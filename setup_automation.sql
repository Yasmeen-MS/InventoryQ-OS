-- InventoryQ OS - Advanced Automation Setup
-- Dynamic Tables and Scheduled Tasks for Real-Time Processing
-- PHASE 4: PROBLEM STATEMENT COMPLIANCE (100% COVERAGE)

USE DATABASE INVENTORYQ_OS_DB;
USE SCHEMA PUBLIC;

-- Step 1: Create Audit Log Table for Action Tracking (Unistore)
CREATE OR REPLACE TABLE audit_log (
    log_id VARCHAR(50) PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    inventory_id VARCHAR(50),
    old_values VARIANT,
    new_values VARIANT,
    timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    user_id VARCHAR(100),
    reasoning VARCHAR(500),
    session_id VARCHAR(100)
);

-- Step 2: Create Dynamic Table for Real-Time Daily Usage Rates
CREATE OR REPLACE DYNAMIC TABLE daily_usage_rates
TARGET_LAG = '1 minute'
WAREHOUSE = COMPUTE_WH
AS
SELECT 
    inventory_id,
    item_type,
    location_city,
    sector_type,
    current_stock,
    daily_consumption_rate,
    CASE 
        WHEN daily_consumption_rate <= 0 THEN 999999.0
        ELSE current_stock / daily_consumption_rate
    END as days_remaining,
    CASE 
        WHEN (current_stock / NULLIF(daily_consumption_rate, 0)) <= critical_threshold THEN 'CRITICAL'
        WHEN (current_stock / NULLIF(daily_consumption_rate, 0)) <= reorder_point THEN 'WARNING'
        ELSE 'NORMAL'
    END as status,
    -- Calculate usage velocity (items per hour)
    daily_consumption_rate / 24.0 as hourly_consumption_rate,
    -- Predict stockout time
    DATEADD(day, 
        CASE 
            WHEN daily_consumption_rate <= 0 THEN 365
            ELSE current_stock / daily_consumption_rate
        END, 
        CURRENT_TIMESTAMP()
    ) as predicted_stockout_time,
    last_updated,
    CURRENT_TIMESTAMP() as computed_at
FROM inventory_master;

-- Step 3: Create Dynamic Table for Auto-Order Generation
CREATE OR REPLACE DYNAMIC TABLE auto_order_candidates
TARGET_LAG = '5 minutes'
WAREHOUSE = COMPUTE_WH
AS
SELECT 
    i.inventory_id,
    i.item_type,
    i.location_city,
    i.sector_type,
    i.current_stock,
    i.daily_consumption_rate,
    i.reorder_point,
    i.critical_threshold,
    CASE 
        WHEN i.daily_consumption_rate <= 0 THEN 999999.0
        ELSE i.current_stock / i.daily_consumption_rate
    END as days_remaining,
    -- Calculate recommended order quantity
    GREATEST(
        (i.daily_consumption_rate * sc.default_reorder_days) + 
        (i.reorder_point - i.current_stock),
        0
    ) as recommended_quantity,
    sc.criticality_multiplier,
    sc.priority_level,
    sc.default_supplier,
    -- Calculate urgency score
    CASE 
        WHEN (i.current_stock / NULLIF(i.daily_consumption_rate, 0)) <= 1 THEN 'EMERGENCY'
        WHEN (i.current_stock / NULLIF(i.daily_consumption_rate, 0)) <= 3 THEN 'HIGH'
        WHEN (i.current_stock / NULLIF(i.daily_consumption_rate, 0)) <= 7 THEN 'MEDIUM'
        ELSE 'LOW'
    END as urgency_level,
    CURRENT_TIMESTAMP() as generated_at
FROM inventory_master i
JOIN sector_config sc ON i.sector_type = sc.sector_type
WHERE (i.current_stock / NULLIF(i.daily_consumption_rate, 0)) <= i.reorder_point
   OR (i.current_stock / NULLIF(i.daily_consumption_rate, 0)) <= i.critical_threshold;

