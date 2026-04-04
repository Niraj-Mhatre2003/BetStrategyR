test_that("validate_data works correctly", {
  df = data.frame(a = 1, b = 2)
  
  expect_true(validate_data(df, c("a", "b")))
  
  expect_error(validate_data(df, c("a", "c")))
})

test_that("create_match_object computes features correctly", {
  obj = create_match_object("TeamA", runs = 120, balls = 120, wickets = 5)
  
  expect_equal(obj$rr, 6)
  expect_equal(obj$wr, 5/120)
})

test_that("venue indices behave correctly", {
  m1 = create_match_object("A", 100, 120, 5, "X")
  m2 = create_match_object("B", 200, 120, 5, "X")
  m3 = create_match_object("C", 150, 120, 5, "Y")
  
  indices = calculate_venue_indices(list(m1, m2, m3))
  
  expect_true("X" %in% names(indices))
  expect_true("Y" %in% names(indices))
})
