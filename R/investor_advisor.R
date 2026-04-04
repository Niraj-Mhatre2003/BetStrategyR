# --- R/investor_advisor.R ---
#' Strategic Investment Advisor
#' 
#' @description
#' Generates a comprehensive betting analytics report by combining match 
#' simulations with market odds and bankroll management.
#' 
#' @usage
#' invest_advisor(team_a_raw, team_b_raw, market_odds_a, bankroll, params,
#'                bet_type = "moneyline", threshold = 160.5,
#'                spread = -5.5, kelly_fraction = 0.5,
#'                strategy_method = "kelly")
#' 
#' @param team_a_raw Numeric vector (RR, WR, VenueIdx) for Team A.
#' @param team_b_raw Numeric vector (RR, WR, VenueIdx) for Team B.
#' @param market_odds_a Decimal odds for Team A to win (default 1.90).
#' @param bankroll Numeric. Available betting capital (default 1000).
#' @param params List containing trained model and scaling parameters.
#' @param bet_type "moneyline", "over_under", or "spread" (default "moneyline").
#' @param threshold Numeric. Run threshold for over/under (default 160.5).
#' @param spread Numeric. Handicap for spread bets (default -5.5).
#' @param kelly_fraction Fraction of Kelly stake to use (default 0.5).
#' @param strategy_method Staking method: "kelly" or "flat" or "martingale" (default "kelly").
#' 
#' @return
#' Invisibly returns simulation results from \code{\link{simulate_match}}.
#' The primary output is a formatted console report.
#' 
#' @details
#' The function performs the following steps:
#' \enumerate{
#'   \item Simulates match outcomes using \code{\link{simulate_match}}.
#'   \item Computes model probability of winning or covering the bet.
#'   \item Converts market odds to implied probability.
#'   \item Calculates:
#'     \itemize{
#'       \item Theoretical edge
#'       \item Expected value (EV)
#'     }
#'   \item Applies a betting strategy via \code{\link{apply_betting_strategy}}.
#'   \item Outputs a professional analytics report.
#' }
#'
#' A bet is recommended only if the edge exceeds a minimum threshold (2%).
#' See \code{\link{betting_concepts}} for a detailed explanation of supported
#' bet types and staking strategies.
#'
#' @seealso
#' \code{\link{simulate_match}},
#' \code{\link{apply_betting_strategy}}
#' \code{\link{betting_concepts}}
#' 
#' @keywords internal
invest_advisor = function(team_a_raw, team_b_raw, market_odds_a, bankroll, params, bet_type = "moneyline", threshold = 160.5, spread = -5.5, kelly_fraction = 0.5, strategy_method = "kelly") {
  
  # 1. Check
  if (length(team_a_raw) != 3 || length(team_b_raw) != 3) {
    stop("Each team must have exactly 3 features: RR, WR, VenueIdx")
  }
  
  # 2. Preparation
  t_a_scaled = team_a_raw
  t_b_scaled = team_b_raw
  
  # 3. Run Simulation (Calling your R/simulation_engine.R)
  sim_results = simulate_match(t_a_scaled, t_b_scaled, params)
  
  # 4. Metrics
  our_prob = sim_results$win_prob 
  
  if (bet_type == "moneyline") {
    our_prob = sim_results$win_prob
    
  } else if (bet_type == "over_under") {
    our_prob = calculate_over_prob(
      sim_results$team_a_scores,
      sim_results$team_b_scores,
      threshold
    )
    
  } else if (bet_type == "spread") {
    our_prob = calculate_spread_prob(
      sim_results$team_a_scores,
      sim_results$team_b_scores,
      spread
    )
    
  } else {
    stop("Invalid bet type")
  }
  
  market_prob = 1 / market_odds_a
  edge = our_prob - market_prob
  ev_pct = ((our_prob * (market_odds_a - 1)) - (1 - our_prob)) * 100
  
  # 5. Staking (Calling R/market_engine.R)
  strat = apply_betting_strategy(
    our_sim = sim_results,
    market_odds = market_odds_a,
    bankroll = bankroll,
    type = bet_type,
    method = strategy_method,
    last_outcome = "win",   # no history here
    prev_stake = 10,
    threshold = threshold,
    spread = spread
  )
  
  stake = strat$stake
  
  # 6. Professional Report Output
  message("\n==============================================")
  message("\n          BETSTRATEGYR ANALYTICS REPORT            ")
  message("\n==============================================")
  message(sprintf("\nBet Type:                       %s", toupper(bet_type)))
  message(sprintf("Staking Strategy:               %s", toupper(strategy_method)))
  message(sprintf("\n[ANALYSIS] Theoretical Edge:     %+.2f%%", edge * 100))
  message(sprintf("\n[ANALYSIS] Expected Value (EV):  %+.2f%%", ev_pct))
  message("\n----------------------------------------------")
  message(sprintf("\nModel Win Probability:           %.2f%%", our_prob * 100))
  message(sprintf("\nMarket Implied Probability:      %.2f%%", market_prob * 100))
  message("\n----------------------------------------------")
  
  if (edge > 0.02) {
    message(sprintf("\nSuggested Stake:                 $%.2f", stake))
    message("\nFINAL STRATEGY:  [ INVEST ]")
  } else {
    message(sprintf("\nSuggested Stake:                 $%.2f", 0.00))
    message("\nFINAL STRATEGY:  [ PASS ]")
    message("\nREASON:          Insufficient Edge")
  }
  message("\n==============================================\n")
  
  return(invisible(sim_results))
}
