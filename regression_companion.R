# Regression Analysis: Companion R Script
# Author: Alexis Diamond, PhD (assisted by Claude and ChatGPT)
# Version 0.9 --- August 26, 2026
# Generated from regression_companion.Rmd.
# Run from top to bottom. Uses base R grammar only.


# ---- ch1-conditional-means ----
x <- rep(c(1, 2, 3, 4), each = 5)
y <- c(3, 4, 4, 5, 4,
       5, 5, 6, 7, 7,
       7, 8, 8, 9, 8,
       9, 10, 11, 10, 10)

dat <- data.frame(x, y)

tapply(dat$y, dat$x, mean)

fit <- lm(y ~ x, data = dat)
summary(fit)

plot(
  dat$x,
  dat$y,
  xlab = "X",
  ylab = "Y",
  main = "Observed Outcomes and a Fitted Regression"
)
abline(fit, lwd = 2)

# ---- ch1-expectation-not-observable ----
# A binary outcome: 1 = employed, 0 = not employed.
employed <- c(1, 1, 1, 1, 0, 1, 1, 1, 0, 1)

mean(employed)   # 0.8

# Every person is a 0 or a 1, so no one has the value 0.8:
sort(unique(employed))

# For a binary Y the conditional mean IS the probability that Y = 1.
# A count outcome makes the same point:
visits <- c(7, 9, 10, 11, 14)
mean(visits)     # 10.2 -- not a possible number of visits

# ---- ch1-linear-loess ----
set.seed(123)

x <- seq(0, 10, length.out = 60)
y <- 2 + 0.35 * x + 1.5 * sin(x) + rnorm(60, sd = 0.5)

dat_curve <- data.frame(x, y)

fit_linear <- lm(y ~ x, data = dat_curve)
fit_loess <- loess(y ~ x, data = dat_curve, span = 0.60)

plot(
  dat_curve$x,
  dat_curve$y,
  xlab = "X",
  ylab = "Y",
  main = "Linear Regression and LOESS"
)
abline(fit_linear, lwd = 2)

ord <- order(dat_curve$x)
lines(
  dat_curve$x[ord],
  predict(fit_loess)[ord],
  lwd = 2,
  lty = 2
)

legend(
  "topleft",
  legend = c("Linear regression", "LOESS"),
  lty = c(1, 2),
  lwd = 2,
  bty = "n"
)

# ---- ch1-regression-families ----
set.seed(42)

# Continuous outcome
x_cont <- runif(200, 0, 10)
y_cont <- 4 + 2 * x_cont + rnorm(200, sd = 3)
dat_cont <- data.frame(x = x_cont, y_cont = y_cont)
fit_ols <- lm(y_cont ~ x, data = dat_cont)

# Binary outcome
x_binary <- runif(200, 0, 10)
p_binary <- 1 / (1 + exp(-(-3 + 0.6 * x_binary)))
y_binary <- rbinom(200, size = 1, prob = p_binary)
dat_binary <- data.frame(x = x_binary, y_binary = y_binary)
fit_logit <- glm(
  y_binary ~ x,
  family = binomial(link = "logit"),
  data = dat_binary
)

# Count outcome
x_count <- runif(200, 0, 5)
lambda <- exp(0.4 + 0.25 * x_count)
count <- rpois(200, lambda = lambda)
dat_count <- data.frame(x = x_count, count = count)
fit_pois <- glm(
  count ~ x,
  family = poisson(link = "log"),
  data = dat_count
)

# Flexible conditional-mean smoother
fit_loess <- loess(y ~ x, data = dat_curve)

summary(fit_ols)
summary(fit_logit)
summary(fit_pois)

# ---- ch1-count-zeros ----
# Zeros are ordinary observations in count data:
sum(dat_count$count == 0)
min(dat_count$count)

# But no fitted value is ever zero, because lambda = exp(X %*% beta) > 0 always:
lambda_hat <- fitted(fit_pois)
min(lambda_hat)

# The model never predicts zero; it assigns zero a probability.
# At the smallest fitted mean, P(Y = 0) = exp(-lambda):
exp(-min(lambda_hat))

