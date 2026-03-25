# --- data_prep.R ---
#Defining needed operators---------------------------------------------------------------------------------

`%||%` = function(a, b) if (!is.null(a)) a else b

# VALIDATION ----------------------------------------------------------------------------------

validate_data = function(df, required_cols) {
  missing = required_cols[!(required_cols %in% colnames(df))]
  if (length(missing) > 0) {
    stop(paste("Error: Missing columns:", paste(missing, collapse = ", ")))
  }
  return(TRUE)
}
# logic for >1,if odds = 1.5 on every 1 unit we get 0.5 units so for <1 we actually lose
validate_odds = function(odds) {
  if (any(odds <= 1)) {
    stop("Error: Decimal odds must be greater than 1.0")
  }
  return(TRUE)
}

#FEATURE EXTRACTION ---------------------------------------------------------------------------

# Standardizes match objects into a clean list
# Use this for both training (JSON) and manual input
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

scale_for_model = function(df) {
  numeric_idx = sapply(df, is.numeric)
  scaled_values = scale(df[, numeric_idx])
  return(scaled_values)
}
