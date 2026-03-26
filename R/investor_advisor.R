#' Strategic Investment Advisor
#' @export
invest_advisor = function(team_a_raw, team_b_raw, market_odds_a, bankroll, params, kelly_fraction = 0.5) {
  
  # 1. Internal Scaling (Mechanical Necessity)
  # Uses the mean/std stored within the params object
  scale_input = function(vec, p) {
    return((vec - p$scale_mean) / p$scale_std)
  }
  
  # 2. Preparation
  t_a_scaled = scale_input(team_a_raw, params)
  t_b_scaled = scale_input(team_b_raw, params)
  
  # 3. Run Simulation (Calling your R/simulation_engine.R)
  sim_results = simulate_match(t_a_scaled, t_b_scaled, params)
  
  # 4. Metrics
  our_prob = sim_results$win_prob 
  market_prob = 1 / market_odds_a
  edge = our_prob - market_prob
  ev_pct = ((our_prob * (market_odds_a - 1)) - (1 - our_prob)) * 100
  
  # 5. Staking (Calling your R/market_engine.R)
  stake = calculate_kelly_stake(our_prob, market_odds_a, bankroll, fraction = kelly_fraction)
  
  # 6. Professional Report Output
  cat("\n==============================================")
  cat("\n          BETSIMR ANALYTICS REPORT            ")
  cat("\n==============================================")
  cat(sprintf("\n[ANALYSIS] Theoretical Edge:     %+.2f%%", edge * 100))
  cat(sprintf("\n[ANALYSIS] Expected Value (EV):  %+.2f%%", ev_pct))
  cat("\n----------------------------------------------")
  cat(sprintf("\nModel Win Probability:           %.2f%%", our_prob * 100))
  cat(sprintf("\nMarket Implied Probability:      %.2f%%", market_prob * 100))
  cat("\n----------------------------------------------")
  cat(sprintf("\nSuggested Stake:                 $%.2f", stake))
  
  if (edge > 0.02) {
    cat("\nFINAL STRATEGY:  [ INVEST ]")
  } else {
    cat("\nFINAL STRATEGY:  [ PASS ]")
    cat("\nREASON:          Insufficient Edge")
  }
  cat("\n==============================================\n")
  
  return(invisible(sim_results))
}