# BetStrategyR: Cricket Match Simulation & Betting Strategy Framework

**Author:** Niraj Mhatre  

---

## 🏏 Project Overview

**BetStrategyR** is a comprehensive R package designed for quantitative analysis of cricket betting strategies. It combines historical match simulation, advanced market intelligence, and risk management frameworks to provide data-driven betting recommendations.

The system operates as a **Quantitative Decision Support Platform** that integrates probability theory, statistical simulation, and optimal capital allocation techniques to model match outcomes and identify valuable betting opportunities.

---

## 🛠 Technical Architecture

The package implements a sophisticated statistical pipeline optimized for cricket analytics:

* **Data Preparation Module:** Standardizes match statistics (run rates, wicket rates, venue impact) into feature vectors for modeling.
* **Model Training Engine:** Implements gradient descent optimization to learn team strength patterns from historical match data.
* **Monte Carlo Simulation:** Generates thousands of match outcome simulations to derive empirical probability distributions.
* **Market Intelligence:** Converts bookmaker odds into fair implied probabilities and identifies edge opportunities.
* **Backtest Engine:** Evaluates strategy performance across historical match datasets with stop-loss protection.
* **Betting Strategy Logic:** Implements Kelly Criterion, Flat Betting, and Martingale approaches for stake sizing.

---

## 🚀 Workflow

1. **Data Ingestion:** Load match history and normalize team performance metrics (runs, wickets, venue data).
2. **Model Training:** Train predictive models using gradient descent on historical match features.
3. **Match Simulation:** Run Monte Carlo simulations to generate win probability distributions.
4. **Market Analysis:** Convert odds to probabilities and calculate edge against bookmaker odds.
5. **Strategy Execution:** Apply Kelly Criterion or flat betting to determine optimal stake sizes.
6. **Backtesting:** Simulate strategy performance across historical matches with risk controls.
7. **Performance Audit:** Evaluate ROI, Sharpe Ratio, Maximum Drawdown, and other financial metrics.

---

## 📦 Core Functions

* **Data Preparation:**
  - `create_match_object()`: Build standardized match feature vectors.
  - `calculate_venue_indices()`: Quantify venue-specific performance impact.
  - `prepare_training_tensors()`: Format data for model training.

* **Model & Simulation:**
  - `train_model()`: Gradient descent optimization of team strength parameters.
  - `simulate_match()`: Monte Carlo engine for match outcome probability.

* **Market Intelligence:**
  - `convert_odds_to_prob()`: Convert decimal odds to implied probabilities.
  - `de_vig_market()`: Remove bookmaker margin (de-vigging).
  - `calculate_kelly_stake()`: Compute optimal stake using Kelly Criterion.

* **Betting Strategies:**
  - `apply_betting_strategy()`: Execute risk-managed staking logic.
  - `calculate_over_prob()`: Probability model for Over/Under betting.
  - `calculate_spread_prob()`: Probability model for handicap/point spread betting.

* **Backtesting & Evaluation:**
  - `simulate_bankroll()`: Longitudinal backtest with stop-loss protection.
  - `run_final_backtest()`: Comprehensive historical performance evaluation.

---

## 📊 Risk Management Features

* **Stop-Loss Controls:** Automatic halt when bankroll declines beyond specified threshold (default: 50%).
* **Kelly Criterion:** Optimal growth-oriented stake sizing with fractional Kelly options (e.g., Half-Kelly at 0.5x).
* **Multiple Betting Markets:** Support for moneyline, over/under, and point spread markets.
* **Adaptive Strategy Methods:** Kelly-based, flat betting, and Martingale approaches.

---

## 📈 Performance Metrics

The framework provides comprehensive evaluation across:

* **Statistical Validation:** Accuracy, Brier Score, Log Loss, calibration analysis.
* **Financial Performance:** ROI, Net Profit/Loss, Win Rate, Average Odds.
* **Risk Metrics:** Sharpe Ratio, Maximum Drawdown, Consecutive Losses.

---

## 🛠 Installation

```R
# Core dependencies:
install.packages(c("umap", "Rtsne", "shiny", "mclust", "implied"))

# Install BetStrategyR from GitHub:
# devtools::install_github("Niraj-Mhatre2003/BetStrategyR")

# Load the package:
# library(BetStrategyR)
```

---

## 📚 Quick Start Example

```R
# 1. Load your match data and create standardized match objects
match_obj1 = create_match_object("Team A", 254, 300, 9, "Napier", 1)
match_obj2 = create_match_object("Team B", 219, 260, 10, "Napier", 0)

# 2. Prepare tensors from historical matches
history = list(match_obj1, match_obj2)
venue_indices = calculate_venue_indices(history)
tensors = prepare_training_tensors(history, venue_indices)

# 3. Train the predictive model
model = train_model(tensors$X, tensors$Y, learning_rate = 0.0001, iterations = 1000)

# 4. Simulate a match to get win probabilities
team_a_features = c(match_obj1$rr, match_obj1$wr, venue_indices[["Napier"]])
team_b_features = c(match_obj2$rr, match_obj2$wr, venue_indices[["Napier"]])
win_prob = simulate_match(team_a_features, team_b_features, model, iterations = 5000)

# 5. Check for market edge
bookie_odds = 1.80
kelly_stake = calculate_kelly_stake(win_prob, bookie_odds, bankroll = 1000)

# 6. Backtest the strategy
backtest_results = simulate_bankroll(match_data, model, initial_bankroll = 1000, 
                                     strategy_method = "kelly")
```

---

## 📁 Repository Structure

```
BetStrategyR/
├── R/
│   ├── main.R                    # Main execution pipeline
│   ├── data_prep.R               # Match data standardization
│   ├── model_trainer.R           # Gradient descent training
│   ├── market_engine.R           # Odds & probability conversion
│   ├── simulation_engine.R       # Monte Carlo match simulation
│   ├── strategy_logic.R          # Kelly & staking methods
│   ├── backtest_engine.R         # Historical backtesting
│   ├── batch_processor.R         # Multi-match batch operations
│   ├── investor_advisor.R        # Risk & return recommendations
│   ├── user_interface_logic.R    # UI helper functions
│   └── run_final_backtest.R      # Full backtest execution
├── data/                         # Pre-trained models
├── tests/                        # Unit tests
└── README.md                     # This file
```

---

## 📝 Version

**Current Version:** 0.0.0.1

---

## 🔗 Contact & Support

For questions, issues, or contributions, please visit the [GitHub repository](https://github.com/Niraj-Mhatre2003/BetStrategyR).
