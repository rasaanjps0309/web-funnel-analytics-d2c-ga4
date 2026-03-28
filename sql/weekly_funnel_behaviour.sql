---- WEEKLY FUNNEL BEHAVIOUR -----------------------

WITH funnel_values AS (
    SELECT 
		CASE 
		    WHEN DATE(sesion_start_time) BETWEEN '2025-12-01' AND '2025-12-07' THEN 'Week 1'
			WHEN DATE(sesion_start_time) BETWEEN '2025-12-08' AND '2025-12-14' THEN 'Week 2'
		    WHEN DATE(sesion_start_time) BETWEEN '2025-12-22' AND '2025-12-31' THEN 'Week 4'
			ELSE 'Week 3'
		END AS week_label,
        COUNT(session_id) AS total_session,
        SUM(is_product_view) AS product_view,
        SUM(is_atc) AS atc,
        SUM(is_checkout_initiated) AS check_out_initiated,
        SUM(is_add_shipping_info) AS shipping_added,
        SUM(is_add_payment_info) AS payment_info_added,
        SUM(is_purchase) AS purchased
    FROM funnel_view
    GROUP BY week_label
)

SELECT 
    week_label,
    total_session,
    product_view,
    atc,
    check_out_initiated,
    shipping_added,
    payment_info_added,
    purchased,

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
ORDER BY week_label;


---- WEEK LEVEL USER BEHAVIOUR - ORDER & REVENUE  -----------------------------------------




SELECT 
    CASE 
        WHEN DATE(sesion_start_time) BETWEEN '2025-12-01' AND '2025-12-07' THEN 'Week 1'
        WHEN DATE(sesion_start_time) BETWEEN '2025-12-08' AND '2025-12-14' THEN 'Week 2'
        WHEN DATE(sesion_start_time) BETWEEN '2025-12-15' AND '2025-12-21' THEN 'Week 3'
        WHEN DATE(sesion_start_time) BETWEEN '2025-12-22' AND '2025-12-31' THEN 'Week 4'
    END AS week_label,
    ROUND(SUM(total_revenue)::numeric,2) AS revenue,
    SUM(transaction_count) AS orders,
    ROUND(SUM(total_revenue)::numeric /NULLIF(SUM(transaction_count),0)::numeric ,2) AS aov
FROM funnel_view
GROUP BY 1
ORDER BY 1;


