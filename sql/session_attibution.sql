SELECT 
	COUNT(*) AS total_row_count,
	COUNT(DISTINCT session_id) AS distinct_session_count,

	-- NULL_CHECKS

	COUNT(source) AS source_row,
	100.00 - ROUND(100*(COUNT(source)::numeric /COUNT(session_id)::numeric),2) AS pct_null_source,
	
	COUNT(medium) AS med_rows ,
	100.00 - ROUND(100*(COUNT(medium)::numeric /COUNT(session_id)::numeric),2) AS pct_null_medium,
	
	COUNT(campaign) AS camoaign_rows ,
	100.00 - ROUND(100*(COUNT(campaign)::numeric /COUNT(session_id)::numeric),2) AS pct_null_campaign,
	
	COUNT(gclid) AS clikc_rows,
	100.00 - ROUND(100*(COUNT(gclid)::numeric /COUNT(session_id)::numeric),2) AS pct_null_gclid


FROM session_attribution;


--- De duplicating the Sessions: 
-- Aproach : 
--For each session_id
---------------------------
-- count no of nulls each row has
-- rank rows by null count ascending (fewer nulls = top )
--keep rank 1 (the most complete row)
-- Creating Clean session  view 

CREATE VIEW session_attribution_clean AS
WITH row_completeness_base AS(

	SELECT 
		*,
		CASE WHEN source IS NOT NULL THEN 1 ELSE 0 END AS is_source_value,
		CASE WHEN medium IS NOT NULL THEN 1 ELSE 0 END AS is_medium_value,
		CASE WHEN campaign IS NOT NULL THEN 1 ELSE 0 END AS is_campaign_value,
		CASE WHEN gclid IS NOT NULL THEN 1 ELSE 0 END AS is_gclid_value
	FROM session_attribution
),

row_weightage_base AS(

	SELECT 
		*,
		ROW_NUMBER() 
			OVER(PARTITION BY session_id 
				 ORDER BY (is_source_value + is_medium_value + is_campaign_value + is_gclid_value) DESC
				 ) AS row_weitage_rnk
	FROM row_completeness_base
)

SELECT 
	session_id,
	event_time,
	source,
	medium,
	campaign,
	gclid

FROM row_weightage_base
WHERE row_weitage_rnk = 1;



SELECT COUNT(*) FROM session_attribution_clean