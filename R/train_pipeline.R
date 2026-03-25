# --- train_pipeline.R ---
# Make sure your working directory is the package root

# 0. Requirements
if (!require("jsonlite")) install.packages("jsonlite")
library(jsonlite)

# 1. Load your package logic (source all files in R folder)
lapply(list.files("R", full.names = TRUE), source)

# 2. RUN BATCH EXTRACTION
# Replace "T20_data" with the actual path to your folder
historical_data = process_t20_folder("T20_data")

# 3. CALCULATE GLOBAL VENUE INDICES
# This maps every city in your dataset to a scoring multiplier
t20_venue_indices = calculate_venue_indices(historical_data)

# 4. PREPARE TRAINING TENSORS
# X: [RR, WR, VenueIndex] | Y: Actual Runs
tensors = prepare_training_tensors(historical_data, t20_venue_indices)

# 5. GRADIENT DESCENT (Offline Training)
cat("\n--- Starting Global Gradient Descent ---\n")
# We use a smaller learning rate and more iterations for a huge dataset
t20_model_params = train_model(
  X = tensors$X, 
  Y = tensors$Y, 
  learning_rate = 0.00005, 
  iterations = 5000
)

# 6. SAVE THE BRAIN
# This is what you ship with your R package.
# Your package will load this and be ready to predict instantly.
save(t20_model_params, t20_venue_indices, file = "data/t20_trained_weights.RData")

cat("\nTraining Complete! Weights saved to data/t20_trained_weights.RData\n")
cat("Final Bias:", t20_model_params$bias, "\n")
cat("Final Weights (RR, WR, Venue):", t20_model_params$weights, "\n")
