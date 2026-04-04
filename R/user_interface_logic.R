# --- R/user_interface_logic.R ---

#' Get Prediction and Betting Advice
#' 
#' @description
#' Generates a full strategic betting report for a match between two teams. 
#' This function loads a pretrained model, processes team statistics, simulates 
#' match outcomes, and provides recommended stakes according to selected betting 
#' strategies.
#' 
#' @usage
#' get_prediction(team_a_stats, team_b_stats,
#'                market_odds = 1.90, bankroll = 1000,
#'                bet_type = "moneyline", threshold = 160.5,
#'                spread = -5.5, strategy_method = "kelly")
#' 
#' @param team_a_stats Numeric vector of raw statistics for Team A: 
#'   \itemize{
#'     \item Run Rate (RR)
#'     \item Wicket Rate (WR)
#'     \item Venue Index (VenueIdx)
#'   }
#' @param team_b_stats Numeric vector of raw statistics for Team B (same structure as Team A).
#' @param market_odds Numeric. Decimal odds offered for Team A to win (must be > 1). (default: 1.90)
#' @param bankroll Numeric. Total available betting capital. (default: 1000)
#' @param bet_type Type of bet:
#'   \itemize{
#'     \item "moneyline": bet on match winner
#'     \item "over_under": bet on total runs scored in the match
#'     \item "spread": bet on margin of victory with handicap
#'   } 
#'   (default: "moneyline")
#' @param threshold Numeric. Run threshold used for over_under bets. (default: 160.5)
#' @param spread Numeric. Point spread applied for spread bets. (default: -5.5)
#' @param strategy_method Staking strategy to use:
#'   \itemize{
#'     \item "kelly": optimal stake using Kelly Criterion
#'     \item "flat": fixed fraction of bankroll
#'     \item "martingale": doubling strategy after losses
#'   }
#'   (default: "kelly")
#'
#' @return Invisibly returns the detailed simulation results.
#' 
#' @details
#' Loads a pretrained model and delegates analysis to \code{\link{invest_advisor}}.
#' See \code{\link{betting_concepts}} for a detailed explanation of supported
#' bet types and staking strategies.
#' 
#' @seealso
#' \code{\link{invest_advisor}},
#' \code{\link{simulate_match}},
#' \code{\link{apply_betting_strategy}},
#' \code{\link{betting_concepts}}
#' 
#' @examples
#' # Default: Moneyline betting with Kelly strategy
#' get_prediction(
#'   team_a_stats = c(8.5, 0.05, 1.1),
#'   team_b_stats = c(7.8, 0.06, 0.9)
#' )
#'
#' # Over/Under betting with Flat strategy
#' get_prediction(
#'   team_a_stats = c(9.0, 0.04, 1.2),
#'   team_b_stats = c(8.2, 0.05, 1.0),
#'   bet_type = "over_under",
#'   threshold = 165.5,
#'   strategy_method = "flat"
#' )
#'
#' # Spread betting with Martingale strategy
#' get_prediction(
#'   team_a_stats = c(8.8, 0.045, 1.1),
#'   team_b_stats = c(7.5, 0.06, 0.95),
#'   bet_type = "spread",
#'   spread = -6.5,
#'   strategy_method = "martingale",
#'   bankroll = 1500
#' )
#' 
#' @export
get_prediction = function(team_a_stats, team_b_stats, market_odds = 1.90, bankroll = 1000, bet_type = "moneyline", threshold = 160.5, spread = -5.5, strategy_method = "kelly") {
  model_path = system.file("extdata", "pretrained_bet_model.rds", package = "BetStrategyR")
  
  if (model_path == "") {
    stop("Model file not found in package.")
  }
  
  params = readRDS(model_path)
  
  if(is.null(params$scale_mean)) params$scale_mean = c(8.5, 0.05, 1.0)
  if(is.null(params$scale_std))  params$scale_std  = c(1.2, 0.01, 0.1)
  
  # Hand off to the advisor
  results = invest_advisor(
    team_a_raw = team_a_stats, 
    team_b_raw = team_b_stats, 
    market_odds_a = market_odds, 
    bankroll = bankroll, 
    params = params,
    bet_type = bet_type,
    threshold = threshold,
    spread = spread,
    strategy_method = strategy_method
  )
  
  return(invisible(results))
}


