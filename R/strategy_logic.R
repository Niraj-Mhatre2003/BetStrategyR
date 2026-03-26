# --- R/strategy_logic.R ---

#' Core Strategy Selector
#' @param type "moneyline", "over_under", or "spread"
#' @param method "flat", "kelly", or "martingale"
apply_betting_strategy = function(our_sim, market_odds, bankroll, 
                                  type = "moneyline", 
                                  method = "kelly", 
                                  last_outcome = "win", 
                                  prev_stake = 10) {
  
  # 1. Determine Probability based on Bet Type
  # For Over/Under, we sum the scores from our 10k simulations
  if (type == "over_under") {
    threshold = 320.5 # Example threshold
    our_prob = mean((our_sim$team_a_scores + our_sim$team_b_scores) > threshold)
  } else if (type == "spread") {
    handicap = -10.5
    our_prob = mean((our_sim$team_a_scores + handicap) > our_sim$team_b_scores)
  } else {
    # Default: Moneyline (Win/Loss)
    our_prob = our_sim$win_prob
  }
  
  # 2. Determine Stake based on Method
  if (method == "flat") {
    # Fixed 5% of initial bankroll 
    stake = bankroll * 0.05 
  } else if (method == "martingale") {
    # Double if last was loss, reset if win 
    stake = if(last_outcome == "loss") prev_stake * 2 else 10
  } else {
    # Default: Kelly Criterion [cite: 45, 46]
    stake = calculate_kelly_stake(our_prob, market_odds, bankroll, fraction = 0.5)
  }
  
  return(list(prob = our_prob, stake = stake, type = type, method = method))
}