# ---- ch2-binary-difference-means ----
D <- c(rep(0, 5), rep(1, 5))
Y <- c(4, 5, 6, 7, 8,
       7, 8, 9, 10, 11)

dat_binary_ols <- data.frame(D, Y)

fit_binary <- lm(Y ~ D, data = dat_binary_ols)
summary(fit_binary)
coef(fit_binary)

mean(dat_binary_ols$Y[dat_binary_ols$D == 0])
mean(dat_binary_ols$Y[dat_binary_ols$D == 1])
mean(dat_binary_ols$Y[dat_binary_ols$D == 1]) -
  mean(dat_binary_ols$Y[dat_binary_ols$D == 0])

# ---- ch2-binary-plot ----
plot(
  jitter(dat_binary_ols$D, amount = 0.04),
  dat_binary_ols$Y,
  xaxt = "n",
  xlab = "Binary predictor D",
  ylab = "Outcome Y",
  main = "OLS with a Binary Predictor"
)
axis(1, at = c(0, 1), labels = c("D = 0", "D = 1"))

abline(fit_binary, lwd = 2)
points(
  c(0, 1),
  c(
    mean(dat_binary_ols$Y[dat_binary_ols$D == 0]),
    mean(dat_binary_ols$Y[dat_binary_ols$D == 1])
  ),
  pch = 15,
  cex = 1.5
)

# ---- ch2-cars-predict ----
fit_cars <- lm(dist ~ speed, data = cars)
summary(fit_cars)
coef(fit_cars)

# Predictions for training observations
train_predictions <- predict(fit_cars)
head(data.frame(
  speed = cars$speed,
  observed_dist = cars$dist,
  predicted_dist = train_predictions
))

# Predictions for new cases
new_cases <- data.frame(speed = c(10, 15, 20))
new_cases$predicted_dist <- predict(
  fit_cars,
  newdata = new_cases
)
new_cases

# Reproduce predict() literally from the coefficients
b <- coef(fit_cars)
manual_predictions <- b[1] + b[2] * new_cases$speed
cbind(new_cases, manual_predictions = manual_predictions)

# ---- ch2-cars-prediction-plot ----
plot(
  cars$speed,
  cars$dist,
  xlab = "Speed",
  ylab = "Stopping distance",
  main = "Regression as a Prediction Rule"
)
abline(fit_cars, lwd = 2)
points(
  new_cases$speed,
  new_cases$predicted_dist,
  pch = 15,
  cex = 1.4
)

# ---- ch2-coefficient-ci ----
confint(fit_cars, level = 0.95)

coef_table <- summary(fit_cars)$coefficients
coef_table

b_speed <- coef_table["speed", "Estimate"]
se_speed <- coef_table["speed", "Std. Error"]

# Approximate 95% confidence interval
b_speed + c(-1, 1) * 2 * se_speed

# ---- ch2-rsquared ----
fit_cars <- lm(dist ~ speed, data = cars)

summary(fit_cars)$r.squared

mse_mean_only <- mean(
  (cars$dist - mean(cars$dist))^2
)

mse_model <- mean(
  (cars$dist - predict(fit_cars))^2
)

mse_mean_only
mse_model
1 - mse_model / mse_mean_only

# ---- ch2-irreducible-error ----
set.seed(7)

# The true DGP: Y = f(X) + epsilon, with f known to us only in a simulation.
f <- function(x) 2 + 0.8 * x
sigma <- 2

simulate_data <- function(n) {
  x <- runif(n, 0, 10)
  data.frame(x = x, y = f(x) + rnorm(n, sd = sigma))
}

# A large test set, used to measure out-of-sample prediction error.
test <- simulate_data(5000)

# The oracle: predict using the TRUE f. No model can beat this.
oracle_mse <- mean((test$y - f(test$x))^2)

# Fit on training samples of different sizes and score on the same test set.
test_mse_at <- function(n) {
  train <- simulate_data(n)
  fit <- lm(y ~ x, data = train)
  mean((test$y - predict(fit, newdata = test))^2)
}

