# --- R/investor_advisor.R ---

invest_advisor = function(team_a_raw, team_b_raw, market_odds_a, bankroll, params, kelly_fraction = 0.5) {
  
  # 1. Scaling Logic (Using saved training attributes)
  scale_input = function(vec, params) {
    return((vec - params$scale_mean) / params$scale_std)
  }
  
  team_a_scaled = scale_input(team_a_raw, params)
  team_b_scaled = scale_input(team_b_raw, params)
  
  # 2. Monte Carlo Simulation
  our_prob = simulate_match(team_a_scaled, team_b_scaled, params)
  
  # 3. Market Comparison
  market_prob = 1 / market_odds_a
  edge = our_prob - market_prob
  
  # 4. Expected Value (EV) per $1 staked
  ev_pct = ((our_prob * (market_odds_a - 1)) - (1 - our_prob)) * 100
  
  # 5. Kelly Criterion Stake
  stake = calculate_kelly_stake(our_prob, market_odds_a, bankroll, fraction = kelly_fraction)
  stake_pct = (stake / bankroll) * 100
  
  # 6. Analyst Report Output
  cat("\n==============================================")
  cat("\n          BETSIMR ANALYTICS REPORT            ")
  cat("\n==============================================")
  cat(sprintf("\n[ANALYSIS] Theoretical Edge:     %+.2f%%", edge * 100))
  cat(sprintf("\n[ANALYSIS] Expected Value (EV):  %+.2f%%", ev_pct))
  cat("\n----------------------------------------------")
  cat(sprintf("\nModel Win Probability:           %.2f%%", our_prob * 100))
  cat(sprintf("\nMarket Implied Probability:      %.2f%%", market_prob * 100))
  cat("\n----------------------------------------------")
  cat("\n            RISK & STAKING PROFILE            ")
  cat("\n----------------------------------------------")
  cat(sprintf("\nBankroll Allocation:             %.2f%%", stake_pct))
  cat(sprintf("\nSuggested Amount:                $%.2f", stake))
  cat(sprintf("\nRisk Multiplier (Kelly):         %.2f", kelly_fraction))
  cat("\n----------------------------------------------")
  
  # Decision Logic
  if (edge > 0.01) {
    cat("\nFINAL STRATEGY:  [ INVEST ]")
  } else {
    cat("\nFINAL STRATEGY:  [ PASS ]")
    cat(sprintf("\nREASON:          Edge below 1%% threshold"))
  }
  cat("\n==============================================\n")
  
  return(invisible(list(edge = edge, stake_pct = stake_pct, stake = stake)))
}
