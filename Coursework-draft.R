# library(WeibullR) # weibull & tidyverse are conflicting. Is it supposed to be
# library(tidyverse) # like that?
# library(conflicted)
# library(dplyr)
# conflicts_prefer(dplyr::filter())
# filter(mtcars, am & cyl == 8)
# 
# # Tasks 1a & 1b: Generating datasets for mice and rats
# mice = data.frame(
#   name = paste0(rep("M_", 200), 1:200),
#   weight_before = round(rnorm(n=200, mean=20, sd=sqrt(2)), 2),
#   weight_after = round(rnorm(n=200, mean=21, sd=sqrt(2.5)), 2)
# )
# head(mice, 10)
# tail(mice, 10)
# 
# 
# rats = data.frame(
#   name = paste0(rep("R_", 200), 1:200),
#   weight_before = round(rweibull(n=200, shape=10, scale = 20), 2),
#   weight_after = round(rweibull(n=200, shape=9, scale = 21), 2)
# )
# head(rats, 10)
# tail(rats, 10)
# 
# # How are the graphs supposed to look like
# 
# # Task 2
# # Part A
# mice_combined = c(mice$weight_before, mice$weight_after)
# shapiro.test(mice_combined)
# 
# # Part B
# rats_combined = c(rats$weight_before, rats$weight_after)
# shapiro.test(rats_combined)
# 
# 
# 
# 
# 


library(fitdistrplus)
library(tidyverse)

# Tasks 1a & 1b: Generating datasets for mice and rats


# name, weight(value), weight_group(before or after)
mice = data.frame(name = rep(paste0(rep("M_", 200), 1:200), times=2), 
                  weight = c(
                    round(rnorm(n=200, mean=20, sd=sqrt(2)), 2), # weight before
                    round(rnorm(n=200, mean=21, sd=sqrt(2.5)), 2)), # weight after
                  weight_group = c(rep("before", times = 200), rep("after", times = 200))
                  
)
head(mice, 10)
tail(mice, 10)


rats = data.frame(name = rep(paste0(rep("R_", 200), 1:200), times=2), 
                  weight = c(
                    round(rweibull(n=200, shape=10, scale = 20), 2), # weight before
                    round(rweibull(n=200, shape=9, scale = 21), 2)), # weight after
                  weight_group = c(rep("before", times = 200), rep("after", times = 200))
                  
)
head(rats, 10)
tail(rats, 10)

qplot(fill = weight_group, x = weight, data = mice, geom = "density", main = "Mice",
      alpha = I(0.5),
      adjust = 1.5)

qplot(fill = weight_group, x = weight, data = rats, geom = "density", main = "Rats",
      alpha = I(0.5),
      adjust = 1.5)

qplot(x = weight_group, y = weight, data = mice, geom = "boxplot", main = "Mice")
qplot(x = weight_group, y = weight, data = rats, geom = "boxplot", main = "Rats")


# Should groups "Before" and "After" be separate (mice) or together (rats)?

qq_mice <- ggplot(data = mice, aes(sample = weight))
qq_mice + stat_qq() + stat_qq_line() + facet_grid(~ weight_group)
shapiro.test(mice$weight)

qq_mice <- ggplot(data = mice, aes(sample = weight))
qq_mice + stat_qq() + stat_qq_line()
shapiro.test(rats$weight)

qq_rats <- ggplot(data = rats, aes(sample = weight))
qq_rats + stat_qq() + stat_qq_line()
shapiro.test(rats$weight)

# Task 2, c - what test do you want us to use to test our hypothesis? T-test or smth similar?


# Task 3
# Part A
t.test(mice$weight ~ mice$weight_group, data = mice, paired = TRUE)
# When calculating df for the CW, we will be calculating it as df = n - 2, 
# because we have 2 types of observations: before and after. Right?

wilcox.test(weight ~ weight_group, data = rats, conf.int = TRUE)


# Task 4
plotdist(rats$weight, histo = TRUE, demp = TRUE)
descdist(rats$weight, discrete=FALSE, boot=1000)

fit_w <- fitdist(rats$weight, "weibull")
fit_ln <- fitdist(rats$weight, "lnorm")
fit_g <- fitdist(rats$weight, "gamma")

summary(fit_w)
summary(fit_ln)
summary(fit_g)

par(mfrow=c(2,2))
plot.legend <- c("Weibull", "lognormal", "gamma")
denscomp(list(fit_w, fit_g, fit_ln), legendtext = plot.legend)
cdfcomp (list(fit_w, fit_g, fit_ln), legendtext = plot.legend)
qqcomp (list(fit_w, fit_g, fit_ln), legendtext = plot.legend)
ppcomp (list(fit_w, fit_g, fit_ln), legendtext = plot.legend)

cdfcomp(fit_w, xlogscale = FALSE, ylogscale = FALSE)



