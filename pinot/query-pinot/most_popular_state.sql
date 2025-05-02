WITH state_counts AS (
  SELECT
    s.artistid,
    addr.state       AS state,
    COUNT(*)         AS cnt
  FROM "stream"            AS s
  JOIN "customer"          AS c    ON c.id        = s.customerid
  JOIN "address"           AS addr ON addr.customerid = c.id
  GROUP BY
    s.artistid,
    addr.state
)
SELECT
  artistid,
  state,
  cnt
FROM (
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
WHERE rn = 1
ORDER BY artistid;