# --- R/batch_processor.R ---

# Standard helper
`%||%` = function(a, b) if (!is.null(a)) a else b

process_t20_folder = function(folder_path) {
  files = list.files(path = folder_path, pattern = "\\.json$", full.names = TRUE)
  all_matches = list()
  
  cat("--- Starting Batch Extraction ---\n")
  cat("Found", length(files), "files in folder.\n")
  
  for (i in 1:length(files)) {
    raw_data = tryCatch({ 
      jsonlite::fromJSON(files[i], simplifyVector = FALSE) 
    }, error = function(e) NULL)
    
    # If file is empty or has no innings, skip it
    if (is.null(raw_data) || is.null(raw_data$innings)) next
    
    # --- NO MATCH TYPE FILTER --- (We assume the folder only has T20s)
    
    # Venue Extraction
    venue_name = raw_data$info$city %||% raw_data$info$venue %||% "Unknown Venue"
    if (is.list(venue_name)) venue_name = venue_name[[1]] # Handle list-type names
    
    for (inn in raw_data$innings) {
      t_runs = 0; t_balls = 0; t_wickets = 0
      
      # Drill down manually
      if (!is.null(inn$overs)) {
        for (over in inn$overs) {
          for (del in over$deliveries) {
            # Total runs
            t_runs = t_runs + (del$runs$total %||% 0)
            
            # Wickets
            if (!is.null(del$wickets)) t_wickets = t_wickets + length(del$wickets)
            
            # Legal Balls
            extras = del$extras
            if (is.null(extras$wides) && is.null(extras$noballs)) {
              t_balls = t_balls + 1
            }
          }
        }
      }
      
      # --- MINIMAL FILTER --- (Just check if they played at least 1 ball)
      if (t_balls > 1) {
        all_matches[[length(all_matches) + 1]] = list(
          team = as.character(inn$team %||% "Unknown"),
          runs = as.numeric(t_runs),
          balls = as.numeric(t_balls),
          rr = (as.numeric(t_runs) / as.numeric(t_balls)) * 6,
          wr = as.numeric(t_wickets) / as.numeric(t_balls),
          venue = as.character(venue_name)
        )
      }
    }
    
    if (i %% 100 == 0) cat("Parsed", i, "files...\n")
  }
  
  cat("Successfully extracted", length(all_matches), "innings.\n")
  return(all_matches)
}