# BetSimR: High-Dimensional Cricket Strategy & Simulation Suite

**Author:** Niraj Mhatre  

---

## 🏏 Project Overview
**BetSimR** is an R package designed for the analysis and optimization of betting strategies using advanced statistical simulation. Functioning as a **Quantitative Decision Support System**, it allows users to input match data or live betting odds, simulate match outcomes using Monte Carlo methods, and evaluate the effectiveness of various betting strategies through high-dimensional visualization and rigorous economic metrics.

The architecture combines probability theory, manifold learning, and capital allocation techniques like the **Kelly Criterion** to provide actionable insights for decision-making under uncertainty.

---

## 🛠 Technical Architecture
The package leverages a sophisticated statistical pipeline to ensure robust predictions and risk management:

* **Manifold Learning (PCA & UMAP):** Applied to performance features to reduce dimensionality, mitigate multicollinearity, and identify the latent drivers of match outcomes.
* **Non-Parametric Prediction (kNN):** Identifies the "k" most similar historical match profiles within the reduced feature space to anchor simulations.
* **Monte Carlo Engine:** Match outcomes are generated via thousands of Bernoulli trials. This empirical distribution allows for the observation of the **Central Limit Theorem (CLT)** in real-time as the mean predicted score converges.
* **Iterative Optimization:** Implements custom Gradient Descent logic to optimize team-strength weighting and minimize prediction error.
* **Market Intelligence:** Uses **Shin’s Method** to strip bookmaker overrounds, converting public odds into "Fair" implied probabilities.

---

## 🚀 Workflow
1.  **Market Ingestion:** Input decimal or fractional odds to establish the market baseline.
2.  **Outcome Simulation:** Generate a distribution of match results based on historical similarity and Monte Carlo iterations.
3.  **Edge Detection:** Compare simulated probabilities against market-implied probabilities to identify value.
4.  **Strategy Application:** Select between **Flat Betting**, **Martingale**, or **Confidence-Weighted** approaches.
5.  **Bankroll Evolution:** Simulate thousands of potential "future paths" for your capital to estimate risk and return.
6.  **Optimal Allocation:** Receive specific bet-size recommendations ($f^*$) using the **Kelly Criterion**.

---

## 📦 Core Functions
* `input_odds()`: Interface for entering market-available odds.
* `convert_prob()`: Advanced de-vigging and probability conversion.
* `simulate_match()`: High-performance Monte Carlo simulation engine.
* `apply_strategy()`: Logic for executing various risk-management profiles.
* `simulate_bankroll()`: Longitudinal tracking of capital growth and drawdown.
* `kelly_bet()`: Calculation of optimal growth-oriented stake sizes.

---

## 📊 Performance & Risk Metrics
* **Statistical Intelligence:** Brier Score, Log Loss, and Calibration analysis.
* **Economic Audit:** Return on Investment (ROI), Sharpe Ratio, and Maximum Drawdown (MDD).

---

## 🛠 Installation
```R
# Core dependencies:
install.packages(c("umap", "Rtsne", "shiny", "mclust", "implied"))

# Install BetSimR:
# devtools::install_github("nirajmhatre/BetSimR")
