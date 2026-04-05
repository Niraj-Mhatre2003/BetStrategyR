# BetStrategyR: Cricket Match Simulation & Betting Strategy Framework

**Author:** Niraj Mhatre  

---

## 🏏 Project Overview

**BetStrategyR** is a comprehensive R package designed for quantitative analysis of cricket betting strategies. It combines historical match simulation, advanced market intelligence, and risk management to provide a complete decision support system for sports bettors and analysts.

The system operates as a **Quantitative Decision Support Platform** that integrates probability theory, statistical simulation, and optimal capital allocation techniques to model match outcomes and identify profitable betting opportunities through rigorous backtesting.

**Key Capabilities:**
- 🎯 Single-match prediction with value identification
- 📊 Monte Carlo match outcome simulation (1,000+ iterations)
- 💰 Optimal stake sizing (Kelly Criterion, Flat Betting, Martingale)
- 📈 Long-term bankroll simulation across sequential bets
- ⚠️ Monte Carlo risk analysis (Probability of Ruin)
- 🔄 Strategy comparison and performance evaluation
- 🛡️ Automatic stop-loss protection and risk controls

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
  - `get_prediction()`: Single match prediction with betting recommendation.
  - `apply_betting_strategy()`: Execute risk-managed staking logic.
  - `calculate_over_prob()`: Probability model for Over/Under betting.
  - `calculate_spread_prob()`: Probability model for handicap/point spread betting.

* **Backtesting & Evaluation:**
  - `simulate_bankroll()`: Longitudinal backtest with stop-loss protection.
  - `simulate_bankroll_mc()`: Monte Carlo risk analysis (multiple simulation paths).
  - `plot_bankroll_path()`: Visualize bankroll evolution.
  - `plot_bankroll_distribution()`: Show distribution of outcomes across simulations.
  - `run_final_backtest()`: Comprehensive historical performance evaluation.

---

## 📊 Risk Management Features

* **Stop-Loss Controls:** Automatic halt when bankroll declines beyond specified threshold (default: 50%).
* **Kelly Criterion:** Optimal growth-oriented stake sizing with fractional Kelly options (e.g., Half-Kelly at 0.5x).
* **Multiple Betting Markets:** Support for moneyline, over/under, and point spread markets.
* **Adaptive Strategy Methods:** Kelly-based, flat betting, and Martingale approaches.
* **Survival Probability Metrics:** Monte Carlo analysis to assess probability of maintaining or growing bankroll.

---

## 📈 Performance Metrics

The framework provides comprehensive evaluation across:

* **Statistical Validation:** Accuracy, Brier Score, Log Loss, calibration analysis.
* **Financial Performance:**  Net Profit/Loss, Win Rate, Average Odds.
* **Risk Metrics:** Maximum Drawdown, Consecutive Losses, Survival Probability.

---

## 🛠 Installation

### Install BetStrategyR
```R
# Option 1: Install from source (.tar.gz file)
install.packages("BetStrategyR_0.0.0.1.tar.gz", repos=NULL, type="source")

# Option 2: Install from GitHub (if published)
# devtools::install_github("Niraj-Mhatre2003/BetStrategyR")

# Load the package:
library(BetStrategyR)
```

---

## 🎯 Quick Start: Complete Demo

To see **BetStrategyR** in action with all 6 steps of the betting workflow, run:

```R
source("runme.R")
```

**⏱️ Expected Runtime:** 2-3 minutes

### What the Demo Covers

#### **Step 1: Match Prediction & Betting Decision**
Get betting recommendation for a single match:

```R
pred <- get_prediction(
  team_a_stats = c(8.5, 0.05, 1.1),      # Run rate, wicket rate, venue factor
  team_b_stats = c(7.8, 0.06, 0.9),
  market_odds = 1.90,
  bankroll = 1000,
  bet_type = "moneyline",
  strategy_method = "kelly"
)

# Output: Recommended stake, expected value, win probability
```

