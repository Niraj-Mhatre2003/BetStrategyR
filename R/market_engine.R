# --- R/market_engine.R ---

# Convert Decimal Odds to Implied Probability
convert_odds_to_prob = function(odds) {
  if (any(odds <= 1)) stop("Error: Odds must be > 1.0")
  return(1 / odds)
}

# Remove Bookmaker Margin (De-vigging)
# Professional addition: Normalizes market probabilities to sum to 1.0
de_vig_market = function(odds_vector) {
  raw_probs = convert_odds_to_prob(odds_vector)
  total_prob = sum(raw_probs)
  fair_probs = raw_probs / total_prob
  return(fair_probs)
}

# The Kelly Criterion formula for optimal stake
# f* = (bp - q) / b
calculate_kelly_stake = function(our_prob, market_odds, bankroll, fraction = 0.5) {
  b = market_odds - 1
  p = our_prob
  q = 1 - p
  
  # Basic Kelly Fraction
  kelly_f = (b * p - q) / b
  
  # Safety Guard: If edge is negative, stake is 0
  if (kelly_f <= 0) return(0)
  
  # Apply Fractional Kelly (risk management)
  suggested_stake = (kelly_f * fraction) * bankroll
  return(suggested_stake)
}

# --- R/market_engine.R ---

# Logic for Over/Under Betting
# Returns probability that total runs > threshold
calculate_over_prob = function(sim_scores_a, sim_scores_b, threshold) {
  total_scores = sim_scores_a + sim_scores_b
  prob_over = mean(total_scores > threshold)
  return(prob_over)
}

# Logic for Point Spread (Handicap)
# Returns probability that Team A wins after applying the spread
calculate_spread_prob = function(sim_scores_a, sim_scores_b, spread_a) {
  # spread_a is usually negative for favorites (e.g., -5.5)
  prob_cover = mean((sim_scores_a + spread_a) > sim_scores_b)
  return(prob_cover)
}