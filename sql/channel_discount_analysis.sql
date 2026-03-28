
--------SOURCE/CHANNEL  DISCOUNT ANALYSIS-------------------------------------------------------------

WITH funnel_values AS (
    SELECT 
        source,
        COUNT(session_id) AS total_session,
        SUM(is_product_view) AS product_view,
        SUM(is_atc) AS atc,
        SUM(is_checkout_initiated) AS check_out_initiated,
        SUM(is_add_shipping_info) AS shipping_added,
        SUM(is_add_payment_info) AS payment_info_added,
        SUM(is_purchase) AS purchased,
                SUM(total_revenue) AS total_revenue
                
    FROM funnel_view
    GROUP BY source
        HAVING COUNT(session_id) >= 500
)

SELECT 
    source,
    total_session,
    product_view,
    atc,
    check_out_initiated,
    shipping_added,
    payment_info_added,
    purchased,
        total_revenue,
    -- Step conversion rates (safe divide)
    ROUND(100.0 * atc / NULLIF(product_view, 0), 2) AS atc_cvr,
    ROUND(100.0 * check_out_initiated / NULLIF(atc, 0), 2) AS checkout_initiated_cvr,
    ROUND(100.0 * shipping_added / NULLIF(check_out_initiated, 0), 2) AS shipping_added_cvr,
    ROUND(100.0 * payment_info_added / NULLIF(shipping_added, 0), 2) AS payment_info_added_cvr,
    ROUND(100.0 * purchased / NULLIF(payment_info_added, 0), 2) AS purchased_cvr,

    
    ROUND(100.0 * purchased / NULLIF(product_view, 0), 2) AS product_view_to_purchase,
    ROUND(100.0 * purchased / NULLIF(check_out_initiated, 0), 2) AS checkout_to_purchase,
    ROUND(100.0 * purchased / NULLIF(total_session, 0), 2) AS session_to_purchase_cvr

FROM funnel_values
ORDER BY total_session DESC;



------ DISCOUNT ANALYSIS--------------------------------------------------------------------------

SELECT 
    CASE 
        WHEN is_discount = 1 THEN 'Discounted'
        WHEN is_discount = 0 THEN 'No Discount'
        ELSE 'Did Not Purchase'
    END AS discount_segment,
    COUNT(session_id) AS sessions,
    SUM(is_purchase) AS purchases,
    ROUND(100.0 * SUM(is_purchase)/COUNT(session_id), 2) AS cvr,
    ROUND(AVG(CASE WHEN is_purchase = 1 THEN total_revenue::numeric END), 2) AS avg_order_value
FROM funnel_view
GROUP BY 
    CASE 
        WHEN is_discount = 1 THEN 'Discounted'
        WHEN is_discount = 0 THEN 'No Discount'
        ELSE 'Did Not Purchase'
    END;


