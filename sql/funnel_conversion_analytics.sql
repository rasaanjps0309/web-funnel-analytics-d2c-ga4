WITH funnel_values AS(
        SELECT 
                COUNT(session_id) AS total_session,
                SUM(is_product_view) AS product_view,
                SUM(is_atc) AS atc,
                SUM(is_checkout_initiated) AS check_out_initiated,
                SUM(is_add_shipping_info) AS shiping_added,
                SUM(is_add_payment_info) AS payment_info_added,
                SUM(is_purchase) AS purchased
                
        FROM funnel_view
        GROUP BY device
)

SELECT 
        *,
        ROUND(100.00 * (atc::numeric/product_view::numeric),2) AS atc_cvr,
        ROUND(100.00 * (check_out_initiated::numeric/atc::numeric),2) AS checkout_inititaed_cvr,
        ROUND(100.00 * (shiping_added::numeric/check_out_initiated::numeric),2) AS shipping_added_cvr,
        ROUND(100.00 * (payment_info_added::numeric/shiping_added::numeric),2) AS payment_info_added_cvr,
        ROUND(100.00 * (purchased::numeric/payment_info_added::numeric),2) AS purchased_cvr,
        ROUND(100.00 * (purchased::numeric/product_view::numeric),2) AS product_view_purchase,
        ROUND(100.00 * (purchased::numeric/check_out_initiated::numeric),2) AS checkout_to_purchase,
        ROUND(100.00 * (purchased::numeric/437063::numeric),2) As session_to_purchase_cvr
        
FROM funnel_values