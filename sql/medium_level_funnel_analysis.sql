
----  MEDIUM LEVEL ------------------
WITH funnel_values AS (
    SELECT 
        medium,
        COUNT(session_id) AS total_session,
        SUM(is_product_view) AS product_view,
        SUM(is_atc) AS atc,
        SUM(is_checkout_initiated) AS check_out_initiated,
        SUM(is_add_shipping_info) AS shipping_added,
        SUM(is_add_payment_info) AS payment_info_added,
        SUM(is_purchase) AS purchased,

		ROUND(SUM(total_revenue)::numeric,2) AS revenue,
    	SUM(transaction_count) AS orders
		
    FROM funnel_view
    GROUP BY medium
	HAVING COUNT(session_id) >100
)

SELECT 
    medium,
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
ORDER BY total_session DESC;
