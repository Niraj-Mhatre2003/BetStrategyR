# --- R/simulate_bankroll_engine.R ---

#' Simulate Bankroll Performance (Sequential Betting Simulation)
#'
#' @description
#' Simulates the evolution of a betting bankroll over a sequence of matches
#' using a specified betting strategy and market type. The function applies
#' model-based probabilities and updates the bankroll after each bet while
#' enforcing a stop-loss rule.
#'
#' @usage
#' simulate_bankroll(match_data, params = NULL, initial_bankroll = 1000,
#'                   strategy_method = "kelly", bet_type = "moneyline",
#'                   threshold = 160.5, spread = -5.5,
#'                   stop_loss_pct = 0.50)
#'
#' @param match_data List of match objects. Each element must contain:
#' \itemize{
#'   \item team_a_stats
#'   \item team_b_stats
#'   \item market_odds (optional, default = 1.9)
#' }
#' @param params A list containing the 'intercept' and 'weights' from the trained model.
#' If NULL (default), a pretrained model included in the package is used.
#' Advanced users may supply their own trained parameters for custom modeling.
#' @param initial_bankroll Numeric. Starting capital.
#' @param strategy_method Character. One of "kelly", "flat", or "martingale".
#' @param bet_type Character. One of "moneyline", "over_under", or "spread".
#' @param threshold Numeric. Threshold for over/under bets.
#' @param spread Numeric. Handicap value for spread bets.
#' @param stop_loss_pct Numeric. Fraction of bankroll loss triggering early stop.
#'
#' @return
#' Numeric vector representing bankroll value after each match.
#' Length is \code{length(match_data) + 1}.
#'
#' @details
#' The simulation stops early if the bankroll falls below the stop-loss level.
#' Strategy decisions are made using \code{\link{apply_betting_strategy}}.
#'
#' @seealso
#' \code{\link{simulate_bankroll_mc}},
#' \code{\link{apply_betting_strategy}},
#' \code{\link{simulate_match}}
#' 
#' @examples
#' # Sample match dataset
#' match_data <- readRDS(system.file("extdata", "sample_match_data.rds", package = "BetStrategyR"))
#'
#' # Run bankroll simulation
#' path <- simulate_bankroll(match_data)
#'
#' # View results
#' path
#' 
#' @export
simulate_bankroll = function(match_data, params = NULL, initial_bankroll = 1000, 
                             strategy_method = "kelly", bet_type = "moneyline",
                             threshold = 160.5,
                             spread = -5.5,
                             stop_loss_pct = 0.50) { # 0.50 means stop at 50% loss
  #for using pretrained model-parameters
  model_path = system.file("extdata", "pretrained_bet_model.rds", package = "BetStrategyR")
  if (model_path == "") {
    stop("Model file not found in package.")
  }
  model_params = readRDS(model_path)
  if (is.null(params)) {
    params <- model_params
  }
  if(is.null(params$scale_mean)) params$scale_mean = c(8.5, 0.05, 1.0)
  if(is.null(params$scale_std))  params$scale_std  = c(1.2, 0.01, 0.1)
  
  n = length(match_data)
  bankroll_history = numeric(n + 1)
  bankroll_history[1] = initial_bankroll
  
  current_bal = initial_bankroll
  stop_loss_value = initial_bankroll * (1 - stop_loss_pct)
  
  last_outcome = "win"
  prev_stake = 10
  
  message(sprintf("\nStarting %s Simulation | Strategy: %s | Stop-Loss: $%.2f\n", 
              toupper(bet_type), toupper(strategy_method), stop_loss_value))
  
  for (i in 1:n) {
    match = match_data[[i]]
    
    # 1. Stop-Loss Check
    if (current_bal <= stop_loss_value) {
      message(sprintf("!!! STOP-LOSS TRIGGERED at match %d !!!\n", i))
      message(sprintf("Current Balance ($%.2f) reached limit ($%.2f)\n", current_bal, stop_loss_value))
      # Fill remaining history with the current balance and exit
      bankroll_history[(i+1):(n+1)] = current_bal
      break
    }
    
    # 2. Run Simulation
    sim = simulate_match(match$team_a_stats, match$team_b_stats, params)
    
    # 3. Get Strategy Advice
    odds = match$market_odds %||% 1.90
    validate_odds(odds)
    strat = apply_betting_strategy(sim, odds, current_bal, 
                                   type = bet_type, 
                                   method = strategy_method, 
                                   last_outcome = last_outcome, 
                                   prev_stake = prev_stake,
                                   threshold = threshold,
                                   spread = spread)
    
    # 4. Update Bankroll
    outcome = ifelse(runif(1) < sim$win_prob, "Team A", "Team B")
    
    if (outcome == "Team A") {
      current_bal = current_bal + (strat$stake * (odds - 1))
      last_outcome = "win"
    } else {
      current_bal = current_bal - strat$stake
      last_outcome = "loss"
    }
    
    bankroll_history[i+1] = current_bal
    prev_stake = strat$stake
    
    if (i %% 500 == 0) message("Processed", i, "matches...\n")
  }
  
  return(bankroll_history)
}

#' Plot Bankroll Trajectory
#'
#' @description
#' Visualizes the evolution of bankroll over a sequence of bets.
#' Each point represents the bankroll after a match.
#'
#' @usage
#' plot_bankroll_path(path)
#'
#' @param path Numeric vector returned by \code{\link{simulate_bankroll}}.
#'
#' @return
#' Produces a line plot of bankroll over time.
#'
#' @details
#' This plot is useful for evaluating:
#' \itemize{
#'   \item Long-term profitability (upward/downward trend)
#'   \item Volatility of returns (large fluctuations vs smooth growth)
#'   \item Drawdowns (periods of sustained loss)
#'   \item Recovery dynamics after losses
#' }
#'
#' A steadily increasing trajectory indicates a profitable strategy,
#' while large swings suggest higher risk.
#'
#' @seealso
#' \code{\link{simulate_bankroll}},
#' \code{\link{simulate_bankroll_mc}}
#' \code{\link{betting_concepts}}
#'
#' @examples
#' # Sample match dataset
#' match_data <- readRDS(system.file("extdata", "sample_match_data.rds", package = "BetStrategyR"))
#'
#' # Run bankroll simulation
#' path <- simulate_bankroll(match_data)
#' plot_bankroll_path(path)
#' 
#' @importFrom graphics par
#' 
#' @export
plot_bankroll_path = function(path) {
  par(mar = c(4,4,2,1))
  plot(path,
       type = "l",
       xlab = "Bet Number",
       ylab = "Bankroll",
       main = "Bankroll Trajectory",
       lwd = 2,
       col = "red")
}
