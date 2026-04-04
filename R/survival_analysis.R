# --- R/survival_analysis.R ---

#' Estimate Bankroll Survival Probability
#' 
#' @description
#' Runs multiple bankroll simulations to estimate the probability of survival
#' (i.e., not hitting the stop-loss threshold).
#'
#' @usage
#' simulate_bankroll_mc(match_data, params = NULL, n_sim = 1000,
#'                      initial_bankroll = 1000,
#'                      strategy_method = "kelly",
#'                      bet_type = "moneyline",
#'                      threshold = 160.5,
#'                      spread = -5.5,
#'                      stop_loss_pct = 0.5)
#' 
#' @param match_data List of matches
#' @param params A list containing the 'intercept' and 'weights' from the trained model.
#' If NULL (default), a pretrained model included in the package is used.
#' Advanced users may supply their own trained parameters for custom modeling.
#' @param n_sim Number of simulation runs (default 1000)
#' @param initial_bankroll Starting bankroll
#' @param strategy_method Betting strategy ("kelly", "flat", "martingale")
#' @param bet_type Type of bet ("moneyline", "over_under", "spread")
#' @param threshold Threshold for over/under bets
#' @param spread Spread value for handicap bets
#' @param stop_loss_pct Stop-loss threshold
#'
#' @return
#' A list containing:
#' \itemize{
#'   \item survival_probability: Probability of avoiding stop-loss
#'   \item final_bankrolls: Vector of final bankroll values
#' }
#'
#' @details
#' Each simulation generates a full bankroll trajectory using
#' \code{\link{simulate_bankroll}} and records the final outcome.
#'
#' This function is useful for:
#' \itemize{
#'   \item Evaluating risk of ruin
#'   \item Comparing betting strategies
#'   \item Understanding drawdown behavior
#' }
#'
#' See \code{\link{betting_concepts}} for interpretation of strategies.
#'
#' @examples
#' # Sample match data
#' match_data <- readRDS(system.file("extdata", "sample_match_data.rds", package = "BetStrategyR"))
#'
#' # Run Monte Carlo bankroll simulation
#' mc_result <- simulate_bankroll_mc(
#'   match_data = match_data,
#'   params = NULL,   # uses pretrained model
#'   n_sim = 30
#' )
#'
#' mc_result$survival_probability
#' 
#' @seealso
#' \code{\link{simulate_bankroll}},
#' \code{\link{plot_bankroll_distribution}},
#' \code{\link{betting_concepts}}
#'
#'
#' @importFrom utils tail
#' 
#' @export
simulate_bankroll_mc = function(match_data, params = NULL,
                                n_sim = 1000,
                                initial_bankroll = 1000,
                                strategy_method = "kelly",
                                bet_type = "moneyline",
                                threshold = 160.5,
                                spread = -5.5,
                                stop_loss_pct = 0.5) {
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
  
  final_values = numeric(n_sim)
  ruined = 0
  
  for (i in 1:n_sim) {
    
    path = simulate_bankroll(
      match_data = match_data,
      params = params,
      initial_bankroll = initial_bankroll,
      strategy_method = strategy_method,
      bet_type = bet_type,
      threshold = threshold,
      spread = spread,
      stop_loss_pct = stop_loss_pct
    )
    
    final_val = tail(path, 1)
    final_values[i] = final_val
    
    if (final_val <= initial_bankroll * (1 - stop_loss_pct)) {
      ruined = ruined + 1
    }
  }
  
  survival_prob = 1 - (ruined / n_sim)
  
  return(list(
    survival_probability = survival_prob,
    final_bankrolls = final_values
  ))
}

#' Plot Final Bankroll Distribution
#'
#' @description
#' Visualizes the distribution of final bankroll values from Monte Carlo simulations.
#'
#' @usage
#' plot_bankroll_distribution(mc_result)
#'
#' @param mc_result Output from \code{\link{simulate_bankroll_mc}}.
#'
#' @return
#' Produces a histogram showing the distribution of ending bankroll values.
#'
#' @details
#' This visualization helps assess:
#' \itemize{
#'   \item Risk of ruin (mass near zero)
#'   \item Variability of outcomes
#'   \item Tail risk and extreme scenarios
#' }
#' 
#' @examples
#' # Sample match data
#' match_data <- readRDS(system.file("extdata", "sample_match_data.rds", package = "BetStrategyR"))
#'
#' # Run Monte Carlo bankroll simulation
#' mc_result <- simulate_bankroll_mc(
#'   match_data = match_data,
#'   params = NULL,   # uses pretrained model
#'   n_sim = 30
#' )
#'
#' # Plot distribution of final bankrolls
#' plot_bankroll_distribution(mc_result)
#' 
#' @seealso
#' \code{\link{simulate_bankroll_mc}}
#'
#' @importFrom graphics par hist
#' 
#' @export
plot_bankroll_distribution = function(mc_result) {
  par(mar=c(4,4,2,1))
  hist(mc_result$final_bankrolls,
       main = "Final Bankroll Distribution",
       xlab = "Final Bankroll")
}
