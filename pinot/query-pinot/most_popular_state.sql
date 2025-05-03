-- First, calculate how many times each artist was streamed in each state
WITH state_counts AS (
  SELECT
    s.artistid,              -- The artist being streamed
    addr.state AS state,     -- The U.S. state where the stream came from
    COUNT(*) AS cnt          -- Total number of streams for that artist in that state
  FROM "stream" AS s
  JOIN customer AS c ON c.id = s.customerid          -- Link streams to customers
  JOIN address AS addr ON addr.customerid = c.id     -- Link customers to their address (to get state)
  GROUP BY s.artistid, addr.state                    -- Group by artist and state to count streams
),

-- Now, rank each state per artist by number of streams (highest to lowest)
ranked AS (
  SELECT
    artistid,
    state,
    cnt,
    ROW_NUMBER() OVER (
      PARTITION BY artistid       -- Restart the row number for each artist
      ORDER BY cnt DESC           -- Highest count = row number 1
    ) AS rn                       -- Row number assigned to each (artist, state) pair
  FROM state_counts
)

-- Finally, select only the top state (rn = 1) for each artist
SELECT
  r.artistid,
  a.name AS artist_name,     -- Artist name from the artist table
  r.state,                   -- Most streamed state for this artist
  r.cnt                      -- Number of streams in that state
FROM ranked AS r
JOIN artist AS a ON a.id = r.artistid     -- Join to get artist names
WHERE r.rn = 1                             -- Only keep the top-ranked state per artist
ORDER BY r.cnt DESC;                       -- Sort so the artist with the strongest state performance appears first