round(
  c(
    irreducible = sigma^2,      # Var(epsilon): the floor
    oracle      = oracle_mse,   # the true f, estimated on nothing
    n_25        = test_mse_at(25),
    n_250       = test_mse_at(250),
    n_10000     = test_mse_at(10000)
  ),
  3
)

# ---- ch3-three-intervals ----
fit <- lm(dist ~ speed, data = cars)

# 1. Confidence intervals for regression coefficients
confint(fit)

# 2. Confidence interval for the conditional mean at speed = 15
predict(
  fit,
  newdata = data.frame(speed = 15),
  interval = "confidence"
)

# 3. Prediction interval for one new observation at speed = 15
predict(
  fit,
  newdata = data.frame(speed = 15),
  interval = "prediction"
)

# ---- ch3-coefficient-ci-plot ----
fit <- lm(dist ~ speed, data = cars)

slope <- coef(fit)["speed"]
slope_ci <- confint(fit)["speed", ]

plot(
  1, slope,
  xlim = c(0.5, 1.5),
  ylim = range(c(0, slope_ci)),
  xaxt = "n",
  xlab = "",
  ylab = "Slope coefficient for speed",
  pch = 19
)

segments(
  x0 = 1,
  y0 = slope_ci[1],
  x1 = 1,
  y1 = slope_ci[2],
  lwd = 3
)

points(1, slope, pch = 19)
axis(1, at = 1, labels = "speed")
abline(h = 0, lty = 3)

# ---- ch3-interval-bands ----
fit <- lm(dist ~ speed, data = cars)

speed_grid <- data.frame(
  speed = seq(
    from = min(cars$speed),
    to = max(cars$speed),
    length.out = 200
  )
)

conf_band <- predict(
  fit,
  newdata = speed_grid,
  interval = "confidence",
  level = 0.95
)

pred_band <- predict(
  fit,
  newdata = speed_grid,
  interval = "prediction",
  level = 0.95
)

plot(
  cars$speed,
  cars$dist,
  xlab = "Speed",
  ylab = "Stopping distance",
  main = "Confidence and Prediction Intervals"
)

lines(speed_grid$speed, conf_band[, "fit"], lwd = 3)
lines(speed_grid$speed, conf_band[, "lwr"], lty = 2, lwd = 2)
lines(speed_grid$speed, conf_band[, "upr"], lty = 2, lwd = 2)
lines(speed_grid$speed, pred_band[, "lwr"], lty = 3, lwd = 2)
lines(speed_grid$speed, pred_band[, "upr"], lty = 3, lwd = 2)

legend(
  "topleft",
  legend = c(
    "Regression line",
    "Confidence interval for mean",
    "Prediction interval for new observation"
  ),
  lty = c(1, 2, 3),
  lwd = c(3, 2, 2),
  bty = "n"
)

# ---- ch3-same-center ----
fit <- lm(dist ~ speed, data = cars)

b <- coef(fit)

# Calculate the prediction literally from the coefficients
manual_prediction <- b[1] + b[2] * 15
manual_prediction

# Ask predict() for the point prediction
predict(
  fit,
  newdata = data.frame(speed = 15)
)

# ---- ch3-mtcars-multiple ----
fit_simple <- lm(mpg ~ am, data = mtcars)
fit_multiple <- lm(mpg ~ wt + am, data = mtcars)

coef(fit_simple)
coef(fit_multiple)

# Two cars with exactly the same weight
same_weight <- data.frame(
  wt = c(3, 3),
  am = c(0, 1)
)

predicted_mpg <- predict(
  fit_multiple,
  newdata = same_weight
)

predicted_mpg
predicted_mpg[2] - predicted_mpg[1]
coef(fit_multiple)["am"]

# Two cars with the same transmission, different weight
same_transmission <- data.frame(
  wt = c(3, 4),
  am = c(0, 0)
)

predicted_mpg <- predict(
  fit_multiple,
  newdata = same_transmission
)

predicted_mpg[2] - predicted_mpg[1]
coef(fit_multiple)["wt"]

# ---- ch3-multiple-plot ----
point_type <- ifelse(mtcars$am == 1, 19, 1)

