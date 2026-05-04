# ============================================================
# Biostatistics Courses
# Course 1 — Week 4, Session 4: Non-parametric tests
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis ---------------------------------------------
# H0: the two (or more) distributions have the same location.
# H1: they do not.

# --- 2. Data ---------------------------------------------------
# Unpaired two-sample (skewed): lognormal vs shifted lognormal.
a <- rlnorm(30, meanlog = 1.0, sdlog = 0.6)
b <- rlnorm(30, meanlog = 1.4, sdlog = 0.6)
unpaired <- tibble(
  value = c(a, b),
  group = factor(rep(c("A", "B"), each = 30))
)

# Paired: pre/post measurements with a modest within-subject effect.
n <- 25
pre  <- rnorm(n, 100, 12)
post <- pre + rnorm(n, 5, 8)
paired <- tibble(id = 1:n, pre = pre, post = post)

# Three groups for Kruskal-Wallis.
three <- tibble(
  value = c(rlnorm(20, 0.8, 0.4),
            rlnorm(20, 1.0, 0.4),
            rlnorm(20, 1.3, 0.4)),
  group = factor(rep(c("low", "mid", "high"), each = 20),
                 levels = c("low", "mid", "high"))
)

# --- 3. Visualise ----------------------------------------------
print(
  ggplot(unpaired, aes(group, value, fill = group)) +
    geom_boxplot(alpha = 0.6, colour = "grey30") +
    labs(x = NULL, y = "Value") +
    theme(legend.position = "none")
)

# --- 4. Assumptions --------------------------------------------
# Rank-based tests assume independence and (for location tests)
# similar distribution shape across groups.
cat("Shapiro p, group A:", signif(shapiro.test(a)$p.value, 2), "\n")
cat("Shapiro p, group B:", signif(shapiro.test(b)$p.value, 2), "\n")

# --- 5. Conduct / Fit ------------------------------------------
w_unp <- wilcox.test(value ~ group, data = unpaired,
                     conf.int = TRUE)
w_pair <- wilcox.test(paired$post, paired$pre,
                      paired = TRUE, conf.int = TRUE)
kw <- kruskal.test(value ~ group, data = three)
sgn <- binom.test(sum(paired$post > paired$pre), n)

print(tidy(w_unp))
print(tidy(w_pair))
print(tidy(kw))
print(tidy(sgn))

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Unpaired Wilcoxon: W = %.0f, p = %.3f\n",
  w_unp$statistic, w_unp$p.value
))
cat(sprintf(
  "Paired signed-rank: V = %.0f, p = %.3f, median difference = %.2f\n",
  w_pair$statistic, w_pair$p.value, w_pair$estimate
))
cat(sprintf(
  "Kruskal-Wallis: H = %.2f, df = %d, p = %.3f\n",
  kw$statistic, kw$parameter, kw$p.value
))