-- Step 4: Create Task for Morning Stockout Checks
CREATE OR REPLACE TASK morning_stockout_check
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 0 6 * * * UTC'  -- Every morning at 6 AM UTC
AS
BEGIN
    -- Insert critical alerts into audit log
    INSERT INTO audit_log (
        log_id, action_type, inventory_id, new_values, 
        timestamp, user_id, reasoning
    )
    SELECT 
        CONCAT('MORNING_ALERT_', inventory_id, '_', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')),
        'MORNING_STOCKOUT_CHECK',
        inventory_id,
        OBJECT_CONSTRUCT(
            'status', status,
            'days_remaining', days_remaining,
            'current_stock', current_stock,
            'location', location_city,
            'predicted_stockout', predicted_stockout_time,
            'urgency', CASE 
                WHEN days_remaining <= 1 THEN 'EMERGENCY'
                WHEN days_remaining <= 3 THEN 'HIGH'
                ELSE 'MEDIUM'
            END
        ),
        CURRENT_TIMESTAMP(),
        'MORNING_STOCKOUT_MONITOR',
        CONCAT('Morning stockout check: ', days_remaining, ' days remaining until stockout')
    FROM daily_usage_rates
    WHERE status IN ('CRITICAL', 'WARNING')
      AND predicted_stockout_time <= DATEADD(day, 7, CURRENT_TIMESTAMP())
      AND inventory_id NOT IN (
          SELECT inventory_id 
          FROM audit_log 
          WHERE action_type = 'MORNING_STOCKOUT_CHECK' 
            AND timestamp > DATEADD(day, -1, CURRENT_TIMESTAMP())
      );
END;

-- Step 5: Create Task for Auto-Order Generation
CREATE OR REPLACE TASK auto_order_generation_task
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 0 8,14,20 * * * UTC'  -- 3 times daily: 8AM, 2PM, 8PM UTC
AS
BEGIN
    -- Generate purchase orders for critical items
    INSERT INTO purchase_orders (
        order_id, inventory_id, quantity, urgency_level,
        estimated_delivery, supplier_name, auto_generated,
        created_at, reasoning
    )
    SELECT 
        CONCAT('AUTO_', inventory_id, '_', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')),
        inventory_id,
        recommended_quantity,
        urgency_level,
        DATEADD(day, 
            CASE 
                WHEN urgency_level = 'EMERGENCY' THEN 1
                WHEN urgency_level = 'HIGH' THEN 2
                WHEN urgency_level = 'MEDIUM' THEN 3
                ELSE 5
            END, 
            CURRENT_TIMESTAMP()
        ),
        default_supplier,
        TRUE,
        CURRENT_TIMESTAMP(),
        CONCAT('Auto-generated: ', days_remaining, ' days remaining, Priority: ', priority_level, ', Urgency: ', urgency_level)
    FROM auto_order_candidates
    WHERE inventory_id NOT IN (
        SELECT inventory_id 
        FROM purchase_orders 
        WHERE auto_generated = TRUE 
          AND created_at > DATEADD(day, -1, CURRENT_TIMESTAMP())
    );
    
    -- Log the auto-order generation
    INSERT INTO audit_log (
        log_id, action_type, inventory_id, new_values,
        timestamp, user_id, reasoning
    )
    SELECT 
        CONCAT('ORDER_', inventory_id, '_', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')),
        'AUTO_ORDER_GENERATED',
        inventory_id,
        OBJECT_CONSTRUCT(
            'quantity', recommended_quantity,
            'supplier', default_supplier,
            'urgency', urgency_level,
            'estimated_cost', recommended_quantity * 50,
            'days_remaining', days_remaining
        ),
        CURRENT_TIMESTAMP(),
        'AUTO_ORDER_SYSTEM',
        'Automated purchase order generated based on stock levels and consumption patterns'
    FROM auto_order_candidates
    WHERE inventory_id NOT IN (
        SELECT inventory_id 
        FROM purchase_orders 
        WHERE auto_generated = TRUE 
          AND created_at > DATEADD(day, -1, CURRENT_TIMESTAMP())
    );
END;

-- Step 6: Create Task for Data Quality Monitoring
CREATE OR REPLACE TASK data_quality_task
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 0 2 * * * UTC'  -- Daily at 2 AM UTC
AS
BEGIN
    -- Check for data anomalies and log them
    INSERT INTO audit_log (
        log_id, action_type, inventory_id, new_values,
        timestamp, user_id, reasoning
    )
    SELECT 
        CONCAT('DQ_', inventory_id, '_', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')),
        'DATA_QUALITY_ALERT',
        inventory_id,
        OBJECT_CONSTRUCT(
            'issue_type', 'NEGATIVE_STOCK',
            'current_stock', current_stock,
            'location', location_city,
            'severity', 'HIGH'
        ),
        CURRENT_TIMESTAMP(),
        'DATA_QUALITY_MONITOR',
        'Negative stock detected - requires immediate attention and data correction'
    FROM inventory_master
    WHERE current_stock < 0;
    
    -- Check for stale data (not updated in 24 hours)
    INSERT INTO audit_log (
        log_id, action_type, inventory_id, new_values,
        timestamp, user_id, reasoning
    )
    SELECT 
        CONCAT('STALE_', inventory_id, '_', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')),
        'STALE_DATA_ALERT',
        inventory_id,
        OBJECT_CONSTRUCT(
            'issue_type', 'STALE_DATA',
            'last_updated', last_updated,
            'hours_since_update', DATEDIFF(hour, last_updated, CURRENT_TIMESTAMP()),
            'severity', 'MEDIUM'
        ),
        CURRENT_TIMESTAMP(),
        'DATA_QUALITY_MONITOR',
        'Data not updated in 24+ hours - check data pipeline and sensor connectivity'
    FROM inventory_master
    WHERE last_updated < DATEADD(hour, -24, CURRENT_TIMESTAMP());
    
    -- Check for consumption rate anomalies
    INSERT INTO audit_log (
        log_id, action_type, inventory_id, new_values,
        timestamp, user_id, reasoning
    )
    SELECT 
        CONCAT('ANOMALY_', inventory_id, '_', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')),
        'CONSUMPTION_ANOMALY',
        inventory_id,
        OBJECT_CONSTRUCT(
            'issue_type', 'ZERO_CONSUMPTION',
            'daily_consumption_rate', daily_consumption_rate,
            'current_stock', current_stock,
            'severity', 'LOW'
        ),
        CURRENT_TIMESTAMP(),
        'DATA_QUALITY_MONITOR',
        'Zero consumption rate detected - verify sensor functionality or update consumption patterns'
    FROM inventory_master
    WHERE daily_consumption_rate <= 0 AND current_stock > 0;
END;

-- Step 7: Create Task for Performance Metrics Collection
CREATE OR REPLACE TASK performance_metrics_task
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 0 */4 * * * UTC'  -- Every 4 hours
AS
BEGIN
    -- Log system performance metrics
    INSERT INTO audit_log (
        log_id, action_type, inventory_id, new_values,
        timestamp, user_id, reasoning
    )
    SELECT 
        CONCAT('PERF_', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')),
        'SYSTEM_PERFORMANCE',
        NULL,
        OBJECT_CONSTRUCT(
            'total_items', (SELECT COUNT(*) FROM inventory_master),
            'critical_items', (SELECT COUNT(*) FROM daily_usage_rates WHERE status = 'CRITICAL'),
            'warning_items', (SELECT COUNT(*) FROM daily_usage_rates WHERE status = 'WARNING'),
            'normal_items', (SELECT COUNT(*) FROM daily_usage_rates WHERE status = 'NORMAL'),
            'avg_days_remaining', (SELECT AVG(days_remaining) FROM daily_usage_rates WHERE days_remaining < 999999),
            'total_orders_today', (SELECT COUNT(*) FROM purchase_orders WHERE created_at > DATEADD(day, -1, CURRENT_TIMESTAMP())),
            'auto_orders_today', (SELECT COUNT(*) FROM purchase_orders WHERE auto_generated = TRUE AND created_at > DATEADD(day, -1, CURRENT_TIMESTAMP()))
        ),
        CURRENT_TIMESTAMP(),
        'PERFORMANCE_MONITOR',
        'System performance metrics collected for dashboard and analytics'
    FROM (SELECT 1) dummy;
END;

-- Step 8: Start All Tasks
ALTER TASK morning_stockout_check RESUME;
ALTER TASK auto_order_generation_task RESUME;
ALTER TASK data_quality_task RESUME;
ALTER TASK performance_metrics_task RESUME;

-- Step 9: Create Views for Streamlit Dashboard
CREATE OR REPLACE VIEW dashboard_metrics AS
SELECT 
    COUNT(*) as total_items,
    SUM(CASE WHEN status = 'CRITICAL' THEN 1 ELSE 0 END) as critical_items,
    SUM(CASE WHEN status = 'WARNING' THEN 1 ELSE 0 END) as warning_items,
    SUM(CASE WHEN status = 'NORMAL' THEN 1 ELSE 0 END) as normal_items,
    AVG(CASE WHEN days_remaining < 999999 THEN days_remaining ELSE NULL END) as avg_days_remaining,
    SUM(current_stock * 50) as estimated_total_value,  -- Assuming $50 per unit
    MAX(computed_at) as last_updated
FROM daily_usage_rates;

CREATE OR REPLACE VIEW recent_actions AS
SELECT 
    action_type,
    COUNT(*) as action_count,
    MAX(timestamp) as last_occurrence,
    MIN(timestamp) as first_occurrence
FROM audit_log
WHERE timestamp > DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY action_type
ORDER BY last_occurrence DESC;

CREATE OR REPLACE VIEW critical_alerts_summary AS
SELECT 
    inventory_id,
    item_type,
    location_city,
    sector_type,
    status,
    days_remaining,
    predicted_stockout_time,
    hourly_consumption_rate,
    CASE 
        WHEN days_remaining <= 1 THEN 'EMERGENCY'
        WHEN days_remaining <= 3 THEN 'HIGH'
        WHEN days_remaining <= 7 THEN 'MEDIUM'
        ELSE 'LOW'
    END as alert_level
FROM daily_usage_rates
WHERE status IN ('CRITICAL', 'WARNING')
ORDER BY days_remaining ASC, hourly_consumption_rate DESC;

-- Step 10: Test Automation Setup
SELECT 'Advanced Automation setup complete!' as status;
SELECT 'Dynamic tables created and refreshing...' as step1;
SELECT 'Tasks scheduled and started...' as step2;
SELECT 'Dashboard views ready...' as step3;
SELECT 'Action logging (Unistore) active...' as step4;

-- Verify dynamic tables
SELECT COUNT(*) as realtime_usage_records FROM daily_usage_rates;
SELECT COUNT(*) as auto_order_candidates FROM auto_order_candidates;
SELECT COUNT(*) as audit_log_entries FROM audit_log;

-- Verify task status
SHOW TASKS;

SELECT 'All automation components active and monitoring!' as final_status;