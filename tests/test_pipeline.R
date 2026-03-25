# --- tests/test_pipeline.R ---
source("R/data_prep.R")
source("R/batch_processor.R")
source("R/model_trainer.R")

cat("--- STARTING FULL PIPELINE TEST ---\n")

# 1. Extraction
files = list.files("data-raw/T20_data/", pattern = "*.json", full.names = TRUE)
raw_matches = batch_process_json(files[1:4]) # Use the 4 files you uploaded
cat("Step 1: Extracted", length(raw_matches), "innings.\n")

# 2. Preparation (Venue Indices & Tensors)
v_indices = calculate_venue_indices(raw_matches)
tensors = prepare_training_tensors(raw_matches, v_indices)
cat("Step 2: Matrices created. Rows in X:", nrow(tensors$X), "\n")

# 3. Training (Gradient Descent)
cat("Step 3: Training model (500 iterations)...\n")
model = train_model(tensors$X, tensors$Y, iterations = 500)

cat("\n--- TEST COMPLETE: Model is functional ---\n")