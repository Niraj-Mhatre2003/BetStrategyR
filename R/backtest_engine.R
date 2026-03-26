# --- R/backtest_engine.R ---

simulate_bankroll = function(match_data, params, initial_bankroll = 1000, strategy_method = "kelly") {
  
  n = length(match_data)
  bankroll_history = numeric(n + 1)
  bankroll_history[1] = initial_bankroll
  
  current_bal = initial_bankroll
  last_outcome = "win"
  prev_stake = 10
  
  cat(sprintf("\nStarting Backtest: %s Strategy...\n", toupper(strategy_method)))
  
  for (i in 1:n) {
    match = match_data[[i]]
    
    # 1. Get Model Prediction
    sim = simulate_match(match$team_a_scaled, match$team_b_scaled, params)
    
    # 2. Get Strategy Advice
    odds = match$market_odds %||% 1.90 
    strat = apply_betting_strategy(sim, odds, current_bal, method = strategy_method, 
                                   last_outcome = last_outcome, prev_stake = prev_stake)
    
    # 3. Update Bankroll based on Actual Result
    if (match$actual_winner == "Team A") {
      current_bal = current_bal + (strat$stake * (odds - 1))
      last_outcome = "win"
    } else {
      current_bal = current_bal - strat$stake
      last_outcome = "loss"
    }
    
    bankroll_history[i+1] = current_bal
    prev_stake = strat$stake
    
    # Progress tracker for large datasets
    if (i %% 100 == 0) cat("Processed", i, "matches...\n")
  }
  
  return(bankroll_history)
}

# --- Data Preparation Script ---

my_matches = list()
# Note: Ensure path is correct for your local setup
json_files = list.files(path = "data/json", pattern = "\\.json$", full.names = TRUE)

# Helper to scale consistently
scale_vec = function(rr, wr, v_idx, params) {
  raw = c(rr, wr, v_idx)
  return((raw - params$scale_mean) / params$scale_std)
}

count = 0
for (i in 1:length(json_files)) {
  raw_data = batch_process_json(json_files[i])
  
  # Safety check: Match must have two innings
  if (length(raw_data) < 2) next
  
  count = count + 1
  
  # Structure the match for the simulator
  my_matches[[count]] = list(
    team_a_scaled = scale_vec(raw_data[[1]]$rr, raw_data[[1]]$wr, 1.0, t20_model_params),
    team_b_scaled = scale_vec(raw_data[[2]]$rr, raw_data[[2]]$wr, 1.0, t20_model_params),
    market_odds = 1.90, 
    actual_winner = if(raw_data[[1]]$runs > raw_data[[2]]$runs) "Team A" else "Team B"
  )
  
  # Stop at 10 for initial test, or remove this to run all 3100
  if (count == 10) break 
}

cat("Success: 'my_matches' created with", length(my_matches), "historical games.\n")