plot(
  mtcars$wt,
  mtcars$mpg,
  pch = point_type,
  xlab = "Weight (1,000 pounds)",
  ylab = "Miles per gallon",
  main = "Multiple Regression: mpg ~ wt + am"
)

b <- coef(fit_multiple)
abline(a = b["(Intercept)"], b = b["wt"], lwd = 3)
abline(
  a = b["(Intercept)"] + b["am"],
  b = b["wt"],
  lwd = 3,
  lty = 2
)

legend(
  "topright",
  legend = c("Automatic: am = 0", "Manual: am = 1"),
  pch = c(1, 19),
  lty = c(1, 2),
  lwd = c(3, 3),
  bty = "n"
)

# ---- ch3-interaction-centering ----
fit_interaction <- lm(mpg ~ wt * am, data = mtcars)
summary(fit_interaction)

mtcars_for_example <- mtcars
mtcars_for_example$wt_centered <-
  mtcars_for_example$wt - mean(mtcars_for_example$wt)

fit_interaction_centered <- lm(
  mpg ~ wt_centered * am,
  data = mtcars_for_example
)
summary(fit_interaction_centered)

# ---- ch3-omitted-confounder-coverage ----
set.seed(11)

alpha1 <- 2.00   # the causal effect of x on y
alpha2 <- 0.15   # the effect of the omitted confounder z on y

one_study <- function(n) {
  z <- rnorm(n)
  x <- 0.7 * z + rnorm(n)                      # x and z are related
  y <- 1 + alpha1 * x + alpha2 * z + rnorm(n)
  fit <- lm(y ~ x)                             # z omitted
  ci <- confint(fit)["x", ]
  c(est = unname(coef(fit)["x"]),
    lower = unname(ci[1]),
    upper = unname(ci[2]))
}

# What the short regression actually targets: beta1 = alpha1 + alpha2 * delta1,
# where delta1 is the population slope of z on x.
delta1 <- 0.7 / (0.7^2 + 1)
beta1 <- alpha1 + alpha2 * delta1
beta1

coverage <- function(n, reps = 2000) {
  out <- replicate(reps, one_study(n))
  c(n                 = n,
    mean_estimate     = mean(out["est", ]),
    covers_causal     = mean(out["lower", ] <= alpha1 & out["upper", ] >= alpha1),
    covers_projection = mean(out["lower", ] <= beta1  & out["upper", ] >= beta1))
}

round(rbind(coverage(100), coverage(1000), coverage(10000)), 4)

# ---- ch4-functional-form ----
set.seed(9)

x <- seq(1, 10, length.out = 100)
y <- 5 + 2 * x - 0.25 * x^2 + rnorm(100, sd = 1.5)
dat_functional <- data.frame(x, y)

fit_linear <- lm(y ~ x, data = dat_functional)
fit_quadratic <- lm(y ~ x + I(x^2), data = dat_functional)
fit_cubic <- lm(y ~ x + I(x^2) + I(x^3), data = dat_functional)
fit_logx <- lm(y ~ log(x), data = dat_functional)

summary(fit_linear)$r.squared
summary(fit_quadratic)$r.squared
summary(fit_cubic)$r.squared
summary(fit_logx)$r.squared

# ---- ch4-mtcars-interaction ----
fit_additive <- lm(mpg ~ wt + am, data = mtcars)
fit_interaction <- lm(mpg ~ wt * am, data = mtcars)

summary(fit_additive)
summary(fit_interaction)

# ---- ch4-interaction-plot ----
plot(
  mtcars$wt,
  mtcars$mpg,
  pch = ifelse(mtcars$am == 0, 1, 19),
  xlab = "Weight (1,000 pounds)",
  ylab = "Miles per gallon",
  main = "Interaction: mpg ~ wt * am"
)

auto_wt <- seq(
  min(mtcars$wt[mtcars$am == 0]),
  max(mtcars$wt[mtcars$am == 0]),
  length.out = 100
)

manual_wt <- seq(
  min(mtcars$wt[mtcars$am == 1]),
  max(mtcars$wt[mtcars$am == 1]),
  length.out = 100
)

