# --- R/backtest_engine.R ---

simulate_bankroll = function(match_data, params, initial_bankroll = 1000, 
                             strategy_method = "kelly", bet_type = "moneyline",
                             stop_loss_pct = 0.50) { # 0.50 means stop at 50% loss
  
  n = length(match_data)
  bankroll_history = numeric(n + 1)
  bankroll_history[1] = initial_bankroll
  
  current_bal = initial_bankroll
  stop_loss_value = initial_bankroll * (1 - stop_loss_pct)
  
  last_outcome = "win"
  prev_stake = 10
  
  cat(sprintf("\nStarting %s Backtest | Strategy: %s | Stop-Loss: $%.2f\n", 
              toupper(bet_type), toupper(strategy_method), stop_loss_value))
  
  for (i in 1:n) {
    match = match_data[[i]]
    
    # 1. Stop-Loss Check
    if (current_bal <= stop_loss_value) {
      cat(sprintf("!!! STOP-LOSS TRIGGERED at match %d !!!\n", i))
      cat(sprintf("Current Balance ($%.2f) reached limit ($%.2f)\n", current_bal, stop_loss_value))
      # Fill remaining history with the current balance and exit
      bankroll_history[(i+1):(n+1)] = current_bal
      break
    }
    
    # 2. Run Simulation
    sim = simulate_match(match$team_a_scaled, match$team_b_scaled, params)
    
    # 3. Get Strategy Advice
    odds = match$market_odds %||% 1.90 
    strat = apply_betting_strategy(sim, odds, current_bal, 
                                   type = bet_type, 
                                   method = strategy_method, 
                                   last_outcome = last_outcome, 
                                   prev_stake = prev_stake)
    
    # 4. Update Bankroll
    if (match$actual_winner == "Team A") {
      current_bal = current_bal + (strat$stake * (odds - 1))
      last_outcome = "win"
    } else {
      current_bal = current_bal - strat$stake
      last_outcome = "loss"
    }
    
    bankroll_history[i+1] = current_bal
    prev_stake = strat$stake
    
    if (i %% 500 == 0) cat("Processed", i, "matches...\n")
  }
  
  return(bankroll_history)
}