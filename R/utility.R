#' Value Bet Detection
#'
#' Determines whether a bet has positive expected value.
#'
#' @param probability numeric probability estimate
#' @param odds decimal bookmaker odds
#'
#' @return logical TRUE or FALSE
#'
#' @examples
#' value_bet(0.55, 2.1)
#'
#' @export

value_bet <- function(probability, odds){
  
  implied_probability <- 1 / odds
  
  if(probability > implied_probability){
    return(TRUE)
  } else {
    return(FALSE)
  }
  
}