**Interpretation:** If model probability > implied probability from odds, this indicates a **VALUE BET** opportunity. Kelly strategy suggests optimal bet sizing.

---

#### **Step 2: Exploring Different Betting Markets**
Test multiple markets to find highest expected value:

```R
# Over/Under market (total runs)
get_prediction(
  team_a_stats = c(8.5, 0.05, 1.1),
  team_b_stats = c(7.8, 0.06, 0.9),
  bet_type = "over_under",
  threshold = 160.5,
  strategy_method = "flat"
)

# Spread market (handicap)
get_prediction(
  team_a_stats = c(8.5, 0.05, 1.1),
  team_b_stats = c(7.8, 0.06, 0.9),
  bet_type = "spread",
  spread = -5.5,
  strategy_method = "martingale"
)
```

**Insight:** BetStrategyR supports multiple markets (moneyline, over/under, spread), allowing flexible strategy evaluation beyond simple win/loss betting.

---

#### **Step 3: Direct Match Simulation**
Use Monte Carlo to estimate match outcomes:

```R
sim <- simulate_match(
  team_a_stats = c(8.5, 0.05, 1.1),
  team_b_stats = c(7.8, 0.06, 0.9),
  iterations = 1000
)

cat("Estimated Win Probability (Team A):", round(sim$win_prob, 3), "\n")
```

**Output:** Probability that Team A wins, based on 1,000 simulated matches.

**Interpretation:** Simulation provides a data-driven estimate of match outcomes, which forms the foundation for betting decisions.

---

#### **Step 4: Long-Term Bankroll Simulation**
Simulate sequential bets across 50 matches:

```R
path_kelly <- simulate_bankroll(
  match_data = match_data,  # List of 50 match scenarios
  initial_bankroll = 1000,
  strategy_method = "kelly"
)

# View final bankroll
cat("Final Bankroll (Kelly):", tail(path_kelly, 1), "\n")

# Visualize evolution
plot_bankroll_path(path_kelly)
```

**Questions Answered:**
- Does bankroll grow steadily or fluctuate wildly?
- What's the worst drawdown?
- What's the ROI after 50 bets?

**Interpretation:** Shows how a strategy performs over time. Growth is not smooth — volatility is inherent in betting.

---

#### **Step 5: Monte Carlo Risk Analysis**
Run 25 simulations to evaluate probability of success:

```R
mc_result <- simulate_bankroll_mc(
  match_data = match_data,
  n_sim = 25,
  initial_bankroll = 1000,
  strategy_method = "kelly"
)

cat("Survival Probability:", 
    round(mc_result$survival_probability * 100, 2), "%\n")

# Visualize distribution of final bankroll values
plot_bankroll_distribution(mc_result)
```

**Key Metric:** **Survival Probability** — What percentage of 25 simulated paths end profitably?

**Interpretation:** Monte Carlo simulation estimates risk of ruin. Even profitable strategies can fail due to variance. This shows the distribution of outcomes across multiple scenarios.

---

#### **Step 6: Strategy Comparison**
Compare Kelly Criterion vs Flat Betting:

```R
path_kelly <- simulate_bankroll(
  match_data = match_data,
  strategy_method = "kelly"
)

path_flat <- simulate_bankroll(
  match_data = match_data,
  strategy_method = "flat"
)

# Plot both strategies
plot(path_kelly, type = "l", lty = 1,
     xlab = "Bet Number", ylab = "Bankroll",
     col = "red", lwd = 2,
     main = "Strategy Comparison: Kelly vs Flat",
     ylim = c(400, 5000))

lines(path_flat, lty = 2, col = "blue", lwd = 2)

legend("topleft",
       legend = c("Kelly", "Flat"),
       col = c("red","blue"),
       lty = c(1, 2))
```

