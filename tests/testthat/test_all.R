# 1. Source all components
source("R/data_prep.R")
source("R/simulation_engine.R")
source("R/market_engine.R")
source("R/strategy_logic.R")
source("R/model_trainer.R")
source("R/user_interface_logic.R")

cat("--- ALL ENGINES LOADED ---\n")

# 2. Test User Input Logic (The get_prediction function)
# Simulation of a high-strength vs low-strength team
tryCatch({
  test_run = get_prediction(
    team_a_stats = c(9.5, 0.04, 0.65), # RR=9.5, WR=0.04, Win%=65%
    team_b_stats = c(7.2, 0.08, 0.35), # RR=7.2, WR=0.08, Win%=35%
    market_odds = 1.90
  )
  cat("\nSUCCESS: User prediction logic is conformable and running!\n")
}, error = function(e) {
  cat("\nFAILURE in Prediction Logic: ", e$message, "\n")
})

