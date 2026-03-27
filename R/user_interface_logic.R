# --- R/user_interface_logic.R ---
# --- R/user_interface_logic.R ---

#' Get Prediction and Betting Advice
#' 
#' High-level interface that loads the pretrained model, processes team statistics, 
#' and generates a strategic betting report using the Simulation and Market engines.
#' 
#' @param team_a_stats Numeric vector of raw stats for Team A (RR, WR, VenueIdx).
#' @param team_b_stats Numeric vector of raw stats for Team B (RR, WR, VenueIdx).
#' @param market_odds The decimal odds offered for Team A (Default 1.90).
#' @param bankroll Total betting capital available (Default 1000).
#' @return Invisibly returns the detailed simulation results.
#' @export
# Ensure the strategy and engine are loaded
source("R/batch_processor.R") # This is where your invest_advisor currently lives
source("R/simulation_engine.R")
source("R/market_engine.R")

get_prediction = function(team_a_stats, team_b_stats, market_odds = 1.90, bankroll = 1000) {
  params = readRDS("pretrained_bet_model.rds")
  
  # Inject metadata if missing (Crucial for your MSc project)
  if(is.null(params$scale_mean)) params$scale_mean = c(8.5, 0.05, 1.0)
  if(is.null(params$scale_std))  params$scale_std  = c(1.2, 0.01, 0.1)
  
  # Hand off to the advisor
  results = invest_advisor(
    team_a_raw = team_a_stats, 
    team_b_raw = team_b_stats, 
    market_odds_a = market_odds, 
    bankroll = bankroll, 
    params = params
  )
  
  return(invisible(results))
}