auto_pred <- predict(
  fit_interaction,
  newdata = data.frame(wt = auto_wt, am = 0)
)

manual_pred <- predict(
  fit_interaction,
  newdata = data.frame(wt = manual_wt, am = 1)
)

lines(auto_wt, auto_pred, lwd = 3)
lines(manual_wt, manual_pred, lwd = 3, lty = 2)

legend(
  "topright",
  legend = c("Automatic", "Manual"),
  pch = c(1, 19),
  lty = c(1, 2),
  lwd = c(3, 3),
  bty = "n"
)

# ---- ch4-gap-data ----
set.seed(26)

x_left <- runif(35, min = 1, max = 4)
x_right <- runif(35, min = 7, max = 10)
x <- c(x_left, x_right)

y <- c(
  2 + 3 * x_left + rnorm(35, mean = 0, sd = 0.5),
  28 - x_right + rnorm(35, mean = 0, sd = 0.5)
)

gap_data <- data.frame(x = x, y = y)

fit_linear <- lm(y ~ x, data = gap_data)
fit_quadratic <- lm(y ~ x + I(x^2), data = gap_data)

new_point <- data.frame(x = 5.5)
predict(fit_linear, newdata = new_point)
predict(fit_quadratic, newdata = new_point)

# ---- ch4-gap-plot ----
x_grid <- seq(1, 10, length.out = 300)
new_grid <- data.frame(x = x_grid)

linear_hat <- predict(fit_linear, newdata = new_grid)
quadratic_hat <- predict(fit_quadratic, newdata = new_grid)

plot(
  gap_data$x,
  gap_data$y,
  xlab = "X",
  ylab = "Y",
  main = "Interpolation Across a Gap in the Training Data",
  pch = 19
)

rect(
  xleft = 4,
  ybottom = par("usr")[3],
  xright = 7,
  ytop = par("usr")[4],
  density = 12,
  angle = 45,
  border = NA
)

points(gap_data$x, gap_data$y, pch = 19)
lines(x_grid, linear_hat, lwd = 3)
lines(x_grid, quadratic_hat, lwd = 3, lty = 2)
abline(v = c(4, 7), lty = 3)

points(
  5.5,
  predict(fit_linear, newdata = data.frame(x = 5.5)),
  pch = 1,
  cex = 1.5,
  lwd = 2
)

points(
  5.5,
  predict(fit_quadratic, newdata = data.frame(x = 5.5)),
  pch = 2,
  cex = 1.5,
  lwd = 2
)

legend(
  "topleft",
  legend = c(
    "Linear fit",
    "Quadratic fit",
    "Gap with no training observations"
  ),
  lty = c(1, 2, NA),
  lwd = c(3, 3, NA),
  fill = c(NA, NA, "black"),
  density = c(0, 0, 35),
  angle = 45,
  border = c(NA, NA, "black"),
  bty = "n"
)

# ---- ch4-faithful-models ----
fit_linear <- lm(waiting ~ eruptions, data = faithful)
fit_quadratic <- lm(
  waiting ~ eruptions + I(eruptions^2),
  data = faithful
)
fit_cubic <- lm(
  waiting ~ eruptions + I(eruptions^2) + I(eruptions^3),
  data = faithful
)

summary(fit_linear)$r.squared
summary(fit_quadratic)$r.squared
summary(fit_cubic)$r.squared

new_case <- data.frame(eruptions = 7)
predict(fit_linear, newdata = new_case)
predict(fit_quadratic, newdata = new_case)
predict(fit_cubic, newdata = new_case)

# ---- ch4-faithful-plot ----
x_grid <- seq(1.4, 7, length.out = 300)
new_grid <- data.frame(eruptions = x_grid)

plot(
  faithful$eruptions,
  faithful$waiting,
  xlim = c(1.4, 7),
  ylim = c(15, 115),
  xlab = "Eruption duration (minutes)",
  ylab = "Waiting time (minutes)",
  main = "Functional Form and Extrapolation"
)

