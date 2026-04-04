# --- R/data_prep.R ---

#Defining needed operators---------------------------------------------------------------------------------
#' @keywords internal
`%||%` = function(a, b) if (!is.null(a)) a else b

# VALIDATION ----------------------------------------------------------------------------------

#' Validate Data Structure
#'
#' @description
#' Ensures that a data frame contains all required columns before further processing.
#'
#' @usage
#' validate_data(df, required_cols)
#'
#' @param df Data frame to validate.
#' @param required_cols Character vector of required column names.
#'
#' @return
#' Logical TRUE if validation passes. Otherwise throws an error.
#'
#' @keywords internal
validate_data = function(df, required_cols) {
  missing = required_cols[!(required_cols %in% colnames(df))]
  if (length(missing) > 0) {
    stop(paste("Error: Missing columns:", paste(missing, collapse = ", ")))
  }
  return(TRUE)
}

# logic for >1,if odds = 1.5 on every 1 unit we get 0.5 units so for <1 we actually lose

#' Validate Betting Odds
#'
#' @description
#' Checks that provided decimal odds are valid for betting calculations.
#'
#' @param odds Numeric vector of decimal odds.
#'
#' @return Logical TRUE if validation passes. Otherwise throws an error.
#'
#' @details
#' In decimal odds format:
#' \itemize{
#'   \item Odds > 1 imply a positive return on winning bets
#'   \item Odds = 1 imply no profit (degenerate case)
#'   \item Odds < 1 imply guaranteed loss, which is invalid in standard betting markets
#' }
#'
#' This function enforces that all odds are strictly greater than 1.
#' 
#' @examples
#' validate_odds(c(1.5, 2.0))
#'
#' # Invalid cases
#' \dontrun{validate_odds(c(1.0, 0.9))}
#'
#' @export
validate_odds = function(odds) {
  if (any(odds <= 1)) {
    stop("Error: Decimal odds must be greater than 1.0")
  }
  return(TRUE)
}

#FEATURE EXTRACTION ---------------------------------------------------------------------------

# Standardizes match objects into a clean list
# Use this for both training (JSON) and manual input

#' Create Match Object
#'
#' @description
#' Constructs a standardized match representation with derived features such as
#' run rate and wicket rate.
#'
#' @usage
#' create_match_object(name, runs, balls, wickets, venue = "Unknown", result = NULL)
#'
#' @param name Character. Team name.
#' @param runs Numeric. Total runs scored.
#' @param balls Numeric. Total balls faced.
#' @param wickets Numeric. Total wickets lost.
#' @param venue Character. Match venue.
#' @param result Optional match outcome label.
#'
#' @return
#' A named list containing:
#' \itemize{
#'   \item Raw inputs (runs, balls, wickets)
#'   \item Derived metrics (run rate, wicket rate)
#'   \item Metadata (team name, venue, result)
#' }
#'
#' @details
#' The function computes:
#' \itemize{
#'   \item Run rate (RR): runs per over = \eqn{6 * runs / balls}
#'   \item Wicket rate (WR): wickets per ball
#' }
#'
#' These features are commonly used in predictive modeling and simulation.
#'
#' @keywords internal
create_match_object = function(name, runs, balls, wickets, venue = "Unknown", result = NULL) {
  return(list(
    team_name = name,
    runs = runs,
    balls = balls,
    wickets = wickets,
    rr = (runs / balls) * 6,       # Run Rate
    wr = wickets / balls,          # Wicket Rate
    venue = venue,
    result = result
  ))
}

# VENUE ANALYTICS -----------------------------------------------------------------------------

#' Calculate Venue Scoring Indices
#'
#' @description
#' Computes relative scoring intensity for each venue based on historical match data.
#'
#' @usage
#' calculate_venue_indices(match_list)
#'
#' @param match_list List of match objects.
#'
#' @return
#' Named list mapping each venue to a relative scoring index.
#'
#' @details
#' The venue index is defined as:
#' \deqn{Index = \frac{\text{Average runs at venue}}{\text{Global average runs}}}
#'
#' Interpretation:
#' \itemize{
#'   \item Index > 1 → High-scoring venue
#'   \item Index < 1 → Low-scoring venue
#'   \item Index ≈ 1 → Neutral conditions
#' }
#'
#' These indices can be used as scaling factors in predictive models.
#'
#' @keywords internal
calculate_venue_indices = function(match_list) {
  if (length(match_list) == 0) return(list())
  
  # Ensure we get numeric values
  runs = as.numeric(sapply(match_list, function(x) x$runs %||% 0))
  venues = as.character(sapply(match_list, function(x) x$venue %||% "Unknown"))
  
  global_avg = mean(runs, na.rm = TRUE)
  if (is.na(global_avg) || global_avg == 0) global_avg = 1 # Prevent division by zero
  
  unique_venues = unique(venues)
  indices = list()
  
  for (v in unique_venues) {
    v_avg = mean(runs[venues == v], na.rm = TRUE)
    indices[[v]] = v_avg / global_avg
  }
  return(indices)
}

#TENSOR PREPARATION FOR GRADIENT DESCENT ----------------------------------------------------

#' Prepare Training Data
#'
#' @description
#' Converts a list of match objects into feature matrix and target vector for modeling.
#'
#' @usage
#' prepare_training_tensors(standardized_match_list, venue_indices)
#'
#' @param standardized_match_list List of standardized match objects created using \code{\link{create_match_object}}.
#' @param venue_indices Named list of venue scaling factors from \code{\link{calculate_venue_indices}}.
#' 
#' @return
#' A list containing:
#' \itemize{
#'   \item X: numeric matrix of features (run rate, wicket rate, venue index)
#'   \item Y: numeric vector of target values (runs scored)
#' }
#'
#' @keywords internal
prepare_training_tensors = function(standardized_match_list, venue_indices) {
  
  n = length(standardized_match_list)
  
  # If 0, stop and explain why
  if (n == 0) {
    stop("ERROR: The list is empty. Extraction failed to find any innings data.")
  }
  
  X = matrix(0, nrow = n, ncol = 3)
  Y = numeric(n)
  
  for (i in 1:n) {
    match = standardized_match_list[[i]]
    v_idx = venue_indices[[match$venue]] %||% 1.0
    
    X[i, 1] = match$rr
    X[i, 2] = match$wr
    X[i, 3] = v_idx
    Y[i] = match$runs
  }
  
  return(list(X = X, Y = Y))
}

# SCALING (For PCA/kNN) -----------------------------------------------------------------------

#' Scale Data for Modeling
#'
#' @description
#' Standardizes numeric features by centering and scaling.
#'
#' @usage
#' scale_for_model(df)
#'
#' @param df Data frame containing numeric features.
#'
#' @return
#' Numeric matrix of scaled values.
#'
#' @details
#' Each numeric column is transformed to have:
#' \itemize{
#'   \item Mean = 0
#'   \item Standard deviation = 1
#' }
#'
#' This is important for many machine learning algorithms such as PCA,
#' k-nearest neighbors, and gradient-based optimization.
#'
#' Non-numeric columns are ignored.
#'
#' @keywords internal
scale_for_model = function(df) {
  numeric_idx = sapply(df, is.numeric)
  scaled_values = scale(df[, numeric_idx])
  return(scaled_values)
}
