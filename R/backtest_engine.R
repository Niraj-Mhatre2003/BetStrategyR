# --- R/backtest_engine.R ---

#' Run Backtest on Historical Dataset
#' @param match_data List of standardized match objects
#' @param params Trained model weights and scaling factors
#' @param initial_bankroll Starting cash (default 1000)
#' @param strategy_method "kelly", "flat", or "martingale"
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
    # (Assuming match contains team_a_stats and team_b_stats)
    sim = simulate_match(match$team_a_scaled, match$team_b_scaled, params)
    
    # 2. Get Strategy Advice
    # market_odds should be in your historical data; if not, use a default 1.9
    odds = match$market_odds %||% 1.90 
    strat = apply_betting_strategy(sim, odds, current_bal, method = strategy_method, 
                                   last_outcome = last_outcome, prev_stake = prev_stake)
    
    # 3. Update Bankroll based on Actual Result
    # If Team A actually won in the real match data:
    if (match$actual_winner == "Team A") {
      current_bal = current_bal + (strat$stake * (odds - 1))
      last_outcome = "win"
    } else {
      current_bal = current_bal - strat$stake
      last_outcome = "loss"
    }
    
    bankroll_history[i+1] = current_bal
    prev_stake = strat$stake
  }
  
  return(bankroll_history)
}
# --- Data Preparation for Backtesting ---

# 1. Initialize the list
my_matches = list()

# 2. Get all your JSON file paths (assuming they are in a folder named 'data/json')
# If your files are in a different folder, change the path here
json_files = list.files(path = "data/json", pattern = "*.json", full_names = TRUE)

# 3. Process a subset (start with 10 matches to test)
for (i in 1:10) {
  raw_data = batch_process_json(json_files[i])
  
  # For the backtester, we need a single match object 
  # with both teams and the actual result
  # We will structure it to match what simulate_bankroll expects
  
  # Note: This logic assumes raw_data[[1]] is Team A and raw_data[[2]] is Team B
  match_obj = list(
    team_a_scaled = (c(raw_data[[1]]$rr, raw_data[[1]]$wr, 1.0) - t20_model_params$scale_mean) / t20_model_params$scale_std,
    team_b_scaled = (c(raw_data[[2]]$rr, raw_data[[2]]$wr, 1.0) - t20_model_params$scale_mean) / t20_model_params$scale_std,
    market_odds = 1.90, # Default odds if not in JSON
    actual_winner = if(raw_data[[1]]$runs > raw_data[[2]]$runs) "Team A" else "Team B"
  )
  
  my_matches[[i]] = match_obj
}

cat("Success: 'my_matches' created with", length(my_matches), "historical games.\n")
