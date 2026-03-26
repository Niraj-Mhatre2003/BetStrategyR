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