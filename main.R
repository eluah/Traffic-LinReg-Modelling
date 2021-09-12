# Graphical display of the observed data.
aadt_raw <- read.table('aadt.txt',header=FALSE)
aadt <- data.frame(y=aadt_raw$V1,x1=aadt_raw$V2,x2=aadt_raw$V3,x3=aadt_raw$V4,x4=aadt_raw$V5)
aadt$x4[aadt$x4=="2"] <- 0
plot(aadt)
cor(aadt)

# Fit a multiple linear regression model.
mlr <- lm(y ~ x1+x2+x3+x4, data=aadt)
summary(mlr)


# Normality checking.
qqnorm(residuals(mlr),ylab='Residuals')
qqline(residuals(mlr))

# Draw some plots of residuals.
par(mfrow=c(1,3))
plot(residuals(mlr),ylab='Residuals',xlab='Time')
plot(residuals(mlr),fitted(mlr),ylab='Residuals',xlab='Fitted values')
plot(residuals(mlr),aadt$predictor,ylab='Residuals',xlab='Predictor variable')
par(mfrow=c(1,1))

# new mlr model with sqrt y values
sqrtaadt <- data.frame(y=sqrt(aadt_raw$V1),x1=aadt_raw$V2,x2=aadt_raw$V3,x3=aadt_raw$V4,x4=aadt_raw$V5)
mlr1 <- lm(y ~ x1+x2+x3+x4, data=sqrtaadt)
summary(mlr1)

par(mfrow=c(1,3))
plot(residuals(mlr1),ylab='Residuals',xlab='Time')
plot(residuals(mlr1),fitted(mlr1),ylab='Residuals',xlab='Fitted values')
plot(residuals(mlr1),sqrtaadt$predictor,ylab='Residuals',xlab='Predictor variable')
par(mfrow=c(1,1))

# Durbin-Watson tests.
library(lmtest)
dwtest(y ~ x1+x2+x3+x4, data=sqrtaadt)

# Some F-tests.
mlr2 <- lm(y ~ x1+x2+x4,data=sqrtaadt)
anova(mlr2,mlr1)

# Checking new model without x3
summary(mlr2)
par(mfrow=c(1,3))
plot(residuals(mlr2),ylab='Residuals',xlab='Time')
plot(residuals(mlr2),fitted(mlr2),ylab='Residuals',xlab='Fitted values')
plot(residuals(mlr2),sqrtaadt$predictor,ylab='Residuals',xlab='Predictor variable')
par(mfrow=c(1,1))

names(mlr2)
mlr2s <- summary(mlr2)
names(mlr2s)

# Prediction
con <- c(1,50000,3,0)
lhat <- sum(con*coef(mlr2))**2
lhat
t05 <- qt(0.975,117)
bm <- t05*mlr2s$sigma*sqrt(con%*%mlr2s$cov.unscaled%*%con)
c(lhat-bm,lhat+bm)
c3 <- 1
bm <- t05*mlr2s$sigma*sqrt(con%*%mlr2s$cov.unscaled%*%con+c3)
c(lhat-bm,lhat+bm)
con <- data.frame(x1=50000,x2=3,x4=0)
predict(mlr2,con)**2
