# --- R/strategy_logic.R ---

#' Core Strategy Selector
#' 
#' @description
#' Determines the optimal bet size based on model-derived probabilities,
#' market odds, and the selected staking strategy.
#'
#' @usage
#' apply_betting_strategy(our_sim, market_odds, bankroll,
#'                        type = "moneyline", method = "kelly",
#'                        last_outcome = "win", prev_stake = 10,
#'                        threshold = 160.5, spread = -5.5)
#' 
#' @param our_sim Simulation results from \code{\link{simulate_match}}.
#' @param market_odds Decimal odds provided by bookmaker.
#' @param bankroll Numeric. Current funds.
#' @param type Market type: "moneyline", "over_under", "spread".
#' @param method Staking method: "kelly", "flat", "martingale".
#' @param last_outcome Previous bet outcome: "win" or "loss".
#' @param prev_stake Amount wagered in previous round.
#' @param threshold Run threshold for over/under bets.
#' @param spread Handicap for spread bets.
#' 
#' @return A list containing:
#'   \item{prob}{Probability of winning for this bet.}
#'   \item{stake}{Recommended stake in dollars.}
#' 
#' @details
#' The function first computes the relevant probability depending on the selected
#' bet type, and then applies a staking rule:
#'
#' \itemize{
#'   \item \strong{Kelly}: maximizes long-term logarithmic growth
#'   \item \strong{Flat}: constant fraction of bankroll per bet
#'   \item \strong{Martingale}: doubles stake after losses
#' }
#'
#' For theoretical background and risk considerations, see
#' \code{\link{betting_concepts}}.
#'
#' @examples
#' # Simulate a match (uses built-in model if NULL)
#' sim <- simulate_match(
#'   team_a_stats = c(8.5, 0.05, 1.1),
#'   team_b_stats = c(7.8, 0.06, 0.9),
#'   params = NULL
#' )
#'
#' # Apply Kelly strategy
#' apply_betting_strategy(
#'   our_sim = sim,
#'   market_odds = 1.90,
#'   bankroll = 1000,
#'   method = "kelly"
#' )
#'
#' # Compare with flat betting
#' apply_betting_strategy(
#'   our_sim = sim,
#'   market_odds = 1.90,
#'   bankroll = 1000,
#'   method = "flat"
#' )
#'
#' # Over/Under betting strategy
#' apply_betting_strategy(
#'   our_sim = sim,
#'   market_odds = 1.90,
#'   bankroll = 1000,
#'   type = "over_under",
#'   threshold = 160.5
#' )
#'
#' # Martingale strategy (after a loss)
#' apply_betting_strategy(
#'   our_sim = sim,
#'   market_odds = 1.90,
#'   bankroll = 1000,
#'   method = "martingale",
#'   last_outcome = "loss",
#'   prev_stake = 20
#' )
#' 
#' @seealso
#' \code{\link{calculate_kelly_stake}},
#' \code{\link{calculate_over_prob}},
#' \code{\link{calculate_spread_prob}},
#' \code{\link{betting_concepts}}
#' 
#' @export
apply_betting_strategy = function(our_sim, market_odds, bankroll, 
                                  type = "moneyline", 
                                  method = "kelly", 
                                  last_outcome = "win", 
                                  prev_stake = 10,
                                  threshold = 160.5,
                                  spread = -5.5) {
  validate_odds(market_odds)
  # 1. Get probability based on bet type
  if (type == "moneyline") {
    our_prob = our_sim$win_prob
    
  } else if (type == "over_under") {
    our_prob = calculate_over_prob(
      our_sim$team_a_scores,
      our_sim$team_b_scores,
      threshold
    )
    
  } else if (type == "spread") {
    our_prob = calculate_spread_prob(
      our_sim$team_a_scores,
      our_sim$team_b_scores,
      spread
    )
    
  } else {
    stop("Invalid bet type")
  }
  
  # 2. Calculate Stake
  if (method == "kelly") {
    stake = calculate_kelly_stake(
      our_prob = our_prob, 
      market_odds = market_odds, 
      bankroll = bankroll, 
      fraction = 0.5
    )
    
  } else if (method == "flat") {
    flat_pct = 0.02   # 2% bankroll
    stake = bankroll * flat_pct
    
  } else if (method == "martingale") {
    base_stake = 0.01 * bankroll   # 1% base
    
    if (last_outcome == "loss") {
      stake = prev_stake * 2
    } else {
      stake = base_stake
    }
    stake = min(stake, 0.2 * bankroll)
    
  } else {
    stop("Invalid staking method")
  }
  
  return(list(prob = our_prob, stake = stake))
}
