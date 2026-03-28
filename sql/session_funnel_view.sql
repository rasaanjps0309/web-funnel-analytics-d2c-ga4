CREATE VIEW funnel_view AS

WITH first_page_ranking  AS(
	SELECT 
		session_id,
		page_type, 
		device, 
		event_time, 
		page_location, 
		ROW_NUMBER()OVER(PARTITION BY session_id ORDER BY event_time) AS page_rnk 
	FROM funnel_events 
),

first_page AS(
	SELECT
		session_id, 
		page_type, 
		device, 
		event_time, 
		page_location
		
	FROM first_page_ranking 
	WHERE page_rnk = 1
),

session_att_ranking AS(
	SELECT 
		*,
		ROW_NUMBER()OVER(PARTITION BY session_id ORDER BY event_time) AS rnk 
	FROM session_attribution_clean
),

session_detail AS(
	SELECT 
		session_id, 
		source,
		medium , 
		campaign 
		
	FROM session_att_ranking
	WHERE rnk = 1
),

purchase AS(
	SELECT 
		session_id, 
		COUNT(DISTINCT transaction_id) AS transaction_count,
		SUM(DISTINCT value) AS total_revenue,
		MAX(CASE WHEN discount IS NOT NULL THEN 1 ELSE 0 END) AS is_discount,
		MAX(CASE WHEN shipping IS NOT NULL THEN 1 ELSE 0 END) AS is_shipping
	FROM purchase_params
	GROUP BY 
		session_id
),

sessions AS(
	SELECT 
	DISTINCT
		fe.session_id, 
		fe.event, 
		fe.event_time,

		fs.page_location, 
		fs.page_type, 
		fs.device,

		sd.source,
		sd.medium , 
		sd.campaign 
		
	FROM funnel_events  AS fe 

	LEFT JOIN first_page AS fs
	ON fe.session_id = fs.session_id

	LEFT JOIN session_detail AS sd
	ON sd.session_id = fe.session_id
 ),

session_final_base AS(
	SELECT 
		session_id,
		page_location,
		device, 
		source,
		medium,
		campaign,
	
	    MAX(CASE 
	            WHEN event = 'view_product_page_loaded' OR event = 'view_item' THEN 1
	            ELSE 0 
	        END) AS is_product_view,
	    MAX(CASE 
	        	WHEN event = 'add_to_cart_custom_event' OR event = 'add_to_cart' THEN 1
	        	ELSE 0 
	    	END) AS is_atc,
			
	    MAX(CASE 
	        	WHEN event = 'begin_checkout' OR event = 'gokwik_checkout_initiated' THEN 1
	        	ELSE 0 
	    	END) AS is_checkout_initiated,
			
	    MAX(CASE 
	        	WHEN event = 'add_shipping_info' THEN 1
	        	ELSE 0 
	    	END) AS is_add_shipping_info,
			
	    MAX(CASE 
	        	WHEN event = 'add_payment_info' THEN 1
	        	ELSE 0 
	    	END) AS is_add_payment_info,
	    MAX(CASE 
	        	WHEN event = 'purchase' THEN 1
	        	ELSE 0 
	    	END) AS is_purchase
			
	FROM sessions
	GROUP BY 
		session_id,
		page_location,
		device, 
		source,
		medium,
		campaign

)

SELECT 
	sfb.*,

	p.transaction_count, 
	p.total_revenue,
	p.is_discount,
	p.is_shipping

FROM session_final_base AS sfb

LEFT JOIN purchase AS p 
ON p.session_id = sfb.session_id 