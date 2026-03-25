# Convert decimal odds to implied probability
# Validation: Odds must be greater than 1
get_implied_prob = function(odds) {
  if (any(odds <= 1)) {
    stop("Error: Odds must be greater than 1.0")
  }
  
  probs = 1 / odds
  return(probs)
}
# Calculate the bookmaker's margin (the "Overround")-------------------------------------------

calculate_margin = function(odds) {
  probs = get_implied_prob(odds)
  margin = sum(probs) - 1
  return(margin)
}

# Basic De-vigging (Normalization)------------------------------------------------------------------------
# This assumes the bookmaker spreads the margin proportionally
de_vig_basic = function(odds) {
  raw_probs = get_implied_prob(odds)
  total_prob = sum(raw_probs)
  
  # Normalize to ensure sum equals 1.0
  fair_probs = raw_probs / total_prob
  return(fair_probs)
}

# Calculate the difference between simulation and market-------------------------------------------------------------------
calculate_edge = function(model_prob, market_prob) {
  # Logic: If model says 60% and market says 55%, edge is 5%
  edge = model_prob - market_prob
  return(edge)
}


#' Calculate Decimal Odds from Stake and Payout--------------------------------------------------------------------
calculate_odds_from_amounts = function(stake, total_payout) {
  if (stake <= 0) {
    stop("Error: Stake must be a positive number.")
  }
  
  # Decimal Odds = Total Payout / Stake
  decimal_odds = total_payout / stake
  
  return(decimal_odds)
}

#' Convert Fractional Odds to Decimal
convert_fractional_to_decimal = function(numerator, denominator) {
  # Formula: (Num / Den) + 1
  decimal_odds = (numerator / denominator) + 1
  return(decimal_odds)
}

#' Convert American Odds to Decimal
convert_american_to_decimal = function(american_odds) {
  # Vectorized approach: much faster for thousands of odds
  decimal_odds = ifelse(american_odds >= 100, 
                        (american_odds / 100) + 1, 
                        (100 / abs(american_odds)) + 1)
  
  # Validation
  if (any(american_odds > -100 & american_odds < 100)) {
    stop("Error: American odds must be >= 100 or <= -100")
  }
  
  return(decimal_odds)
}

#' Convert Decimal Odds to Implied Probability--------------------------------------------
convert_odds_to_prob = function(odds) {
  # Validation check
  if (odds <= 1) {
    stop("Odds must be greater than 1")
  }
  
  # Calculation: Prob = 1 / Odds
  prob = 1 / odds
  return(prob)
}

#' Calculate Betting Edge
#' Edge = Your_Prob - Market_Prob
calculate_edge = function(your_prob, market_odds) {
  market_prob = convert_odds_to_prob(market_odds)
  edge = your_prob - market_prob
  return(edge)
}
#model prob = This is the Theoretical Edge. It tells you if your statistical model disagrees with the bookmaker's math.
#model odds = This is the Price Gap. It tells you how much "extra" money you are getting compared to what you should be getting.




