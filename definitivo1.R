library(caret)
library(readr)
library(dplyr)
library(tidyverse)
library(caret)
library(xgboost)
library(nnet)  # multinom
library(MetricsWeighted)
ehis <- read.delim("C:/Users/apant/Desktop/Statistical Learning/progetto/EHIS_Microdati_2019.txt")
#ehis2<- read_csv("EHIS_2019_IT_finale.csv")
ehis[ehis == -3] <- NA

ehis <- ehis[!is.na(ehis$UN2A), ]
ehis <- ehis[!is.na(ehis$UN2B), ]
ehis <- ehis[!is.na(ehis$UN2C), ]
ehis <- ehis[!is.na(ehis$UN2D), ]
#Variabile sintetica sulle abitudini alimentari
# Prima converti i missing
vars <- c("DH1", "DH3", "DH5", "DH6")
ehis[vars] <- lapply(ehis[vars], function(x) ifelse(x == -1, NA, x))

# Inverti la scala per le variabili "positive"
ehis$frutta_score <- 6 - ehis$DH1
ehis$verdura_score <- 6 - ehis$DH3
ehis$succhi_score <- 6 - ehis$DH5

# Mantieni la scala per le bevande zuccherate (è già inversa: 1 = tanto zucchero)
ehis$bevande_score <- ehis$DH6

# Calcolo punteggio finale
ehis$dieta_score <- rowSums(ehis[, c("frutta_score", "verdura_score", "succhi_score", "bevande_score")], na.rm = FALSE)

# Creazione della variabile dieta_cat in base a dieta_score
ehis$dieta_cat <- cut(
  ehis$dieta_score,
  breaks = c(-Inf, 9, 15, Inf),  # Definisci i punti di cut per le categorie
  labels = c("Poco sano", "Medio", "Sano"),  # Etichette delle categorie
  right = TRUE  # Include l'estremo superiore nel range
)
mh_vars <- c("MH1A", "MH1B", "MH1C", "MH1D", "MH1E", "MH1F", "MH1G", "MH1H")
ehis$indice_mentale <- rowSums(ehis[mh_vars], na.rm = FALSE)
ehis$indice_gruppi[ehis$indice_mentale >= 4 & ehis$indice_mentale <= 11] <- "Basso"
ehis$indice_gruppi[ehis$indice_mentale >= 12 & ehis$indice_mentale <= 20] <- "Medio-Basso"
ehis$indice_gruppi[ehis$indice_mentale >= 21 & ehis$indice_mentale <= 26] <- "Medio-Alto"
ehis$indice_gruppi[ehis$indice_mentale >= 27 & ehis$indice_mentale <= 32] <- "Alto"

#sintesi UN1A e UN1B
# Prima sostituisci i missing -1 con NA
ehis$UN1A[ehis$UN1A == -1] <- NA
ehis$UN1B[ehis$UN1B == -1] <- NA

# Crea la variabile sintetica
ehis$problemi_accesso_cure <- with(ehis, ifelse(
  UN1A == 1 | UN1B == 1, 1,                      # almeno un problema
  ifelse(UN1A == 2 & UN1B == 2, 2,               # nessun problema
         ifelse(UN1A == 3 & UN1B == 3, 3, NA)    # non ha avuto bisogno
  )))


##Grafici-----
age_labels <- c("15-17", "18-24", "25-34", "35-44", "45-49", "50-54",
                "55-59", "60-64", "65-69", "70-74", "75+")

# Etichette leggibili per UN2A
un2a_labels <- c("1" = "Yes", "2" = "No", "3" = "No, I had no need")

sex_labels <- c("1" = "Male", "2" = "Female")

dati_clean<-ehis
dati_clean$y_adj<-ehis$UN2A-1

