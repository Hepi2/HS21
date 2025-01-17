#export files
knitr::purl("solution5.2.Rmd", "Solution_stat5.2.R", documentation = 0)



library(dplyr)
library(readr)
library(stringr)
library(ggfortify)
library(lme4)

nova <- read_delim("https://zenodo.org/record/3890949/files/2017_ZHAW_individual_menu_sales_NOVANIMAL.csv?download=1", delim = ";", locale = locale(encoding = "latin1"))

## definiert mytheme für ggplot2 (verwendet dabei theme_classic())
mytheme <- 
  theme_classic() + 
  theme(
    axis.line = element_line(color = "black"), 
    axis.text = element_text(size = 20, color = "black"), 
    axis.title = element_text(size = 20, color = "black"), 
    axis.ticks = element_line(size = 1, color = "black"), 
    axis.ticks.length = unit(.5, "cm")
    )



df <- nova # kopiert originaler Datensatz

# Genereiert eine Dummyvariable: Fleisch 1, kein Fleisch 0
df %<>%
  # entfernt Personen die sich ein Buffet Teller gekauft
  filter(label_content != "Hot and Cold") %>%
  # ihr könnt keine Angabe vernachlässigen, sind (nur) 54 Personen
  filter(age_group != "keine Angaben") %>% 
  mutate(label_content = str_replace_all(.$label_content, 
                                         c("Fisch|Geflügel"),"Fleisch")) %>%   
  mutate(meat = if_else(.$label_content == "Fleisch", 1, 0)) %>%
  # setzt andere Reihenfolge für die Hochschulzugehörigkeit, nur für die Interpretation
  # nützlich: neu Referenzkategorie Studierende (vorher Mitarbeitende)
  mutate(member = factor(.$member, levels = c("Studierende", "Mitarbeitende")))  


# wie viele NA's hat es dirn (uns interessiert v.a. die responsevariable: meat)
sum(is.na(df$meat)) #Amelia::missmap(df_)


# sieht euch die Verteilung zwischen Fleisch und  kein Fleisch an, 
# beide kategorien kommen nicht gleich häufig vor, aber nicht super tragisch
prop.table(table(df$meat)) # gibt die prozente an
table(df$meat) # gibt die absoluten werte an

# definiert das logistische Modell mit ccrs als random intercept und 
# wendet es auf den Datensatz an


#check out ICC: https://www.datanovia.com/en/lessons/intraclass-correlation-coefficient-in-r/
#however data needs to be wide format
#not working yet
df %>% dplyr::select(ccrs, label_content) %>% tidyr::pivot_wider(names_from = "ccrs", values_fill = "label_content") -> tt


library(lme4)
#dauert ein paar sekunden
mod0 <- glmer(meat ~ gender + member + age_group + (1|ccrs),
              data = df, binomial("logit")) 

# lasst euch das Modell anzeigen: sieht so aus, als ob v.a. Geschlecht eine 
# Rolle spielt
# wahrnmeldung kann vernachlässigt werden (aufgrund der unicode resp. 
# umlaute in den variablen)
summary(mod0) 


## erste Interpretation: Geschlecht (Mann) und Alter (junge Personen) scheinen den Fleischkonsum positiv zu beeinflussen + Hochschulzugehörigkeit spielt keien Rolle
# d.h. könnte man vernachlässigen. Ich lasse aus inhaltlichen Gründen aber im Modell drin

# Pseudo R^2
library(MuMIn)
r.squaredGLMM(mod0) 
# das marginale R^2 (r2m) gibt uns die erklärte Varianz der fixen Effekte: hier 4% (das ist sehr wenig)
# das conditionale R^2 (r2c) gibt uns die erklärte Varianz für das ganze Modell 
# (mit fixen und variablen Effekten): hier 27% (ganz ok, aber auch nicht super mega)
# für weitere Informationen: https://rdrr.io/cran/MuMIn/man/r.squaredGLMM.html 

# zusätzliche Informationen, welche für die Interpretation gut sein kann
# berechnet den Standardfehler (mehr infos: https://www.youtube.com/watch?v=r-txC-dpI-E oder hier: https://mgimond.github.io/Stats-in-R/CI.html)
# weitere info: https://stats.stackexchange.com/questions/26650/how-do-i-reference-a-regression-models-coefficients-standard-errors
se <- sqrt(diag(vcov(mod0)))

# zeigt eine Tabelle der Schätzer mit 95% Konfidenzintervall (KI)
# => Faustregel: falls 0 im KI enthalten ist, dann ist der Unterschied statistisch NICHT signifikant
tab1 <- cbind(Est = fixef(mod0), LL = fixef(mod0) - 1.96 * se,
              UL = fixef(mod0) + 1.96 * se)

# erzeugt die Odds Ratios
tab2 <- exp(tab1)


#replace rownames
rownames(tab1) <-  c("Intercept", "Männer", "Mitarbeitende",
                            "26 bis 34-jährig", "35 bis 49-jährig",
                            "50 bis 64-jährig")

# achtung wir sind hier im log raum
knitr::kable(tab1, col.names = c("Coefficients", "Lower Limit (LL)", "Uppewr Limit (UL)"),
             caption = "Modellschätzer (Coefficients) mit dazugehörigem 95% Konfidenzintervall", digits = 2)
             



# ersetze row names
rownames(tab2) <-  c("Intercept", "Männer", "Mitarbeitende",
                            "26 bis 34-jährig", "35 bis 49-jährig",
                            "50 bis 64-jährig")

knitr::kable(tab2, col.names = c("OR", "Lower Limit (LL)", "Uppewr Limit (UL)"),
             row.names = ,
             caption = "Odds Ratio (OR) mit dazugehörigem 95% Konfidenzintervall", 
             digits = 2)

```{.r .distill-force-highlighting-css}
```
