# --- R/batch_processor.R ---
#' Batch Process Cricket JSON Data
#'
#' @description
#' Parses ball-by-ball cricket match data in JSON format and converts it into
#' structured match objects containing aggregate statistics such as total runs,
#' run rate, and wicket rate.
#'
#' @usage
#' batch_process_json(file_path)
#'
#' @param file_path Character. Path to the JSON file.
#'
#' @return
#' A list of match objects (one per innings), each containing:
#' \itemize{
#'   \item Team name
#'   \item Runs, balls, wickets
#'   \item Derived features (run rate, wicket rate)
#'   \item Venue information
#' }
#'
#' @details
#' The function traverses nested match data:
#' \itemize{
#'   \item Innings → Overs → Deliveries
#' }
#'
#' For each innings, it computes:
#' \itemize{
#'   \item Total runs scored
#'   \item Total balls faced
#'   \item Total wickets lost
#' }
#'
#' These aggregates are then transformed into standardized match objects using
#' \code{\link{create_match_object}}, which includes derived features such as:
#' \itemize{
#'   \item Run rate (runs per over)
#'   \item Wicket rate (wickets per ball)
#' }
#'
#' @importFrom jsonlite fromJSON
#' @keywords internal
batch_process_json = function(file_path) {
  # simplifyVector = FALSE is CRITICAL for this nested structure
  data = fromJSON(file_path, simplifyVector = FALSE)
  
  venue = data$info$venue %||% "Unknown"
  match_innings_data = list()
  
  # Loop through each innings (usually 2 per match)
  for (ing in data$innings) {
    team_name = ing$team
    total_runs = 0
    total_wickets = 0
    total_balls = 0
    
    # Nested Loop: Overs -> Deliveries
    for (ovr in ing$overs) {
      for (dlv in ovr$deliveries) {
        # 1. Sum up the runs
        total_runs = total_runs + (dlv$runs$total %||% 0)
        
        # 2. Count the ball (ignoring wides/no-balls for RR calculation is optional, 
        # but usually we count all deliveries that contribute to the score)
        total_balls = total_balls + 1
        
        # 3. Check for wickets
        if (!is.null(dlv$wickets)) {
          total_wickets = total_wickets + length(dlv$wickets)
        }
      }
    }
    
    # Only save if the innings actually happened
    if (total_balls > 0) {
      match_innings_data[[length(match_innings_data) + 1]] = create_match_object(
        name = team_name,
        runs = total_runs,
        balls = total_balls,
        wickets = total_wickets,
        venue = venue
      )
    }
  }
  
  return(match_innings_data)
}
