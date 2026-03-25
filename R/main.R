# --- main.R ---
# 1. Load the required logic
# (In a real package, you would use library(betsimR) or source() these files)
source("R/data_prep.R")
source("R/model_trainer.R")
source("R/market_engine.R")
source("R/simulation_engine.R")

# 2. MOCK DATA: Simulate loading your '64814.json' file
# We will use the stats from the Napier match you provided
napier_match = list(
  venue = "Napier",
  team1 = list(name = "New Zealand", runs = 254, balls = 300, wickets = 9, result = 1),
  team2 = list(name = "India", runs = 219, balls = 260, wickets = 10, result = 0)
)

# 3. PRE-PROCESSING
# Create standardized objects for training
match_obj1 = create_match_object("New Zealand", 254, 300, 9, "Napier", 1)
match_obj2 = create_match_object("India", 219, 260, 10, "Napier", 0)

# Create a history list for training (usually this would be hundreds of matches)
history = list(match_obj1, match_obj2)

# Calculate Venue Impact
venue_indices = calculate_venue_indices(history)

# Prepare Tensors [RR, WR, VenueIndex]
tensors = prepare_training_tensors(history, venue_indices)

# 4. TRAINING (Gradient Descent)
cat("--- Starting Model Training ---\n")
model = train_model(tensors$X, tensors$Y, learning_rate = 0.0001, iterations = 1000)

# 5. SIMULATION (The Monte Carlo Rematch)
# Let's simulate a rematch at Napier
cat("\n--- Running Monte Carlo Simulation ---\n")

# Prepare feature vectors for the current match
nz_features = c(match_obj1$rr, match_obj1$wr, venue_indices[["Napier"]])
ind_features = c(match_obj2$rr, match_obj2$wr, venue_indices[["Napier"]])

win_prob_nz = simulate_match(nz_features, ind_features, model, overs = 50, iterations = 5000)

cat(paste("Probability of New Zealand winning the rematch:", round(win_prob_nz * 100, 2), "%\n"))

# 6. MARKET CHECK (Optional)
# If a bookmaker gives NZ odds of 1.80, is there an edge?
bookie_prob = convert_odds_to_prob(1.80)
edge = calculate_edge(win_prob_nz, 1.80)

cat(paste("Market Probability:", round(bookie_prob * 100, 2), "%\n"))
cat(paste("Your Edge:", round(edge * 100, 2), "%\n"))