# Dataframe con etichette fattoriali
df <- dati_clean %>%
  mutate(
    AGE_CLASS = factor(AGE_CLA75, levels = 1:11, labels = age_labels),
    SEX_LABEL = factor(SEX, levels = 1:2, labels = sex_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(AGE_CLASS), !is.na(SEX_LABEL), !is.na(UN2A_LABEL))

# Grafico con facet
ggplot(df, aes(x = AGE_CLASS, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ SEX_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Distribution of Giving Up Medical Care by Age Group and Gender",
    x = "Age Group",
    y = "%",
    fill = "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_brewer(palette = "Set2")


#Distribuzione della rinuncia alle cure per fascia d'età, genere e in base al fatto di prendersi cura di altri
# Etichette leggibili

care_labels <- c("-1"="Missing","1" = "Yes", "2" = "No")

# Prepara il dataset
df <- dati_clean %>%
  mutate(
    SEX_LABEL = factor(SEX, levels = 1:2, labels = sex_labels),
    CARE_LABEL = factor(IC1, levels = c("-1","1","2"), labels = care_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels),
    AGE_CLASS = factor(AGE_CLA75, levels = 1:11, labels = age_labels)
  ) %>%
  filter(!is.na(SEX_LABEL), !is.na(CARE_LABEL), !is.na(UN2A_LABEL), !is.na(AGE_CLASS))

# Crea il grafico
ggplot(df, aes(x = CARE_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_grid(rows = vars(SEX_LABEL), cols = vars(AGE_CLASS)) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title =  "Distribution of Giving Up Medical Care by Age Group, Gender and Caregiving",
    x = "Are you a Caregiver",
    y = "%",
    fill = "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1),
    strip.text.x = element_text(size = 10),
    strip.text.y = element_text(size = 11)
  ) +
  scale_fill_brewer(palette = "Set2")


# Etichette leggibili
chronic_labels <- c("1" = "Yes", "2" = "No")
income_labels <- c("1" = "I quantile", "2" = "II quantile", "3" = "III quantile",
                   "4" = "IV quantile", "5" = "V quantile")

# Prepara il dataset
df <- dati_clean %>%
  mutate(
    CHRONIC_LABEL = factor(HS2, levels = 1:2, labels = chronic_labels),
    INCOME_LABEL = factor(HHINCOME, levels = 1:5, labels = income_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(CHRONIC_LABEL), !is.na(INCOME_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = INCOME_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ CHRONIC_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Distribution of Giving Up Medical Care by Income, and Chronic Diseases",
    x = "Quantile of Income",
    y = "%",
    fill =  "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
  scale_fill_brewer(palette = "Set2")

#Distribuzione rinuncia alle cure in base alla cittadinanza

# Etichette leggibili
citizen_labels <- c("10" = "Italian", "20" = "Foreign")
table(dati_clean$CITIZEN2)
# Prepara il dataset
df <- dati_clean %>%
  mutate(
    CITIZEN_LABEL = factor(CITIZEN2, levels = c(10, 20), labels = citizen_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(CITIZEN_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = CITIZEN_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +  # percentuali
  scale_y_continuous(labels = scales::percent) +
  labs(
    title ="Distribution of Giving Up Medical Care by Citizenship",
    x = "Citizenship",
    y = "%",
    fill = "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_brewer(palette = "Set2")


#Distribuzione rinuncia alle cure per ripartizione geografica (RIP)
table(dati_clean$UN1B)
table(dati_clean$UN1A)
table(dati_clean$RIP)
# Etichette leggibili
rip_labels <- c("1" = "North-west", "2" = "North-east", "3" = "Center", 
                "4" = "South", "5" = "Island")
un1a_labels <- c("1" = "Yes", "2" = "No, no delay", "3" = "No,I had no need", 
                 "-1" = "Missing")
un1b_labels<-un1a_labels

# Prepara il dataset
df <- dati_clean %>%
  mutate(
    RIP_LABEL = factor(RIP, levels = 1:5, labels = rip_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels),
    UN1A_LABEL = factor(UN1A, levels = 1:4, labels = un1a_labels),
    UN1B_LABEL = factor(UN1B, levels = 1:4, labels = un1b_labels)
  ) %>%
  filter(!is.na(RIP_LABEL), !is.na(UN2A_LABEL),!is.na(UN1A_LABEL),!is.na(UN1B_LABEL))
table(dati_clean$IC1,dati_clean$AGE_CLA75)
# Crea il grafico
p1<-ggplot(df, aes(x = RIP_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ UN1A_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  
  labs(
    title = "Distribution of Giving Up Medical Care by Geographical Distribution and Delayed Care (Waiting List) ",
    x = "Geographical Distribution",
    y = "%",
    fill = "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(size = 12)) +
  scale_fill_brewer(palette = "Set2")

#Distribuzione rinuncia agli studi in base al titolo di studio (HATLEVEL4)



# Prepara il dataset
df <- dati_clean %>%
  mutate(
    RIP_LABEL = factor(RIP, levels = 1:5, labels = rip_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels),
    UN1A_LABEL = factor(UN1A, levels = 1:4, labels = un1a_labels),
    UN1B_LABEL = factor(UN1B, levels = 1:4, labels = un1b_labels)
  ) %>%
  filter(!is.na(RIP_LABEL), !is.na(UN2A_LABEL),!is.na(UN1A_LABEL),!is.na(UN1B_LABEL))

# Crea il grafico
p2<-ggplot(df, aes(x = RIP_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ UN1B_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  
  labs(
    title = "Distribution of Giving Up Medical Care by Geographical Distribution and Delayed Care(Access Issues)",
    x = "Geographical Distribution",
    y = "%",
    fill = "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(size = 12)) +
  scale_fill_brewer(palette = "Set2")

#Distribuzione rinuncia agli studi in base al titolo di studio (HATLEVEL4)
library(gridExtra)

grid.arrange(p1, p2, ncol = 1)


# Tabella congiunta
tabella <- table(dati_clean$RIP, dati_clean$UN1A)


# Calcolo percentuali di UN1A == 1 (cioè "Yes") per ogni area (RIP)
percentuali <- prop.table(tabella, margin = 1)[, "1"] * 100

# Aggiungo le etichette leggibili
names(percentuali) <- rip_labels[names(percentuali)]

# Visualizzo
round(percentuali, 2)

table(dati_clean$HS1)
# Etichette leggibili
riseco_labels <- c("1" = "Excellent", "2" = " Adequate", "3" = "Poor", 
                   "4" = " Absolutely insufficient")

hs1_labels <- c("1" = "Very good", "2" = "Good", "3" = "Neutral", 
                "4" = "Bad","5"="Very Bad")


# Prepara il dataset
df <- dati_clean %>%
  mutate(
    RISECO_LABEL = factor(RISECO, levels = 1:4, labels = riseco_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels),
    HS1_LABEL = factor(HS1, levels = 1:5, labels = hs1_labels)
  ) %>%
  filter(!is.na(RISECO_LABEL), !is.na(UN2A_LABEL),!is.na(HS1_LABEL))

# Crea il grafico
ggplot(df, aes(x = RISECO_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ HS1_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  
  labs(
    title = "Distribution of Medical Care Renunciation by Economic Resources and Self-Rated Health",
    x = " Economic Resources",
    y = "%",
    fill = "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(size = 12)) +
  scale_fill_brewer(palette = "Set2")


table(dati_clean$indice_gruppi)
table(dati_clean$dieta_cat)
table(dati_clean$y_adj)
table(dati_clean$SS2)

#indice_gruppi*SS2*dieta cat
gruppi_labels<- c("Basso" = "Low", "Medio-Basso" = " Mid-Low", "Medio-Alto" = "Mid-High", 
                  "Alto" = " High")
dieta_labels <- c("Poco sano" = "Unhealthy", "Medio" = "Moderate", "Sano" = "Healty")


SS2_labels <- c("-1"="Missing","1" = "Molta attenzione e molto interesse", "2" = "Abbastanza attenzione e interesse", "3" = "Ne poco ne molto",  "4" = "Scarsa attenzione e scarso interesse", "5"="Nessuna attenzione e nessun interesse")
dati_clean$SS2
factor(dati_clean$indice_gruppi, levels = c("Basso","Medio-Basso","Medio-Alto","Alto"), labels =gruppi_labels)
# Prepara il dataset
df <- dati_clean %>%
  mutate(
    GRUPPI_LABEL = factor(indice_gruppi,levels = c("Basso","Medio-Basso","Medio-Alto","Alto"), labels =gruppi_labels),
    DIETA_LABEL = factor(dieta_cat, levels = c("Poco Sano","Medio","Sano"), labels = dieta_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels),
    SS2_LABEL = factor(SS2, levels = 1:6, labels = SS2_labels)
  )  %>%
  filter(!is.na(DIETA_LABEL), !is.na(UN2A_LABEL),!is.na(GRUPPI_LABEL),!is.na(SS2_LABEL))


# Crea il grafico
ggplot(df, aes(x = SS2_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_grid(rows = vars(GRUPPI_LABEL)) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title =  "Distribution of Giving Up Medical Care by Age Group, Gender and Caregiving",
    x = "Are you a Caregiver",
    y = "%",
    fill = "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 6) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1),
    strip.text.x = element_text(size = 10),
    strip.text.y = element_text(size = 11)
  ) +
  scale_fill_brewer(palette = "Set2")


table(dati_clean$LAVDEN)


income_labels <- c("1" = "I quantile", "2" = "II quantile", "3" = "III quantile",
                   "4" = "IV quantile", "5" = "V quantile")
un2b_labels <- c("1" = "Yes", "2" = "No", "3" = "No, I had no need")
SS2_labels <- c(
  "-1" = "Missing",
  "1" = "A lot of attention and interest",
  "2" = "Quite a bit of attention and interest",
  "3" = "Neither much nor little",
  "4" = "Little attention and interest",
  "5" = "No attention and no interest"
)

lavden_labels<-c("-1"="Missing","1"="Spesso","2"="Una","3"="non sempre","4"="Mai")
# Prepara il dataset
df <- dati_clean %>%
  mutate(
    
    SS2_LABEL = factor(SS2, levels =1:6, labels = SS2_labels),
    UN2A_LABEL = factor(y_adj+1, levels = 1:3, labels = un2a_labels),
    UN2B_LABEL = factor(UN2B, levels = 1:3, labels = un2b_labels)
  )  %>%
  filter(!is.na(SS2_LABEL), !is.na(UN2A_LABEL),!is.na(UN2B_LABEL))


# Crea il grafico
ggplot(df, aes(x = SS2_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_grid(rows = vars(UN2B_LABEL)) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title =  "Distribution of Giving Up Medical Care by Others' Attention and Giving Up Dentist",
    x = "Others' attention",
    y = "%",
    fill = "Have you Given Up Medical Care?"
  ) +
  theme_minimal(base_size = 6) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1),
    strip.text.x = element_text(size = 10),
    strip.text.y = element_text(size = 11)
  ) +
  scale_fill_brewer(palette = "Set2")



# Funzione per calcolare la moda (categoria più frequente)
mode_cat <- function(x) {
  tab <- table(x)
  mod <- names(tab)[which.max(tab)]
  return(mod)
}

mode_summary <- function(var, group, varname) {
  levels_group <- unique(group)
  
  result <- data.frame(Group = character(),
                       Variable = character(),
                       Mode = character(),
                       Count = integer(),
                       Percent = numeric(),
                       stringsAsFactors = FALSE)
  
  for (g in levels_group) {
    subset_var <- var[group == g]
    mode_val <- mode_cat(subset_var)
    count_val <- sum(subset_var == mode_val, na.rm = TRUE)
    percent_val <- round(count_val / length(subset_var) * 100, 1)
    
    result <- rbind(result,
                    data.frame(Group = g,
                               Variable = varname,
                               Mode = mode_val,
                               Count = count_val,
                               Percent = percent_val))
  }
  return(result)
}
# Funzione che seleziona le variabili con moda diversa tra i gruppi di 'group_var'
select_vars_diff_mode <- function(data, group_var, categorical_vars) {
  group_levels <- unique(data[[group_var]])
  
  vars_diff <- c()
  
  for (v in categorical_vars) {
    modes <- sapply(group_levels, function(g) {
      subset_var <- data[[v]][data[[group_var]] == g]
      mode_cat(subset_var)
    })
    # Controllo se la moda è uguale per tutti i gruppi
    if(length(unique(modes)) > 1) {
      vars_diff <- c(vars_diff, v)
    }
  }
  
  return(vars_diff)
}




#Settiamo il df
df<- ehis %>%
  mutate(across(-WGT, as.factor))

categorical_vars <- names(df)[sapply(df, function(x) is.factor(x) || is.character(x))]
categorical_vars <- setdiff(categorical_vars, c("UN2A","WGT"))

# Lista per raccogliere i risultati

all_results <- do.call(rbind, lapply(categorical_vars, function(v) {
  mode_summary(df[[v]], df$UN2A, v)
}))

# Visualizza i risultati
print(all_results)

library(tidyr)
summary_table <- pivot_wider(all_results,
                             names_from = Group,
                             values_from = c(Mode, Count, Percent))

print(summary_table)


vars_con_moda_diversa <- select_vars_diff_mode(df, "UN2A", categorical_vars)

print(vars_con_moda_diversa)
# Filtra all_results per tenere solo le variabili con moda diversa
filtered_results <- all_results[all_results$Variable %in% vars_con_moda_diversa, ]

# Visualizza il risultato filtrato
print(filtered_results)


##Funzioni per Conformal Prediction----


confusion_matrix_weighted <- function(reference, prediction, weights = NULL) {
  if (length(reference) != length(prediction)) {
    stop("reference e prediction devono avere la stessa lunghezza.")
  }
  
  if (!is.null(weights) && length(weights) != length(reference)) {
    stop("I pesi devono avere la stessa lunghezza delle etichette.")
  }
  
  # Se i pesi non sono forniti, usa tutti 1
  if (is.null(weights)) {
    weights <- rep(1, length(reference))
  }
  
  # Crea fattori con livelli comuni
  levels_all <- sort(unique(c(reference, prediction)))
  reference <- factor(reference, levels = levels_all)
  prediction <- factor(prediction, levels = levels_all)
  
  # Tabella pesata
  tbl <- tapply(weights, list(Prediction = prediction, Reference = reference), sum, default = 0)
  
  # Assicura che sia una matrice completa con nomi
  tbl[is.na(tbl)] <- 0
  return(as.matrix(tbl))
}

mondrian_icp <- function(cal_probs, cal_labels, test_probs, alpha = 0.1) {
  classes <- sort(unique(cal_labels))
  thresholds <- list()
  
  # Costruisco le soglie per ogni classe
  for (k in classes) {
    p_k <- cal_probs[, k + 1]  # perché etichette sono 0-based
    in_class <- cal_labels == k
    threshold_k <- quantile(1 - p_k[in_class], probs = 1 - alpha, type = 8)
    thresholds[[as.character(k)]] <- threshold_k
  }
  
  # Per ogni test point, assegna tutte le classi compatibili
  prediction_sets <- lapply(1:nrow(test_probs), function(i) {
    sapply(classes, function(k) {
      p_ik <- test_probs[i, k + 1]
      (1 - p_ik) <= thresholds[[as.character(k)]]
    })
  })
  
  # Risultato: lista di prediction sets per ogni esempio
  return(prediction_sets)
}




###Modello-------


#"Le variabili relative alla rinuncia a cure odontoiatriche, psicologiche e ai farmaci sono state incluse come possibili predittori indiretti della rinuncia alle cure mediche generiche, in quanto possono riflettere condizioni di vulnerabilità o priorità percepite che non coincidono necessariamente con una rinuncia globale al sistema di cure, ma ne rappresentano potenziali segnali premonitori."
dati_clean <- ehis %>%
  select(UN2A, AGE_CLA75, SEX, RIP, HS2, CITIZEN2, WGT,IC1,BMI_CLASS,FUMO, HATLEVEL4,  HHTYPE, HHINCOME, HS2, CD2, MD1, problemi_accesso_cure, PE1,PE2,SS1, EVDOL,dieta_cat,UN2B,UN2C,UN2D, indice_gruppi
  )  %>%
  filter(complete.cases(.))  %>%
  mutate(across(-WGT, as.factor)) %>%  # tutte le variabili tranne WGT diventano fattori
  mutate(y_adj = as.numeric(UN2A) - 1) %>%  # crea target numerico da UN2A
  select(-UN2A)  # rimuove UN2A

#Cerchiamo di capire se c'è collinearità
# Carica i pacchetti necessari
library(DescTools)   # Per Cramér's V
library(corrplot)    # Per visualizzazione

# Inserisci i nomi delle variabili esplicative (escludendo la target)
vars_cat <- c("AGE_CLA75", "SEX", "RIP", "HS2", "CITIZEN2", "IC1", "BMI_CLASS",
              "FUMO", "HATLEVEL4", "HHTYPE", "HHINCOME", "CD2",
           "MD1", "problemi_accesso_cure", "PE1", "PE2", "SS1", "EVDOL", "dieta_cat", "UN2B", "UN2C", "UN2D", "indice_gruppi")

# Crea una matrice vuota
cramer_matrix <- matrix(NA, nrow = length(vars_cat), ncol = length(vars_cat),
                        dimnames = list(vars_cat, vars_cat))

# Calcola Cramér's V per ogni coppia
for (i in 1:length(vars_cat)) {
  for (j in 1:length(vars_cat)) {
    tbl <- table(dati_clean[[vars_cat[i]]], dati_clean[[vars_cat[j]]])
    cramer_matrix[i, j] <- CramerV(tbl)
  }
}

# Visualizza la matrice in modo leggibile
corrplot(cramer_matrix, method = "color", is.corr = FALSE,
         tl.cex = 0.7, number.cex = 0.7, mar = c(0,0,1,0),
         title = "Cramér’s V tra variabili categoriche")

#preparazione datatset per stimare il modello
X <- model.matrix(y_adj ~ . - WGT, data = dati_clean)[, -1]
y <- dati_clean$y_adj
#xgboosting
set.seed(123)
# 60% Train, 20% Calibration, 20% Test
idx <- sample(1:nrow(dati_clean))
n <- nrow(dati_clean)
train_cal_idx <- idx[1:round(0.8 * n)]
test_idx <- idx[(round(0.8 * n) + 1):n]
#
#
train_cal <- dati_clean[train_cal_idx, ]
test <- dati_clean[test_idx, ]
#dividiamo in folds
folds<-createFolds(train_cal_idx, k =4, list = TRUE, returnTrain = FALSE) #indici


coverage_vec<-c()
dim_mean_set_vec<-c()

for (i in 1:4) {
  cal_idx<- folds[[i]]
  train_idx <- setdiff(1:nrow(train_cal),cal_idx)
  
  train <- train_cal[train_idx, ]
  cal <- train_cal[cal_idx, ]
  
  dtrain <- xgb.DMatrix(data = as.matrix(X[train_idx,]), label = y[train_idx])
  dcal<-xgb.DMatrix(data = X[cal_idx, ], label = y[cal_idx])
  dtest  <- xgb.DMatrix(data = X[test_idx, ], label = y[test_idx])

  model <- xgboost(data = dtrain, objective = "multi:softprob", num_class = 3, nrounds = 100, verbose = 0)
  
  cal_probs <- predict(model, dcal)
  cal_probs <- matrix(cal_probs, ncol = 3, byrow = TRUE)
  
  # Nonconformity score = 1 - probabilità della classe vera
  cal_true_probs <- sapply(1:nrow(cal), function(i) cal_probs[i, cal$y_adj[i] + 1])
  cal_scores <- 1 - cal_true_probs
  
  alpha <- 0.05  # 95% confidence
  threshold <- quantile(cal_scores, probs = 1 - alpha, type = 1)
  
  
  test_probs <- predict(model, dtest)
  test_probs <- matrix(test_probs, ncol = 3, byrow = TRUE)
  pred_classes<-max.col(test_probs)-1
  

  # Mondrian ICP con alpha = 0.05
  prediction_sets <- mondrian_icp(cal_probs, y[cal_idx], test_probs, alpha = 0.05)
  head(prediction_sets)
  # True label su test set
  true_labels <- y[test_idx]
  
  # Calcolo coverage e dimensione media dei set predetti
  covered <- sapply(1:length(prediction_sets), function(i) {
    prediction_sets[[i]][true_labels[i] + 1]  # +1 per etichette 0-based
  })
  
  avg_set_size <- sapply(prediction_sets, sum) %>% mean()
  
  cat("Coverage:", mean(covered), "\n")
  cat("Dimensione media set predizione:", avg_set_size, "\n")
  coverage_vec[i]<-mean(covered)
  dim_mean_set_vec[i]<-avg_set_size
  cm<-confusionMatrix(as.factor(pred_classes),as.factor(true_labels))
  print(cm)
  # Recall per tutte le classi
  recall <- cm$byClass[, "Sensitivity"]
  print(recall)
  precision <- cm$byClass[,"Precision"]

  
  f1 <- 2 * (precision * recall) / (precision + recall)
  f1
  print("Metriche Pesate:")
  # Calcolo delle metriche pesate

  p<-confusion_matrix_weighted(as.factor(true_labels), as.factor(pred_classes), w = test$WGT)
  cm_w <- confusionMatrix(as.matrix(p))
  print(cm_w)
  
}


mean(coverage_vec)
mean(avg_set_size)

#LOGISTICO
# Split
set.seed(123)
idx <- sample(1:nrow(dati_clean))
n <- nrow(dati_clean)
train_cal_idx <- idx[1:round(0.8 * n)]
test_idx <- idx[(round(0.8 * n) + 1):n]

train_cal <- dati_clean[train_cal_idx, ]
test <- dati_clean[test_idx, ]

# Crea folds
folds <- createFolds(train_cal$y_adj, k = 4, list = TRUE)

coverage_vec <- c()
dim_mean_set_vec <- c()
library(broom)
for (i in 1:4) {
  cal_idx <- folds[[i]]
  train_idx <- setdiff(1:nrow(train_cal), cal_idx)
  
  train <- train_cal[train_idx, ]
  cal <- train_cal[cal_idx, ]
  
  # Fit modello logit multinomiale
  model <- multinom(y_adj ~ . -WGT, data = train, trace = FALSE)
  
  
  # Predici probabilità su validation
  cal_probs <- predict(model, newdata = cal, type = "probs")
  
  # Nonconformity score = 1 - prob della classe vera
  cal_true <- as.numeric(cal$y_adj)
  cal_true_probs <- sapply(1:nrow(cal), function(i) {
    class_label <- as.character(cal_true[i])  # Converti 0 → "0"
    cal_probs[i, class_label]
  })
  
  cal_scores <- 1 - cal_true_probs
  
  # Soglia conformal
  alpha <- 0.05
  threshold <- quantile(cal_scores, probs = 1 - alpha, type = 1)
  
  # Probabilità predette su test set
  test_probs <- predict(model, newdata = test, type = "probs")
  pred_classes <- apply(test_probs, 1, function(p) which.max(p))-1
  
  true_labels <- as.character(test$y_adj)
  
  # Mondrian ICP
  prediction_sets<- lapply(1:nrow(test_probs), function(i) {
    1 * (1 - test_probs[i, ] <= threshold)
  })
  
  covered <- sapply(1:length(prediction_sets), function(i) {
    prediction_sets[[i]][true_labels[i]] == 1
  })
  
  avg_set_size <- sapply(prediction_sets, sum) %>% mean()
  
  cat("Fold", i, "\n")
  cat("Coverage:", mean(covered), "\n")
  cat("Average prediction set size:", avg_set_size, "\n")
  
  coverage_vec[i] <- mean(covered)
  dim_mean_set_vec[i] <- avg_set_size
  
  # Confusion matrix
  cm <- confusionMatrix(as.factor(pred_classes), as.factor(true_labels))
  print(cm)
  
  # Recall e precision per classe
  recall <- cm$byClass[, "Sensitivity"]
  precision <- cm$byClass[, "Precision"]
  
  f1 <- 2 * (precision * recall) / (precision + recall)
  print("F1 scores:")
  print(f1)
  
  # Calcolo pesato
  if (!require("MLmetrics")) install.packages("MLmetrics")
  library(MLmetrics)
  weighted_f1 <- F1_Score(y_pred = as.factor(pred_classes), y_true = as.factor(true_labels), positive = NULL)
  print(paste("Weighted F1 score:", round(weighted_f1, 3)))
}

cat("Media Coverage:", mean(coverage_vec), "\n")
cat("Media dimensione set:", mean(dim_mean_set_vec), "\n")
library(broom)
library(knitr)
m<-tidy(model)
m<- m %>%
  mutate(estimate = round(estimate, 2),
         std.error = round(std.error, 2),
         statistic = round(statistic, 2),
         p.value = round(p.value, 2)) 