**Key Insights:**
- **Kelly Criterion:** Higher growth but more volatile → compound growth strategy
- **Flat Betting:** Safer and more predictable → but slower growth

---

## 📚 Detailed Usage Examples

### Example 1: Single Match Analysis

```R
library(BetStrategyR)

# Step 1: Define team statistics
team_a_stats <- c(
  run_rate = 8.5,      # Average runs per over
  wicket_rate = 0.05,  # Wickets lost per over
  venue_factor = 1.1   # Home ground advantage
)

team_b_stats <- c(
  run_rate = 7.8,
  wicket_rate = 0.06,
  venue_factor = 0.9
)

# Step 2: Get prediction
pred <- get_prediction(
  team_a_stats = team_a_stats,
  team_b_stats = team_b_stats,
  market_odds = 1.90,
  bankroll = 1000,
  bet_type = "moneyline",
  strategy_method = "kelly"
)

# Step 3: Interpret results
if (pred$recommended_stake > 0) {
  cat("✓ VALUE BET FOUND!\n")
  cat("Recommended Stake:", pred$recommended_stake, "\n")
  cat("Expected Value:", pred$expected_value, "\n")
  cat("Win Probability:", pred$win_probability, "\n")
} else {
  cat("✗ No value detected. Skip this bet.\n")
}
```

---

### Example 2: Multi-Market Evaluation

```R
# Compare opportunities across 3 different markets
markets <- list(
  moneyline = list(odds = 1.90, type = "moneyline"),
  over_under = list(threshold = 160.5, type = "over_under"),
  spread = list(spread = -5.5, type = "spread")
)

best_edge <- NULL
best_ev <- -Inf

for (market_name in names(markets)) {
  market <- markets[[market_name]]
  
  pred <- get_prediction(
    team_a_stats = team_a_stats,
    team_b_stats = team_b_stats,
    market_odds = market$odds,
    bet_type = market$type,
    strategy_method = "kelly"
  )
  
  if (pred$expected_value > best_ev) {
    best_ev <- pred$expected_value
    best_edge <- market_name
  }
}

cat("Best opportunity:", best_edge, "with EV:", best_ev, "\n")
```

---

### Example 3: Backtest a Strategy

```R
# Load 50 historical matches
match_data <- list(
  list(team_a_stats=c(8.5,0.05,1.05), team_b_stats=c(7.8,0.06,0.95), market_odds=1.90),
  list(team_a_stats=c(8.2,0.045,1.00), team_b_stats=c(8.0,0.055,1.05), market_odds=1.88),
  # ... 48 more matches
)

# Run backtest with Kelly Criterion
kelly_results <- simulate_bankroll(
  match_data = match_data,
  initial_bankroll = 1000,
  strategy_method = "kelly"
)

# Run backtest with Flat Betting
flat_results <- simulate_bankroll(
  match_data = match_data,
  initial_bankroll = 1000,
  strategy_method = "flat"
)

# Compare results
kelly_final <- tail(kelly_results, 1)
flat_final <- tail(flat_results, 1)

cat("Kelly Final Bankroll:", kelly_final, "\n")
cat("Kelly ROI:", (kelly_final - 1000) / 1000 * 100, "%\n\n")

cat("Flat Final Bankroll:", flat_final, "\n")
cat("Flat ROI:", (flat_final - 1000) / 1000 * 100, "%\n")
```

---

### Example 4: Risk Analysis with Monte Carlo

```R
# Run 100 simulations of the betting sequence
mc_risk <- simulate_bankroll_mc(
  match_data = match_data,
  n_sim = 100,
  initial_bankroll = 1000,
  strategy_method = "kelly"
)

cat("Survival Probability:", 
    round(mc_risk$survival_probability * 100, 2), "%\n")

cat("Expected Final Bankroll:", 
    round(mean(mc_risk$final_bankrolls), 2), "\n")

cat("Worst Case Bankroll:", 
    round(min(mc_risk$final_bankrolls), 2), "\n")

# Visualize outcomes
plot_bankroll_distribution(mc_risk)
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
├── runme.R                       # Complete demo script (run this first!)
├── data/                         # Pre-trained models & datasets
├── tests/                        # Unit tests
└── README.md                     # This file
```

