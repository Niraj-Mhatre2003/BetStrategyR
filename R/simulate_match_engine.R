# --- R/simulation_engine.R ---
#' Simulate T20 Cricket Match
#' 
#' @description
#' Performs a Monte Carlo simulation of a T20 match between two teams based on 
#' Poisson-distributed run scoring and Binomial-distributed wicket events.
#' 
#' @usage
#' simulate_match(team_a_stats, team_b_stats, params = NULL,
#'                overs = 20, iterations = 10000)
#'
#' @param team_a_stats Numeric vector of scaled stats for Team 1 (RR, WR, VenueIdx).
#' @param team_b_stats Numeric vector of scaled stats for Team 2 (RR, WR, VenueIdx).
#' @param params A list containing the 'intercept' and 'weights' from the trained model.
#' If NULL (default), a pretrained model included in the package is used.
#' Advanced users may supply their own trained parameters for custom modeling.
#' @param overs Number of overs per innings (default 20).
#' @param iterations Number of simulation trials (default 10,000 for stability).
#' 
#' @importFrom stats rbinom rpois
#' 
#' @return A list containing:
#'   \item{win_prob}{Probability that Team 1 wins (0-1).}
#'   \item{team_a_scores}{Numeric vector of simulated scores for Team 1.}
#'   \item{team_b_scores}{Numeric vector of simulated scores for Team 2.}
#' 
#' @details
#' Each simulation iteration:
#' \enumerate{
#'   \item Predicts expected runs using model parameters.
#'   \item Simulates wickets using a Binomial distribution.
#'   \item Applies a penalty to expected runs based on wickets lost.
#'   \item Simulates final scores using a Poisson distribution.
#'   \item Compares scores to determine match outcome.
#' }
#'
#' The win probability is estimated as:
#' \deqn{P(win) = \frac{\text{wins + 0.5 * ties}}{\text{iterations}}}
#' 
#' @examples
#' sim <- simulate_match(
#'   team_a_stats = c(8.5, 0.05, 1.1),
#'   team_b_stats = c(7.8, 0.06, 0.9),
#'   params = NULL
#' )
#'
#' # Win probability
#' sim$win_prob
#'
#' # Simulated score distributions
#' head(sim$team_a_scores)
#' head(sim$team_b_scores)
#'
#' # Histogram of Team 1 scores
#' hist(sim$team_a_scores,
#'      main = "Team 1 Score Distribution",
#'      xlab = "Runs")
#'
#' @seealso
#' \code{\link{simulate_bankroll}},
#' \code{\link{apply_betting_strategy}}
#' 
#' @export
simulate_match = function(team_a_stats, team_b_stats, params = NULL, overs = 20, iterations = 10000) {
  
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
  
  exp_total1 = predict_expected_runs(params, team_a_stats)
  exp_total2 = predict_expected_runs(params, team_b_stats)
  
  scores_a = numeric(iterations)
  scores_b = numeric(iterations)
  team1_wins = 0
  
  for (i in 1:iterations) {
    # probabilities between 0.01 and 0.99
    # This prevents rbinom from producing NAs when stats are extreme
    raw_p1 = 0.3 + (1 - team_a_stats[2]) * 0.2 
    raw_p2 = 0.3 + (1 - team_b_stats[2]) * 0.2
    
    p1 = max(0.01, min(0.99, raw_p1))
    p2 = max(0.01, min(0.99, raw_p2))
    
    wickets1 = rbinom(1, 10, p1)
    wickets2 = rbinom(1, 10, p2)
    
    # 3. Apply Penalty
    adj_total1 = exp_total1 * (1 - (wickets1 * 0.05))
    adj_total2 = exp_total2 * (1 - (wickets2 * 0.05))
    
    # Ensures Poisson lambda is at least 0.01.
    # rpois(1, 0) or negative numbers produce NAs
    sim_score1 = rpois(1, max(0.01, adj_total1))
    sim_score2 = rpois(1, max(0.01, adj_total2))
    
    scores_a[i] = sim_score1
    scores_b[i] = sim_score2
    
    # 5. Comparison 
    if (sim_score1 > sim_score2) {
      team1_wins = team1_wins + 1
    } else if (sim_score1 == sim_score2) {
      team1_wins = team1_wins + 0.5
    }
  }
  
  return(list(
    win_prob = team1_wins / iterations,
    team_a_scores = scores_a,
    team_b_scores = scores_b
  ))
}
