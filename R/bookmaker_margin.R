#' Bookmaker Margin
#'
#' Calculates bookmaker overround from odds.
#'
#' @param odds_vector numeric vector of decimal odds
#'
#' @return bookmaker margin
#'
#' @examples
#' bookmaker_margin(c(1.9, 1.9))
#'
#' @export

bookmaker_margin <- function(odds_vector){
  
  margin <- sum(1 / odds_vector) - 1
  
  return(margin)
  
}

