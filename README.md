# BetSimR: High-Dimensional Statistical Inference & Cricket Strategy Simulator

**Author:** Niraj Mhatre  
**Institution:** Indian Institute of Technology Kanpur (IITK)  
**Course:** MTH210 Statistical Computing  
**Project Deadline:** April 4, 2026  

---

## 🏏 Project Overview
[cite_start]**BetSimR** is an R package designed to assist users in analyzing and optimizing betting strategies using advanced statistical simulation techniques[cite: 121]. [cite_start]Unlike standard predictors, this package functions as a **Quantitative Decision Support System**[cite: 123]. [cite_start]It allows users to input match data or betting odds, simulate match outcomes using Monte Carlo methods, and evaluate the effectiveness of various betting strategies through high-dimensional visualization and rigorous statistical metrics[cite: 122, 123].

[cite_start]The core architecture combines probability theory, **Monte Carlo simulation**, and optimization techniques like the **Kelly Criterion** to provide actionable insights into betting scenarios[cite: 123].

---

## 🛠 Statistical Framework & Constraints (MTH210)
To meet the academic requirements of MTH210, the package integrates the following central statistical concepts:

* [cite_start]**Dimensionality Reduction (PCA):** Applied to team and player performance features to reduce multicollinearity and identify latent drivers of match outcomes[cite: 68, 69].
* **Manifold Learning & Clustering:** Uses **UMAP/t-SNE** for match similarity mapping and **k-means/EM Algorithm** for identifying latent team "form" states.
* **Non-Parametric Prediction (kNN):** Predicts match outcomes by identifying the "k" most similar historical matches within the reduced PCA/UMAP space.
* [cite_start]**Simulation & CLT:** Match outcomes are simulated using **Bernoulli trials**[cite: 156]. [cite_start]By running 10,000+ iterations, the package demonstrates the **Central Limit Theorem (CLT)**, showing the convergence of the empirical distribution of outcomes[cite: 156].
* **Optimization (Gradient Descent):** A custom implementation to optimize the loss function for team-strength weighting.
* **Inference Quality:** Diagnostics for **Unbiasedness** and **Consistency** to ensure model-derived probabilities are statistically sound.

---

## 🚀 Package Workflow
[cite_start]The package follows a structured pipeline designed for both academic rigor and practical utility[cite: 132]:

1.  [cite_start]**Input Data/Odds:** Users provide match metrics or bookmaker odds[cite: 133].
2.  [cite_start]**Market Analysis:** Conversion of decimal odds into implied probabilities[cite: 134, 153].
3.  [cite_start]**Simulation Engine:** Generates an empirical distribution of match outcomes through repeated Monte Carlo runs[cite: 135, 156].
4.  [cite_start]**Strategy Selection:** Users choose between **Flat Betting**, **Martingale**, or **Kelly Criterion**[cite: 137, 158].
5.  [cite_start]**Bankroll Evolution:** Iterative updates to the user's bankroll to estimate expected returns and **Risk of Ruin**[cite: 138, 168].
6.  [cite_start]**Visualization:** High-fidelity plots of bankroll growth and risk distribution histograms[cite: 139, 184].
7.  [cite_start]**Recommendation:** Suggests the optimal bet size ($f^*$) based on the calculated edge[cite: 140, 182].

---

## 📦 Key Functions
* [cite_start]`input_odds()`: Accepts user-defined market odds[cite: 176].
* [cite_start]`convert_prob()`: Strips bookmaker margins (overround) to find fair probabilities[cite: 176].
* [cite_start]`simulate_match()`: Executes the Monte Carlo engine for match outcomes[cite: 177].
* [cite_start]`apply_strategy()`: Computes stakes based on selected risk profiles[cite: 179].
* [cite_start]`simulate_bankroll()`: Tracks the longitudinal evolution of capital[cite: 180].
* [cite_start]`kelly_bet()`: Calculates the optimal fraction of bankroll to wager[cite: 182].

---

## 📊 Evaluation Metrics
[cite_start]The package evaluates performance using two distinct lenses[cite: 92]:
* [cite_start]**Statistical Metrics:** Brier Score, Log Loss, and Calibration Curves[cite: 93, 94, 95].
* [cite_start]**Economic Metrics:** Return on Investment (ROI), Sharpe Ratio, and Maximum Drawdown[cite: 97, 98, 99, 100].

---

## 🛠 Installation
```R
# Internal logic uses these core packages for dimensionality and UI:
install.packages(c("umap", "Rtsne", "shiny", "mclust", "implied"))

# To install BetSimR (once hosted):
# devtools::install_github("yourusername/BetSimR")
