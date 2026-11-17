# Tests

A small test suite for the Dota Carry Lab R code. It uses **base R + dplyr only**
(no testthat), so it runs anywhere the app runs.

## How to run

From the repo root:

```bash
Rscript tests/run_tests.R
```

Each test prints `ok:` or `FAIL:`. The last line is the summary. The script exits
with status `1` if any test failed, so it can be used in scripts or CI.

## What is covered

- **scoring.R**: `shrink()` (baseline, large-sample and in-between behaviour),
  `assign_tier()` cut-offs, `bracket_stats()` on the real snapshot (winrates in
  [0, 1], pick rates summing to about 10), `carry_meta_board()` (size, pool,
  sort order), and `matchup_advantages()` on small fake data.
- **TODO(human) functions**: `score_candidate()` and `percentile_of()` are only
  checked for returning one number. Their real behaviour is left for you; an
  optional, commented-out block at the bottom of the file has the checks to enable
  once you implement them.
- **Data integrity**: every JSON in `data/curated` and `data/processed` parses;
  curated item keys exist in the item list; curated heroes are in `MY_MAINS`;
  starting kits cost at most 600 gold; core item timings are whole minutes between
  5 and 60 and never go backwards; carry-pool heroes exist and have bracket
  matchup files with games.
- **Data helpers**: `item_img()`, `hero_item_popularity()` and `hero_matchups()`.

## How to add a test

Tests live in `tests/run_tests.R`, grouped under section headers. Add one block
like this:

```r
test_results <- c(test_results, test_that_simple("a short description", {
  result <- my_function(1)
  stopifnot(result == 2)   # if this is FALSE, the test fails
}))
```

- Use `stopifnot()` for each check. Give a readable message with `"msg" = condition`
  when it helps, for example `stopifnot("must be positive" = x > 0)`.
- Put the new block in the matching section, or add a new section header.
- Compare decimals with a tolerance, like `abs(a - b) < 1e-6`, not `==`.
- Run `Rscript tests/run_tests.R` again and check the summary line.
