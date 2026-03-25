# --- tests/test_extraction.R ---
source("R/data_prep.R") # Needed for create_match_object
source("R/batch_processor.R")

# 1. Setup Path
data_path = "data-raw/T20_data/"
files = list.files(data_path, pattern = "*.json", full.names = TRUE)

# 2. Run Extraction on just 2 files to save time
cat("Testing extraction on first 2 files...\n")
test_data = batch_process_json(files[1:2])

# 3. Print Results
cat("Innings found:", length(test_data), "\n")
if(length(test_data) > 0) {
  cat("First Innings Team:", test_data[[1]]$team_name, "\n")
  cat("First Innings Runs:", test_data[[1]]$runs, "\n")
}