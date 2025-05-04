CREATE INDEX CONCURRENTLY precinct_result_idx ON precinct_result (
  year,
  election,
  jurisdiction,
  position,
  candidate
);