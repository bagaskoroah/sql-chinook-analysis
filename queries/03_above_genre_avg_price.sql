-- Case 03: Songs Priced Above Genre Average
-- Objective: Identify tracks that are priced higher than the average price of their genre to spot premium-priced content for pricing strategy evaluation.
SELECT
	song_name,
	genre_name,
	unit_price
FROM (
	SELECT
		t.name AS song_name,
		g.name AS genre_name,
		t.unit_price,
		ROUND(AVG(t.unit_price) OVER (PARTITION BY g.name),2) AS avg_genre_price
	FROM track t
	JOIN genre g ON t.genre_id = g.genre_id)
WHERE unit_price > avg_genre_price;