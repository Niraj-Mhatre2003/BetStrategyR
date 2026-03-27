# --- R/market_engine.R ---

# Convert Decimal Odds to Implied Probability----------------------
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
#-----------------------------------------------------------------------------------------------
#' Calculate Optimal Betting Stake
#' 
#' Uses the Kelly Criterion to determine the dollar amount to wager based on model edge.
#' @param our_prob The win probability calculated by the simulation engine.
#' @param market_odds The decimal odds offered by the bookmaker.
#' @param bankroll The total available funds for betting.
#' @param fraction The Kelly multiplier (default 0.5 for a conservative Half-Kelly).
#' @return A numeric value representing the recommended stake in dollars.
#' @export
calculate_kelly_stake = function(our_prob, market_odds, bankroll, fraction = 0.5) {
  # Standard Kelly: f* = (bp - q) / b
  b = market_odds - 1
  p = our_prob
  q = 1 - p
  
  kelly_f = (b * p - q) / b
  
  # If no edge or error, bet $0
  if (is.na(kelly_f) || kelly_f <= 0) return(0)
  
  # Return the dollar amount to bet
  return((kelly_f * fraction) * bankroll)
}
# Logic for Over/Under Betting----------------------------------------------------------
# Returns probability that total runs > threshold
#' Calculate Over/Under Probability
#' 
#' Computes the probability that the total match score exceeds a specific threshold.
#' @param sim_scores_a Vector of simulated scores for Team A.
#' @param sim_scores_b Vector of simulated scores for Team B.
#' @param threshold The run threshold (e.g., 160.5).
#' @return A numeric probability between 0 and 1.
#' @export
calculate_over_prob = function(sim_scores_a, sim_scores_b, threshold) {
  total_scores = sim_scores_a + sim_scores_b
  prob_over = mean(total_scores > threshold)
  return(prob_over)
}

# Logic for Point Spread (Handicap)
# Returns probability that Team A wins after applying the spread
#' Calculate Point Spread (Handicap) Probability
#' 
#' Computes the probability of a team "covering the spread" based on simulations.
#' @param sim_scores_a Vector of simulated scores for Team A.
#' @param sim_scores_b Vector of simulated scores for Team B.
#' @param spread_a The handicap applied to Team A (e.g., -5.5 for favorites).
#' @return A numeric probability between 0 and 1.
#' @export
calculate_spread_prob = function(sim_scores_a, sim_scores_b, spread_a) {
  # spread_a is usually negative for favorites (e.g., -5.5)
  prob_cover = mean((sim_scores_a + spread_a) > sim_scores_b)
  return(prob_cover)
}
calculate_spread_prob = function(sim_scores_a, sim_scores_b, spread_a) {
  # spread_a is usually negative for favorites (e.g., -5.5)
  prob_cover = mean((sim_scores_a + spread_a) > sim_scores_b)
  return(prob_cover)
}