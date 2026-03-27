# =============================================================
# BETSIMR STANDALONE BACKTEST SUITE
# =============================================================

# --- FIXED SOURCE BLOCK ---
files_to_source = c("R/data_prep.R", "R/batch_processor.R", 
                    "R/simulation_engine.R", "R/market_engine.R", 
                    "R/model_trainer.R", "R/backtest_engine.R","R/strategy_logic.R")

for (f in files_to_source) {
  if (file.exists(f) && file.info(f)$size > 0) {
    source(f)
    cat("Successfully sourced:", f, "\n")
  } else {
    warning(paste("Skipping empty or missing file:", f))
  }
}

# 2. LOAD PRETRAINED MODEL & METADATA
# Adjusting path to where your file sits (root directory)
if (!file.exists("pretrained_bet_model.rds")) {
  stop("Error: pretrained_bet_model.rds not found in current directory!")
}

params = readRDS("pretrained_bet_model.rds")
params$scale_mean = c(8.5, 0.05, 1.0) 
params$scale_std  = c(1.2, 0.01, 0.1)

# 3. DATA EXTRACTION
json_folder = "data-raw/T20_data/"
files = list.files(json_folder, pattern = "\\.json$", full.names = TRUE)

cat("Found", length(files), "matches. Starting extraction...\n")

processed_matches = list()
for (i in 1:length(files)) {
  # Extract data from JSON
  raw_match = batch_process_json(files[i])
  
  # Validation: Ensure we have two complete innings
  if (length(raw_match) == 2) {
    processed_matches[[length(processed_matches) + 1]] = list(
      team_a_scaled = (c(raw_match[[1]]$rr, raw_match[[1]]$wr, 1.0) - params$scale_mean) / params$scale_std,
      team_b_scaled = (c(raw_match[[2]]$rr, raw_match[[2]]$wr, 1.0) - params$scale_mean) / params$scale_std,
      market_odds = 1.90, # Standard even-money assumption for historical testing
      actual_winner = if(raw_match[[1]]$runs > raw_match[[2]]$runs) "Team A" else "Team B"
    )
  }
  
  if (i %% 500 == 0) cat("Processed", i, "files...\n")
}

cat("Extraction Complete. Matches for backtest:", length(processed_matches), "\n")

#section 4

# SETTINGS
MY_STRATEGY = "kelly"
MY_BET_TYPE = "moneyline"
STOP_LOSS = 0.40 # Stops the backtest if you lose 40% of your initial $1000

cat("\nExecuting Strategy Engine...\n")

final_history = simulate_bankroll(processed_matches, params, 
                                  initial_bankroll = 1000, 
                                  strategy_method = MY_STRATEGY,
                                  bet_type = MY_BET_TYPE,
                                  stop_loss_pct = STOP_LOSS)

# Update the plot to show the Stop-Loss line
plot(final_history, type = "l", col = "blue", lwd = 2,
     main = paste("Backtest:", toupper(MY_STRATEGY), "Strategy"),
     xlab = "Match Number", ylab = "Bankroll ($)")
abline(h = 1000 * (1 - STOP_LOSS), col = "orange", lty = 3, lwd = 2) # Stop-Loss Line
legend("topleft", legend=c("Bankroll", "Stop-Loss"), col=c("blue", "orange"), lty=c(1,3))

cat(sprintf("Starting Bankroll: $1000.00\n"))
cat(sprintf("Ending Bankroll:   $%.2f\n", final_bal))
cat(sprintf("Total Return:      %.2f%%\n", roi))
cat(sprintf("Max Capital Dip:   $%.2f\n", 1000 - min(final_history)))

# =============================================================