# Statistical Hypothesis Testing in R

# loading packages
library(tidyverse)
library(fitdistrplus)

# locking the random number generation for reproducibility
set.seed(123)



# Task 1: data generation

# mice data
mice <- data.frame(
  name = rep(paste0("M_", 1:200), times = 2),
  weight = c(
    rnorm(n = 200, mean = 20, sd = sqrt(2)),  # before treatment
    rnorm(n = 200, mean = 21, sd = sqrt(2.5)) # after treatment
  ),
  weight_group = rep(c("Before", "After"), each = 200)
)

# rats data
rats <- data.frame(
  name = rep(paste0("R_", 1:200), times = 2),
  weight = c(
    rweibull(n = 200, shape = 10, scale = 20), # before treatment
    rweibull(n = 200, shape = 9, scale = 21)   # after treatment
  ),
  weight_group = rep(c("Before", "After"), each = 200)
)


# Tasks 1c & 1d: Plots

save_plot <- function(plot, filename, width = 6, height = 4) {
  ggsave(filename, plot = plot, width = width, height = height, dpi = 300)
}

# Density plots
plot_density <- function(data, title) {
  p <- ggplot(data, aes(x = weight, fill = weight_group)) +
    geom_density(alpha = 0.5, adjust = 1.5) +
    labs(title = title, x = "Weight", y = "Density", fill = "Group") +
    theme_minimal(base_size = 14) +
    theme(
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.major = element_line(color = "gray80"),
      panel.grid.minor = element_line(color = "gray90"),
      plot.title = element_text(hjust = 0.5, color = "black"),
      axis.title = element_text(color = "black"),
      axis.text = element_text(color = "black"),
      legend.text = element_text(color = "black"),
      legend.title = element_text(color = "black")
    )
  return(p)
}

density_mice <- plot_density(mice, "Mice Weight Density Before vs After Treatment")
density_rats <- plot_density(rats, "Rats Weight Density Before vs After Treatment")

save_plot(density_mice, "mice_density.png")
save_plot(density_rats, "rats_density.png")

# Box plots
plot_box <- function(data, title) {
  p <- ggplot(data, aes(x = weight_group, y = weight, fill = weight_group)) +
    geom_boxplot(alpha = 0.5) +
    labs(title = title, x = "Group", y = "Weight") +
    theme_minimal(base_size = 14) +
    theme(
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.major = element_line(color = "gray80"),
      panel.grid.minor = element_line(color = "gray90"),
      plot.title = element_text(hjust = 0.5, color = "black"),
      axis.title = element_text(color = "black"),
      axis.text = element_text(color = "black"),
      legend.text = element_text(color = "black"),
      legend.title = element_text(color = "black"),
      legend.position = "none"
    )
  return(p)
}

box_mice <- plot_box(mice, "Mice Weight Boxplot Before vs After Treatment")
box_rats <- plot_box(rats, "Rats Weight Boxplot Before vs After Treatment")

save_plot(box_mice, "mice_boxplot.png")
save_plot(box_rats, "rats_boxplot.png")



# Task 2: Normality Check

# QQ plots and Shapiro-Wilk test
check_normality <- function(data, title) {
  p <- ggplot(data, aes(sample = weight)) +
    stat_qq() +
    stat_qq_line() +
    labs(title = paste("QQ Plot -", title)) +
    theme_minimal()
  print(p)
  
  shapiro_result <- shapiro.test(data$weight)
  return(shapiro_result)
}

shapiro_mice <- check_normality(mice, "Mice Combined")
shapiro_rats <- check_normality(rats, "Rats Combined")

print(shapiro_mice)
print(shapiro_rats)



# Task 3: Hypothesis Testing

# Paired t-test for mice
t_test_mice <- t.test(weight ~ weight_group, data = mice, paired = TRUE)
print(t_test_mice)

# Wilcoxon test for rats
wilcox_rats <- wilcox.test(weight ~ weight_group, data = rats, conf.int = TRUE)
print(wilcox_rats)



# Task 4: Distribution Fitting (rats)

# Distribution fitting
fit_w <- fitdist(rats$weight, "weibull")
fit_ln <- fitdist(rats$weight, "lnorm")
fit_g <- fitdist(rats$weight, "gamma")

# Summary
summary(fit_w)
summary(fit_ln)
summary(fit_g)

# Open PNG device
png("rats_distribution_fitting.png", width = 1600, height = 1200, res = 150)

# Layout for 2x2 plots
par(mfrow = c(2,2))

# Generate the plots
denscomp(list(fit_w, fit_g, fit_ln), legendtext = c("Weibull", "Gamma", "Lognormal"))
cdfcomp(list(fit_w, fit_g, fit_ln), legendtext = c("Weibull", "Gamma", "Lognormal"))
qqcomp(list(fit_w, fit_g, fit_ln), legendtext = c("Weibull", "Gamma", "Lognormal"))
ppcomp(list(fit_w, fit_g, fit_ln), legendtext = c("Weibull", "Gamma", "Lognormal"))

# Close device
dev.off()
