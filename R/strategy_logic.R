# --- R/strategy_logic.R ---

#' Core Strategy Selector
#' 
#' Evaluates different wagering strategies (Kelly Criterion, Flat Betting) 
#' based on simulation results and market conditions.
#' 
#' @param our_sim The result list returned from simulate_match().
#' @param market_odds The decimal odds provided by the bookmaker.
#' @param bankroll Current total funds available for wagering.
#' @param type Betting market type: "moneyline", "over_under", or "spread" (Default "moneyline").
#' @param method Staking method: "flat", "kelly", or "martingale" (Default "kelly").
#' @param last_outcome Result of the previous bet, used for progression strategies (Default "win").
#' @param prev_stake The amount wagered in the previous round (Default 10).
#' @return A list containing the calculated win probability and the recommended stake.
#' @export
apply_betting_strategy = function(our_sim, market_odds, bankroll, 
                                  type = "moneyline", 
                                  method = "kelly", 
                                  last_outcome = "win", 
                                  prev_stake = 10) {
  
  # 1. Get the probability from the simulation
  our_prob = our_sim$win_prob 
  
  # 2. Calculate Stake
  if (method == "kelly") {
    # Ensure this function exists in your market_engine.R
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