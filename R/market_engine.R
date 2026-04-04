# --- R/market_engine.R ---

#' Convert Decimal Odds to Implied Probability
#'
#' @description
#' Converts decimal betting odds into implied probabilities under the assumption
#' of a fair market without adjustment for bookmaker margin.
#'
#' @usage
#' convert_odds_to_prob(odds)
#'
#' @param odds Numeric vector of decimal odds. All values must be strictly greater than 1.
#'
#' @return
#' Numeric vector of implied probabilities corresponding to each odds value.
#'
#' @details
#' The implied probability is calculated as:
#' \deqn{P = \frac{1}{odds}}
#'
#' For example:
#' \itemize{
#'   \item Odds = 2.00 → Probability = 0.50
#'   \item Odds = 1.50 → Probability ≈ 0.67
#' }
#'
#' This does not account for bookmaker margin.
#'
#' @examples
#' convert_odds_to_prob(c(2.0, 1.5, 3.0))
#'
#' @seealso
#' \code{\link{de_vig_market}}
#'
#' @export
convert_odds_to_prob = function(odds) {
  if (any(odds <= 1)) stop("Error: Odds must be > 1.0")
  return(1 / odds)
}

#' Remove Bookmaker Margin (De-vigging)
#'
#' @description
#' Adjusts implied probabilities derived from market odds so that they sum to one,
#' effectively removing bookmaker margin (overround).
#'
#' @usage
#' de_vig_market(odds_vector)
#'
#' @param odds_vector Numeric vector of decimal odds.
#'
#' @return
#' Numeric vector of normalized probabilities summing to 1.
#'
#' @details
#' Bookmakers embed a margin such that:
#' \deqn{\sum P_i > 1}
#'
#' This function rescales probabilities:
#' \deqn{P_i^{fair} = \frac{P_i}{\sum P_i}}
#'
#' making them comparable to model probabilities.
#'
#' @examples
#' de_vig_market(c(1.90, 1.90))
#'
#' @seealso
#' \code{\link{convert_odds_to_prob}}
#'
#' @export
de_vig_market = function(odds_vector) {
  raw_probs = convert_odds_to_prob(odds_vector)
  total_prob = sum(raw_probs)
  fair_probs = raw_probs / total_prob
  return(fair_probs)
}
#-----------------------------------------------------------------------------------------------
#' Calculate Optimal Stake (Kelly Criterion)
#'
#' @description
#' Computes the optimal fraction of bankroll to wager based on estimated win
#' probability and market odds using the Kelly Criterion.
#'
#' @usage
#' calculate_kelly_stake(our_prob, market_odds, bankroll, fraction = 0.5)
#'
#' @param our_prob Numeric. Estimated probability of winning (0–1).
#' @param market_odds Numeric. Decimal odds offered by the market (>1).
#' @param bankroll Numeric. Current available capital.
#' @param fraction Numeric. Fraction of the full Kelly stake to apply (default 0.5).
#'
#' @return
#' Numeric value representing the recommended stake size.
#'
#' @details
#' The Kelly Criterion determines the optimal fraction of bankroll to wager
#' in order to maximize long-term logarithmic growth of capital.
#'
#' The optimal fraction is given by:
#' \deqn{f^* = \frac{bp - (1 - p)}{b}}
#'
#' where:
#' \itemize{
#'   \item \eqn{b = odds - 1} (net payout per unit stake)
#'   \item \eqn{p} is the model-estimated win probability
#' }
#'
#' Interpretation:
#' \itemize{
#'   \item \eqn{f^* > 0}: Positive edge → bet a fraction of bankroll
#'   \item \eqn{f^* = 0}: Fair bet → no advantage
#'   \item \eqn{f^* < 0}: Negative edge → do not bet
#' }
#'
#' In practice, fractional Kelly (e.g., 0.5 × Kelly) is used to reduce
#' volatility and drawdowns while retaining growth benefits.
#'
#' This method is widely used in quantitative finance and sports betting
#' for optimal capital allocation under uncertainty.
#' 
#' @examples
#' calculate_kelly_stake(0.55, 2.0, 1000)
#'
#' @seealso
#' \code{\link{apply_betting_strategy}}
#' \code{\link{betting_concepts}}
#'
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
#' @description
#' Computes the probability that the combined score of two teams exceeds a
#' specified threshold based on simulated match outcomes.
#'
#' @usage
#' calculate_over_prob(sim_scores_a, sim_scores_b, threshold)
#'
#' @param sim_scores_a Numeric vector of simulated scores for Team A.
#' @param sim_scores_b Numeric vector of simulated scores for Team B.
#' @param threshold Numeric. The run threshold (e.g., 160.5).
#' 
#' @return
#' Numeric value in the interval of 0 and 1, representing the probability that total score exceeds the threshold.
#'
#' @details
#' Over/Under betting involves predicting whether the combined score of both
#' teams will exceed (Over) or fall below (Under) a specified threshold.
#'
#' The probability is estimated empirically using simulation:
#' \deqn{P(\text{Over}) = \frac{\#(score_A + score_B > threshold)}{N}}
#'
#' where \eqn{N} is the number of simulated matches.
#'
#' Interpretation:
#' \itemize{
#'   \item High probability (> 0.5): Model expects a high-scoring match
#'   \item Low probability (< 0.5): Model expects a low-scoring match
#' }
#'
#' The threshold is often a half-integer (e.g., 160.5) to eliminate ties.
#'
#' This approach allows capturing uncertainty in scoring distributions
#' rather than relying on point estimates.
#'
#' @examples
#' 
#' # Step 1: simulate a match
#' sim <- simulate_match(
#'  team_a_stats = c(8.5, 0.05, 1.1),
#'  team_b_stats = c(7.8, 0.06, 0.9))
#'
#' # Step 2: compute over/under probability
#' calculate_over_prob(
#'   sim$team_a_scores,
#'   sim$team_b_scores,
#'   threshold = 160.5)
#' 
#' @seealso
#' \code{\link{calculate_spread_prob}},
#' \code{\link{simulate_match}}
#' \code{\link{betting_concepts}}
#'
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
#' @description
#' Computes the probability that a team covers a specified point spread based on
#' simulated match outcomes.
#'
#' @usage
#' calculate_spread_prob(sim_scores_a, sim_scores_b, spread_a)
#'
#' @param sim_scores_a Numeric vector of simulated scores for Team A.
#' @param sim_scores_b Numeric vector of simulated scores for Team B.
#' @param spread_a Numeric. Handicap applied to Team A (typically negative for favorites, e.g., -5.5).
#'
#' @return
#' Numeric value in the interval of 0 and 1, representing probability of covering the spread.
#'
#' @details
#' Spread betting (also called handicap betting) adjusts the score of one team
#' by a fixed margin to create a balanced betting market.
#'
#' For Team A with spread \eqn{s}, the adjusted outcome is:
#' \deqn{score_A + s > score_B}
#'
#' The probability of covering the spread is estimated as:
#' \deqn{P(\text{cover}) = \frac{\#(score_A + s > score_B)}{N}}
#'
#' Interpretation:
#' \itemize{
#'   \item Negative spread (e.g., -5.5): Team A must win by more than 5.5 runs
#'   \item Positive spread (e.g., +5.5): Team A can lose narrowly and still "cover"
#' }
#'
#' Spread betting is useful when one team is significantly stronger,
#' allowing more balanced and informative betting decisions.
#'
#' @examples
#' 
#' # Step 1: simulate a match
#' sim <- simulate_match(
#'  team_a_stats = c(8.5, 0.05, 1.1),
#'  team_b_stats = c(7.8, 0.06, 0.9))
#'
#' # Step 2: compute probability of covering the spread
#' calculate_spread_prob(
#'   sim$team_a_scores,
#'   sim$team_b_scores,
#'   spread_a = -5.5)
#'
#' @seealso
#' \code{\link{calculate_over_prob}},
#' \code{\link{simulate_match}}
#' \code{\link{betting_concepts}}
#'
#' @export
calculate_spread_prob = function(sim_scores_a, sim_scores_b, spread_a) {
  # spread_a is usually negative for favorites (e.g., -5.5)
  prob_cover = mean((sim_scores_a + spread_a) > sim_scores_b)
  return(prob_cover)
}
