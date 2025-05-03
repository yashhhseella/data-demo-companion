WITH state_counts AS (
  SELECT
    s.artistid,
    addr.state AS state,
    COUNT(*) AS cnt
  FROM "stream" AS s
  JOIN customer AS c ON c.id = s.customerid
  JOIN address  AS addr ON addr.customerid = c.id
  GROUP BY s.artistid, addr.state
),


ranked AS (
  SELECT
    artistid,
    state,
    cnt,
    ROW_NUMBER() OVER (
      PARTITION BY artistid
      ORDER BY cnt DESC
    ) AS rn
  FROM state_counts
)


SELECT
  r.artistid,
  a.name AS artist_name,
  r.state,
  r.cnt
FROM ranked AS r
JOIN artist AS a ON a.id = r.artistid
WHERE r.rn = 1
ORDER BY r.cnt DESC;