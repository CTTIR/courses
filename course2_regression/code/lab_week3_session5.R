# ============================================================
# Biostatistics Courses
# Course 2 — Week 3, Session 5: Calibration and discrimination
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(MASS)
library(pROC)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Evaluate a logistic model by discrimination, calibration, and Brier.

# --- 2. Data ---------------------------------------------------
train <- as_tibble(Pima.tr) |> mutate(y = as.integer(type == "Yes"))
test  <- as_tibble(Pima.te) |> mutate(y = as.integer(type == "Yes"))

# --- 3. Visualise ----------------------------------------------
fit <- glm(y ~ glu + bmi + age + ped, data = train, family = binomial)
test$p <- predict(fit, test, type = "response")
p <- ggplot(test, aes(p, fill = factor(y))) +
  geom_histogram(position = "identity", alpha = 0.5, bins = 30) +
  labs(x = "Predicted probability", y = "Count", fill = "Diabetes")
print(p)

# --- 4. Assumptions --------------------------------------------
# evaluation uses held-out test set.

# --- 5. Conduct / Fit ------------------------------------------
roc_obj <- roc(test$y, test$p, quiet = TRUE)
print(auc(roc_obj)); print(ci.auc(roc_obj))
plot(roc_obj)
cal <- test |> mutate(bin = ntile(p, 10)) |>
  group_by(bin) |>
  summarise(predicted = mean(p), observed = mean(y), n = n())
print(cal)
brier <- mean((test$p - test$y)^2)

# --- 6. Report -------------------------------------------------
cat(sprintf("AUC: %.2f; Brier: %.3f\n",
            as.numeric(auc(roc_obj)), brier))
