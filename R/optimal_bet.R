#' Optimal Bet Size using Kelly Criterion
#'
#' Calculates the optimal bet size based on bankroll,
#' probability of winning, and bookmaker odds.
#'
#' @param bankroll numeric, current bankroll
#' @param probability numeric, probability of winning
#' @param odds numeric, decimal odds
#'
#' @return numeric bet size
#'
#' @examples
#' optimal_bet(1000, 0.55, 2)
#'
#' @export

optimal_bet <- function(bankroll, probability, odds) {
  
  if(probability <= 0 || probability >= 1){
    stop("Probability must be between 0 and 1")
  }
  
  b <- odds - 1
  q <- 1 - probability
  
  fraction <- (b * probability - q) / b
  
  bet_size <- bankroll * fraction
  
  return(bet_size)
}