---

## 💡 Key Concepts

### Kelly Criterion
The Kelly Criterion calculates the optimal fraction of your bankroll to wager on each bet:

```
Kelly % = (Edge) / (Odds - 1)
```

where **Edge** = Your winning probability - Implied probability from odds

This maximizes long-term compound growth while minimizing risk of ruin.

### Monte Carlo Simulation
Instead of relying on single-path backtests, we run 25-100 independent simulations of the same betting sequence to understand:
- Distribution of outcomes (best case, worst case, median)
- Probability of ruin (bankroll falls below starting amount)
- Confidence in strategy profitability

### Value Betting
A bet has "value" when:
```
Your Probability > Implied Probability (from odds)
```

Example:
- You estimate Team A has 60% win probability
- Bookmaker odds 1.80 imply 55.6% probability
- Positive expected value → Place the bet!

---

## 🚀 Use Cases

1. **Pre-Match Analysis:** Should I bet on this match? How much?
2. **Market Comparison:** Which betting market offers the best opportunity?
3. **Strategy Evaluation:** Will my strategy be profitable long-term?
4. **Risk Assessment:** What's my probability of ruin with this strategy?
5. **Portfolio Optimization:** Kelly vs Flat - which strategy fits my risk tolerance?
6. **Performance Audit:** How did my strategy perform on historical data?

---

## 📊 Output Interpretation Guide

| Metric | What It Means | Interpretation |
|--------|---------------|-----------------|
| **Expected Value (EV)** | Average profit per bet | Positive EV = profitable bet |
| **Win Probability** | Chance your prediction is correct | Higher is better (>55% is good) |
| **Recommended Stake** | Amount to wager (Kelly method) | Conservative sizing to minimize ruin risk |
| **Final Bankroll** | Ending balance after sequence | Compare to starting $1,000 |
| **Survival Probability** | % of Monte Carlo paths that profit | Higher is better (>85% is excellent) |

---

## 📝 Version History

**Current Version:** 0.0.0.1  
- Initial release with core betting strategy framework
- Single match prediction
- Bankroll simulation (Kelly, Flat, Martingale)
- Monte Carlo risk analysis
- Strategy comparison tools

---

## ⚠️ Disclaimer

**BetStrategyR is a quantitative analysis tool for research and educational purposes.**

- Past performance does not guarantee future results
- Betting involves risk of financial loss
- Use at your own risk and within legal jurisdictions
- Always gamble responsibly
- Never bet more than you can afford to lose

---

## 🔗 Contact & Support

**Author:** Niraj Mhatre  
**GitHub:** [https://github.com/Niraj-Mhatre2003/BetStrategyR](https://github.com/Niraj-Mhatre2003/BetStrategyR)

For questions, issues, bug reports, or feature requests:
1. Open an issue on GitHub
2. Contact the author directly at nirajstats@gmail.com

---

## 📚 Further Reading

- Kelly Criterion: [https://en.wikipedia.org/wiki/Kelly_criterion](https://en.wikipedia.org/wiki/Kelly_criterion)
- Monte Carlo Methods: [https://en.wikipedia.org/wiki/Monte_Carlo_method](https://en.wikipedia.org/wiki/Monte_Carlo_method)
- Sports Analytics: Research papers on cricket win probability models

---

## 🙏 Acknowledgments

Built with R and powered by statistical simulation, optimal capital allocation theory, and practical sports betting experience.

Special thanks to the open-source R community for essential packages like `Rtsne`, `umap`, and `shiny`.

---

**Happy Betting! 🎯**

Remember: In the long run, edge + discipline + risk management = profit.
