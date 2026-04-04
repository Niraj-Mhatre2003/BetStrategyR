# --- R/betting_concepts.R ---

#' Betting Concepts and Strategy Framework
#'
#' @description
#' This documentation provides an overview of the core betting concepts used in
#' the package, including supported bet types and staking strategies.
#'
#' These concepts form the foundation for decision-making in functions such as
#' \code{\link{get_prediction}}, \code{\link{invest_advisor}}, \code{\link{apply_betting_strategy}}, 
#' \code{\link{simulate_bankroll}} and \code{\link{simulate_bankroll_mc}}.
#'
#' @section Bet Types:
#'
#' \strong{Moneyline}
#' \itemize{
#'   \item The simplest form of betting: predict which team wins.
#'   \item A bet is successful if the selected team wins the match.
#'   \item Probability modeled as:
#'   \deqn{P(\text{win})}
#' }
#'
#' \strong{Over/Under}
#' \itemize{
#'   \item Predict whether the total score exceeds a threshold.
#'   \item A bet wins if:
#'   \deqn{score_A + score_B > threshold}
#'   \item Thresholds are typically fractional (e.g., 160.5) to avoid ties.
#' }
#'
#' \strong{Spread (Handicap)}
#' \itemize{
#'   \item Adjusts the score of a team to balance uneven matchups.
#'   \item A bet wins if:
#'   \deqn{score_A + spread > score_B}
#'   \item Negative spread: team must win by a margin.
#'   \item Positive spread: team can lose narrowly and still cover.
#' }
#'
#' @section Staking Strategies:
#'
#' \strong{Kelly Criterion}
#' \itemize{
#'   \item A mathematically optimal staking strategy that maximizes long-term
#'   bankroll growth.
#'   \item Bet fraction:
#'   \deqn{f^* = \frac{bp - (1 - p)}{b}}
#'   \item Only bets when there is positive edge.
#'   \item Often used in fractional form (e.g., 0.5 × Kelly) to reduce risk.
#' }
#'
#' \strong{Flat Betting}
#' \itemize{
#'   \item A constant stake is placed on every bet.
#'   \item Simple and low-risk compared to Kelly.
#'   \item Does not adapt to edge or confidence.
#' }
#'
#' \strong{Martingale}
#' \itemize{
#'   \item Doubles the stake after each loss.
#'   \item Recovers previous losses upon a win.
#'   \item High risk due to exponential growth of stake size.
#' }
#'
#' @details
#' Bet types define \emph{what} outcome is being predicted, while staking
#' strategies define \emph{how much} to wager.
#'
#' Combining a strong predictive model with disciplined staking is critical
#' for long-term profitability.
#'
#' @name betting_concepts
NULL