lines(x_grid, predict(fit_linear, newdata = new_grid), lwd = 3)
lines(
  x_grid,
  predict(fit_quadratic, newdata = new_grid),
  lwd = 3,
  lty = 2
)
lines(
  x_grid,
  predict(fit_cubic, newdata = new_grid),
  lwd = 3,
  lty = 3
)

abline(v = max(faithful$eruptions), lty = 2)

legend(
  "topleft",
  legend = c("Linear", "Quadratic", "Cubic"),
  lty = c(1, 2, 3),
  lwd = c(3, 3, 3),
  bty = "n"
)

# ---- ch4-loess-extrapolation ----
fit_loess <- loess(waiting ~ eruptions, data = faithful)

predict(
  fit_loess,
  newdata = data.frame(eruptions = c(2, 4, 7))
)

# ---- ch4-support-comparison ----
fit_interaction <- lm(mpg ~ wt * am, data = mtcars)

predict(
  fit_interaction,
  newdata = data.frame(
    wt = c(5, 5),
    am = c(0, 1)
  )
)

range(mtcars$wt[mtcars$am == 0])
range(mtcars$wt[mtcars$am == 1])

# ---- ch5-observational-data ----
x_control <- rep(0:8, each = 3)
x_treated <- rep(5:16, each = 3)

noise_control <- rep(c(-1, 0, 1), times = 9)
noise_treated <- rep(c(-1, 0, 1), times = 12)

Y0_control <- 5 + x_control + 0.4 * x_control^2 + noise_control
Y0_treated <- 5 + x_treated + 0.4 * x_treated^2 + noise_treated

D <- c(
  rep(0, length(x_control)),
  rep(1, length(x_treated))
)

x <- c(x_control, x_treated)
Y <- c(Y0_control, Y0_treated + 6)

causal_dat <- data.frame(Y, D, x)

# ---- ch5-model-dependence ----
fit_linear_adjustment <- lm(
  Y ~ D + x,
  data = causal_dat
)

fit_quadratic_adjustment <- lm(
  Y ~ D + x + I(x^2),
  data = causal_dat
)

coef(fit_linear_adjustment)["D"]
coef(fit_quadratic_adjustment)["D"]

# ---- ch5-overlap-restriction ----
overlap_dat <- causal_dat[
  causal_dat$x >= 5 & causal_dat$x <= 8,
]

fit_linear_overlap <- lm(
  Y ~ D + x,
  data = overlap_dat
)

fit_quadratic_overlap <- lm(
  Y ~ D + x + I(x^2),
  data = overlap_dat
)

coef(fit_linear_overlap)["D"]
coef(fit_quadratic_overlap)["D"]

# ---- ch5-overlap-plot ----
plot(
  causal_dat$x,
  causal_dat$Y,
  pch = ifelse(causal_dat$D == 1, 19, 1),
  xlab = "Confounder X",
  ylab = "Observed outcome Y",
  main = "Limited Overlap in an Observational Study"
)

abline(v = 5, lty = 3)
abline(v = 8, lty = 3)

legend(
  "topleft",
  legend = c("Control", "Treated", "Overlap: X = 5 to 8"),
  pch = c(1, 19, NA),
  lty = c(NA, NA, 3),
  bty = "n"
)

# ---- ch5-balanced-rct ----
x <- rep(0:16, each = 6)
D <- rep(c(0, 0, 0, 1, 1, 1), times = 17)
noise <- rep(c(-1, 0, 1, -1, 0, 1), times = 17)

Y0 <- 5 + x + 0.4 * x^2 + noise
Y <- Y0 + 6 * D

rct_dat <- data.frame(Y, D, x)

# Difference in means = treatment-only OLS coefficient
mean(rct_dat$Y[rct_dat$D == 1]) -
  mean(rct_dat$Y[rct_dat$D == 0])

fit_rct_simple <- lm(Y ~ D, data = rct_dat)
fit_rct_linear <- lm(Y ~ D + x, data = rct_dat)
fit_rct_quadratic <- lm(Y ~ D + x + I(x^2), data = rct_dat)

coef(fit_rct_simple)["D"]
coef(fit_rct_linear)["D"]
coef(fit_rct_quadratic)["D"]
