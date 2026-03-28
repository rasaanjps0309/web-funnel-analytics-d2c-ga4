-- Distinct Session Count 
SELECT 
	COUNT(DISTINCT session_id) AS unique_session 
FROM funnel_events 


-- Traffic share by page type 

	SELECT 
		page_type,
		COUNT(DISTINCT session_id) AS session_page_distributiuon,
		ROUND(COUNT(DISTINCT session_id) * 100.0 / 
        SUM(COUNT(DISTINCT session_id)) OVER (), 2) AS pct_of_total
	FROM funnel_events 
	GROUP BY page_type
	ORDER BY COUNT(DISTINCT session_id) DESC

-- Device Wise Traffic Distribution 

	SELECT 
		device,
		COUNT(DISTINCT session_id) AS session_page_distributiuon,
		ROUND(COUNT(DISTINCT session_id) * 100.0 / 
        SUM(COUNT(DISTINCT session_id)) OVER (), 2) AS pct_of_total
	FROM funnel_events 
	GROUP BY device
	ORDER BY COUNT(DISTINCT session_id) DESC
