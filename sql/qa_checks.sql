
-- Row count and date range verification
SELECT 
    COUNT(*) AS total_rows,
    MIN(date_ist) AS start_date,
    MAX(date_ist) AS end_date,
    COUNT(DISTINCT session_id) AS unique_sessions
FROM funnel_events;

--  Rows per source file
SELECT 
    source_file,
    COUNT(*) AS row_count
FROM funnel_events
GROUP BY source_file
ORDER BY source_file;

--  Event distribution
SELECT 
    event,
    COUNT(*) AS event_count
FROM funnel_events
GROUP BY event
ORDER BY event_count DESC;

-- Page type distribution
SELECT 
    page_type,
    COUNT(DISTINCT session_id) AS sessions,
    ROUND(COUNT(DISTINCT session_id) * 100.0 / 
        SUM(COUNT(DISTINCT session_id)) OVER (), 2) AS pct_of_total
FROM funnel_events
WHERE event = 'session_start'
GROUP BY page_type
ORDER BY sessions DESC;

--Duplicate transaction_ids
SELECT 
    transaction_id,
    COUNT(*) AS occurrence_count
FROM purchase_params
WHERE transaction_id IS NOT NULL
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

--Sessions with purchase but no checkout
SELECT COUNT(DISTINCT p.session_id) AS sessions_purchased_no_checkout
FROM funnel_events p
WHERE p.event = 'purchase'
AND p.session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM funnel_events 
    WHERE event IN (
        'begin_checkout', 
        'gokwik_checkout_initiated'
    )
);

-- Attribution null rates
SELECT
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN source IS NULL THEN 1 ELSE 0 END) AS null_source,
    ROUND(SUM(CASE WHEN source IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_null_source,
    SUM(CASE WHEN medium IS NULL THEN 1 ELSE 0 END) AS null_medium,
    ROUND(SUM(CASE WHEN medium IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_null_medium,
    SUM(CASE WHEN campaign IS NULL THEN 1 ELSE 0 END) AS null_campaign,
    ROUND(SUM(CASE WHEN campaign IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_null_campaign
FROM session_attribution;

-- Sessions missing session_start
SELECT COUNT(DISTINCT session_id) AS sessions_no_session_start
FROM funnel_events
WHERE session_id NOT IN (
    SELECT session_id 
    FROM session_attribution
);

-- Multiple user_ids per session
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT session_id) AS distinct_sessions
FROM funnel_events;

--  Device distribution
SELECT 
    device,
    COUNT(DISTINCT session_id) AS sessions,
    ROUND(COUNT(DISTINCT session_id) * 100.0 / 
        SUM(COUNT(DISTINCT session_id)) OVER (), 2) AS pct_of_total
FROM funnel_events
WHERE event = 'session_start'
GROUP BY device
ORDER BY sessions DESC;

-- Duplicate add_to_cart events within same session
SELECT 
    session_id,
    COUNT(*) AS atc_count
FROM funnel_events
WHERE event IN ('add_to_cart', 'add_to_cart_custom_event')
GROUP BY session_id
HAVING COUNT(*) > 1
ORDER BY atc_count DESC
LIMIT 10;

--  Purchase params null rates
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
    SUM(CASE WHEN value IS NULL THEN 1 ELSE 0 END) AS null_value,
    SUM(CASE WHEN shipping IS NULL THEN 1 ELSE 0 END) AS null_shipping,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS null_discount
FROM purchase_params;