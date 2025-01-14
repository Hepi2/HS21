#__________________________________________________________________________
# Research Methods, Teil Statistik
# Statistik 5: Demo
# Statistik_5_Demo_v.06.R | Version 0.6
#__________________________________________________________________________

# Split-plot ANOVA --------------------------------------------------------
# Based on Logan (2010), Chapter 14

spf <- read.delim("spf.csv", sep = ";") 
spf.aov <- aov(Reaktion~Signal * Messung + Error(VP), data = spf)
summary(spf.aov)

interaction.plot(spf$Messung, spf$Signal, spf$Reaktion)

# nun als LMM
if(!require(nlme)){install.packages("nlme")}
library(nlme)

# mit random intercept (VP) und random slope (Messung)
spf.lme.1 <- lme(Reaktion~Signal * Messung, random = ~Messung | VP, data = spf)
# #nur random intercept
spf.lme.2 <- lme(Reaktion~Signal * Messung, random = ~1 | VP, data = spf)

anova(spf.lme.1)
anova(spf.lme.2)

summary(spf.lme.1)
summary(spf.lme.2)



# GLMM --------------------------------------------------------------------
#  Based on Zuur et al. (2009), Kapitel 13

DeerEcervi <- read.delim("DeerEcervi.txt", sep = "", stringsAsFactors = T)

# Anzahl Larven hier in Presence/Absence übersetzt
DeerEcervi$Ecervi.01 <- DeerEcervi$Ecervi
DeerEcervi$Ecervi.01[DeerEcervi$Ecervi>0] <- 1

#Numerische Geschlechtscodierung als Factor
DeerEcervi$fSex <- as.factor(DeerEcervi$Sex)

DeerEcervi$CLength <- DeerEcervi$Length - mean(DeerEcervi$Length)

# Zunächst als GLM
# Interaktionen mit Farm nicht berücksichtigt, da zu viele Freiheitsgrade verbraucht würden
DE.glm <- glm(Ecervi.01 ~ CLength * fSex + Farm, family = binomial, data = DeerEcervi)

drop1(DE.glm, test = "Chi")
summary(DE.glm)
anova(DE.glm)


# Response curves für die einzelnen Farmen (Weibliche Tiere: fSex = "1" )
plot(DeerEcervi$CLength, DeerEcervi$Ecervi.01,
     xlab = "Length", ylab = "Probability of \
     presence of E. cervi L1")

I <- order(DeerEcervi$CLength)
AllFarms <- unique(DeerEcervi$Farm)
for (j in AllFarms){
  mydata <- data.frame(CLength=DeerEcervi$CLength, fSex = "1",
                       Farm = j)
  n <- dim(mydata)[1]
  if (n>10){
    P.DE2 <- predict(DE.glm, mydata, type = "response")
    lines(mydata$CLength[I], P.DE2[I])
  }}


# GLMM
if(!require(MASS)){install.packages("MASS")}
library(MASS)
DE.PQL <- glmmPQL(Ecervi.01 ~ CLength * fSex,
                random = ~ 1 | Farm, family = binomial, data = DeerEcervi)
summary(DE.PQL)


g <- 0.8883697 + 0.0378608 * DeerEcervi$CLength
p.averageFarm1 <- exp(g)/(1 + exp(g))
I <- order(DeerEcervi$CLength)  #Avoid spaghetti plot
plot(DeerEcervi$CLength, DeerEcervi$Ecervi.01, xlab="Length",
     ylab = "Probability of presence of E. cervi L1")
lines(DeerEcervi$CLength[I], p.averageFarm1[I],lwd=3)
p.Upp <- exp(g + 1.96 * 1.462108)/(1 + exp(g+1.96 * 1.462108))
p.Low <- exp(g - 1.96 * 1.462108)/(1 + exp(g-1.96 * 1.462108))
lines(DeerEcervi$CLength[I], p.Upp[I])
lines(DeerEcervi$CLength[I], p.Low[I])


if(!require(lme4)){install.packages("lme4")}
library(lme4)
DE.lme4 <- glmer(Ecervi.01 ~ CLength * fSex + (1|Farm), family = binomial, data = DeerEcervi)
summary(DE.lme4)

if(!require(glmmML)){install.packages("glmmML")}
library(glmmML)
DE.glmmML <- glmmML(Ecervi.01 ~ CLength * fSex,
                  cluster = Farm, family = binomial, data = DeerEcervi)
summary(DE.glmmML)

