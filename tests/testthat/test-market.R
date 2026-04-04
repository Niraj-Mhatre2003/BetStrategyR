test_that("odds convert correctly", {
  probs = convert_odds_to_prob(c(2.0, 4.0))
  
  expect_equal(probs, c(0.5, 0.25))
})

test_that("invalid odds throw error", {
  expect_error(convert_odds_to_prob(1))
  expect_error(convert_odds_to_prob(0.9))
})

test_that("de_vig sums to 1", {
  probs = de_vig_market(c(1.9, 1.9))
  
  expect_equal(sum(probs), 1)
})

test_that("kelly stake behaves correctly", {
  stake = calculate_kelly_stake(0.6, 2.0, 1000)
  
  expect_true(stake > 0)
})

test_that("kelly returns 0 when no edge", {
  stake = calculate_kelly_stake(0.4, 2.0, 1000)
  
  expect_equal(stake, 0)
})
