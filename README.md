# BetSimR: High-Dimensional Cricket Strategy & Simulation Suite

**Author:** Niraj Mhatre  

---

## 🏏 Project Overview
**BetSimR** is an R package designed for the analysis and optimization of betting strategies using advanced statistical simulation. [cite_start]Functioning as a **Quantitative Decision Support System**, it allows users to input match data or live betting odds, simulate match outcomes using Monte Carlo methods, and evaluate the effectiveness of various betting strategies through high-dimensional visualization and rigorous economic metrics[cite: 121, 122].

[cite_start]The architecture combines probability theory, manifold learning, and capital allocation techniques like the **Kelly Criterion** to provide actionable insights for decision-making under uncertainty[cite: 123].

---

## 🛠 Technical Architecture
The package leverages a sophisticated statistical pipeline to ensure robust predictions and risk management:

* [cite_start]**Manifold Learning (PCA & UMAP):** Applied to performance features to reduce dimensionality, mitigate multicollinearity, and identify the latent drivers of match outcomes[cite: 68, 69].
* **Non-Parametric Prediction (kNN):** Identifies the "k" most similar historical match profiles within the reduced feature space to anchor simulations.
* [cite_start]**Monte Carlo Engine:** Match outcomes are generated via thousands of Bernoulli trials[cite: 156]. [cite_start]This empirical distribution allows for the observation of the **Central Limit Theorem (CLT)** in real-time as the mean predicted score converges[cite: 105].
* **Iterative Optimization:** Implements custom Gradient Descent logic to optimize team-strength weighting and minimize prediction error.
* [cite_start]**Market Intelligence:** Uses **Shin’s Method** to strip bookmaker overrounds, converting public odds into "Fair" implied probabilities[cite: 74].

---

## 🚀 Workflow
1.  [cite_start]**Market Ingestion:** Input decimal or fractional odds to establish the market baseline[cite: 133].
2.  [cite_start]**Outcome Simulation:** Generate a distribution of match results based on historical similarity and Monte Carlo iterations[cite: 135].
3.  [cite_start]**Edge Detection:** Compare simulated probabilities against market-implied probabilities to identify value[cite: 75].
4.  [cite_start]**Strategy Application:** Select between **Flat Betting**, **Martingale**, or **Confidence-Weighted** approaches[cite: 158].
5.  [cite_start]**Bankroll Evolution:** Simulate thousands of potential "future paths" for your capital to estimate risk and return[cite: 138, 170].
6.  [cite_start]**Optimal Allocation:** Receive specific bet-size recommendations ($f^*$) using the **Kelly Criterion**[cite: 140, 161].

---

## 📦 Core Functions
* [cite_start]`input_odds()`: Interface for entering market-available odds[cite: 176].
* [cite_start]`convert_prob()`: Advanced de-vigging and probability conversion[cite: 176].
* [cite_start]`simulate_match()`: High-performance Monte Carlo simulation engine[cite: 177].
* [cite_start]`apply_strategy()`: Logic for executing various risk-management profiles[cite: 179].
* [cite_start]`simulate_bankroll()`: Longitudinal tracking of capital growth and drawdown[cite: 180].
* [cite_start]`kelly_bet()`: Calculation of optimal growth-oriented stake sizes[cite: 182].

---

## 📊 Performance & Risk Metrics
* [cite_start]**Statistical Intelligence:** Brier Score, Log Loss, and Calibration analysis[cite: 93, 94, 95].
* [cite_start]**Economic Audit:** Return on Investment (ROI), Sharpe Ratio, and Maximum Drawdown (MDD)[cite: 98, 99, 100].

---

## 🛠 Installation
```R
# Core dependencies:
install.packages(c("umap", "Rtsne", "shiny", "mclust", "implied"))

# Install BetSimR:
# devtools::install_github("nirajmhatre/BetSimR")
