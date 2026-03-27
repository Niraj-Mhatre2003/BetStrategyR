# --- R/strategy_logic.R ---

#' Core Strategy Selector
#' @param our_sim The result list from simulate_match()
#' @param market_odds The decimal odds provided by the bookmaker
#' @param bankroll Current total funds
#' @param type "moneyline", "over_under", or "spread"
#' @param method "flat", "kelly", or "martingale"
# --- R/strategy_logic.R ---

apply_betting_strategy = function(our_sim, market_odds, bankroll, 
                                  type = "moneyline", 
                                  method = "kelly", 
                                  last_outcome = "win", 
                                  prev_stake = 10) {
  
  # 1. Get the probability from the simulation
  our_prob = our_sim$win_prob 
  
  # 2. Calculate Stake
  if (method == "kelly") {
    # We call the function using the exact name 'our_prob'
    stake = calculate_kelly_stake(our_prob = our_prob, 
                                  market_odds = market_odds, 
                                  bankroll = bankroll, 
                                  fraction = 0.5)
  } else if (method == "flat") {
    stake = 20
  } else {
    stake = 10 # Default
  }
  
  return(list(prob = our_prob, stake = stake))
}