#librerie
library(ggplot2)
library(dplyr)
library(openxlsx)
library(stringr)
library(readxl)

ehis <- read.delim("C:/Users/apant/Desktop/Statistical Learning/progetto/EHIS_Microdati_2019.txt")

#Target UN2A: Rinuncia ad esami o cure mediche
ehis$UN2A[ehis$UN2A == -3] <- NA
table(ehis$UN2A)

##Rinuncia alle cure mediche per classe di età
# Etichette leggibili per le classi di età
age_labels <- c("15-17", "18-24", "25-34", "35-44", "45-49", "50-54",
                "55-59", "60-64", "65-69", "70-74", "75+")

# Etichette leggibili per UN2A
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Crea una copia con fattori etichettati
df <- ehis %>%
  mutate(
    AGE_CLASS = factor(AGE_CLA75, levels = 1:11, labels = age_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(UN2A_LABEL), !is.na(AGE_CLASS))  # rimuove i NA

ggplot(df, aes(x = AGE_CLASS, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +  # Usa "fill" per percentuali
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Distribuzione della rinuncia alle cure mediche per classe di età",
    x = "Classe di età",
    y = "Percentuale",
    fill = "Ha rinunciaro a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_brewer(palette = "Set2")

##Rinuncia alle cure mediche per sesso
# Etichette leggibili per il genere
sex_labels <- c("1" = "Maschi", "2" = "Femmine")

# Crea una copia con fattori etichettati
df <- ehis %>%
  mutate(
    SEX_LABEL = factor(SEX, levels = 1:2, labels = sex_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(UN2A_LABEL), !is.na(SEX_LABEL))  # rimuove i NA

# Crea il grafico
ggplot(df, aes(x = SEX_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +  # Usa "fill" per percentuali
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Distribuzione della rinuncia alle cure mediche per genere",
    x = "Genere",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_brewer(palette = "Set2")

#rinuncia alle cure mediche per genere e fasce d'età
age_labels <- c("15-17", "18-24", "25-34", "35-44", "45-49", "50-54",
                "55-59", "60-64", "65-69", "70-74", "75+")
sex_labels <- c("1" = "Maschi", "2" = "Femmine")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Dataframe con etichette fattoriali
df <- ehis %>%
  mutate(
    AGE_CLASS = factor(AGE_CLA75, levels = 1:11, labels = age_labels),
    SEX_LABEL = factor(SEX, levels = 1:2, labels = sex_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(AGE_CLASS), !is.na(SEX_LABEL), !is.na(UN2A_LABEL))

# Grafico con facet
ggplot(df, aes(x = AGE_CLASS, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ SEX_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Distribuzione della rinuncia alle cure mediche per età e genere",
    x = "Classe di età",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_brewer(palette = "Set2")

#Valutiamo come il prendersi cura di altre persone (IC1) incide sulla rinuncia alle cure
table(ehis$IC1)
ehis$IC1[ehis$IC1 == -3|ehis$IC1 == -1] <- NA

# Etichette leggibili per le variabili
care_labels <- c("1" = "Sì", "2" = "No")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Crea una copia del dataframe con fattori etichettati
df <- ehis %>%
  mutate(
    CARE_LABEL = factor(IC1, levels = 1:2, labels = care_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(CARE_LABEL), !is.na(UN2A_LABEL))  # Rimuove eventuali NA

# Crea il grafico
ggplot(df, aes(x = CARE_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +  # Percentuali per gruppo
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Distribuzione della rinuncia alle cure mediche\nin base al fatto di prendersi cura di altri",
    x = "Si prende cura o assiste una o più persone almeno una volta la settimana?",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_brewer(palette = "Set2") +
  theme(axis.text.x = element_text(size = 12))

#Distribuzione della rinuncia alle cure per genere e in base al fatto di prendersi cura di altri
# Etichette leggibili
sex_labels <- c("1" = "Maschi", "2" = "Femmine")
care_labels <- c("1" = "Sì", "2" = "No")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Dataframe con fattori
df <- ehis %>%
  mutate(
    SEX_LABEL = factor(SEX, levels = 1:2, labels = sex_labels),
    CARE_LABEL = factor(IC1, levels = 1:2, labels = care_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(SEX_LABEL), !is.na(CARE_LABEL), !is.na(UN2A_LABEL))

# Grafico con faceting per genere
ggplot(df, aes(x = CARE_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ SEX_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Rinuncia alle cure mediche in base a genere e cura verso altri",
    x = "Si prende cura di altri?",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_brewer(palette = "Set2") +
  theme(axis.text.x = element_text(size = 12))

#Distribuzione della rinuncia alle cure per fascia d'età, genere e in base al fatto di prendersi cura di altri
# Etichette leggibili
sex_labels <- c("1" = "Maschi", "2" = "Femmine")
care_labels <- c("1" = "Sì", "2" = "No")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")
age_labels <- c("15-17", "18-24", "25-34", "35-44", "45-49", "50-54",
                "55-59", "60-64", "65-69", "70-74", "75+")

# Prepara il dataset
df <- ehis %>%
  mutate(
    SEX_LABEL = factor(SEX, levels = 1:2, labels = sex_labels),
    CARE_LABEL = factor(IC1, levels = 1:2, labels = care_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels),
    AGE_CLASS = factor(AGE_CLA75, levels = 1:11, labels = age_labels)
  ) %>%
  filter(!is.na(SEX_LABEL), !is.na(CARE_LABEL), !is.na(UN2A_LABEL), !is.na(AGE_CLASS))

# Crea il grafico
ggplot(df, aes(x = CARE_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_grid(rows = vars(SEX_LABEL), cols = vars(AGE_CLASS)) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Rinuncia alle cure mediche per genere, età e cura verso altri",
    x = "Si prende cura di altri?",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1),
    strip.text.x = element_text(size = 10),
    strip.text.y = element_text(size = 11)
  ) +
  scale_fill_brewer(palette = "Set2")

##Valutiamo se le malattie croniche (HS2) incidono in qualche modo nella rinuncia alle cure
table(ehis$HS2)
ehis$HS2[ehis$HS2 == -1] <- NA

# Etichette leggibili
chronic_labels <- c("1" = "Sì", "2" = "No")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Prepara il dataset
df <- ehis %>%
  mutate(
    CHRONIC_LABEL = factor(HS2, levels = 1:2, labels = chronic_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(CHRONIC_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = CHRONIC_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +  # percentuali
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Distribuzione della rinuncia alle cure mediche\nin base alla presenza di malattie croniche",
    x = "Ha malattie croniche?",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_brewer(palette = "Set2") +
  theme(axis.text.x = element_text(size = 12))

#Distribuzione rinuncia alle cure in base al reddito (HHINCOME)
table(ehis$HHINCOME)
# Etichette leggibili
chronic_labels <- c("1" = "Sì", "2" = "No")
income_labels <- c("1" = "I quintile", "2" = "II quintile", "3" = "III quintile",
                   "4" = "IV quintile", "5" = "V quintile")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Prepara il dataset
df <- ehis %>%
  mutate(
    CHRONIC_LABEL = factor(HS2, levels = 1:2, labels = chronic_labels),
    INCOME_LABEL = factor(HHINCOME, levels = 1:5, labels = income_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(CHRONIC_LABEL), !is.na(INCOME_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = INCOME_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ CHRONIC_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Rinuncia alle cure mediche per reddito e presenza di malattie croniche",
    x = "Quintile di reddito",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
  scale_fill_brewer(palette = "Set2")

#Distribuzione rinuncia alle cure in base alla cittadinanza
table(ehis$CITIZEN2)
ehis$CITIZEN2[ehis$CITIZEN2 == -1] <- NA

# Etichette leggibili
citizen_labels <- c("10" = "Italiana", "20" = "Straniera")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Prepara il dataset
df <- ehis %>%
  mutate(
    CITIZEN_LABEL = factor(CITIZEN2, levels = c(10, 20), labels = citizen_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(CITIZEN_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = CITIZEN_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +  # percentuali
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Rinuncia alle cure mediche per cittadinanza",
    x = "Cittadinanza",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_brewer(palette = "Set2")

##Distribuzione rinuncia alle cure mediche per componenti in famiglia (HHNBPERS)
table(ehis$HHNBPERS)

# Etichette leggibili
ncomp_labels <- c("1" = "1", "2" = "2", "3" = "3", "4" = "4", 
                  "5" = "5", "6" = "6", "7" = "7 o più")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Prepara il dataset
df <- ehis %>%
  mutate(
    COMPONENTI_LABEL = factor(HHNBPERS, levels = names(ncomp_labels), labels = ncomp_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(COMPONENTI_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = COMPONENTI_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Rinuncia alle cure mediche per numero di componenti della famiglia",
    x = "Numero di componenti",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_brewer(palette = "Set2") +
  theme(axis.text.x = element_text(size = 12))

#Distribuzione rinuncia alle cure per componenti in famiglia e reddito
# Etichette leggibili
ncomp_labels <- c("1" = "1", "2" = "2", "3" = "3", "4" = "4", 
                  "5" = "5", "6" = "6", "7" = "7 o più")
income_labels <- c("1" = "I quintile", "2" = "II quintile", "3" = "III quintile",
                   "4" = "IV quintile", "5" = "V quintile")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Prepara il dataset
df <- ehis %>%
  mutate(
    COMPONENTI_LABEL = factor(HHNBPERS, levels = names(ncomp_labels), labels = ncomp_labels),
    INCOME_LABEL = factor(HHINCOME, levels = 1:5, labels = income_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(COMPONENTI_LABEL), !is.na(INCOME_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = COMPONENTI_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  facet_wrap(~ INCOME_LABEL) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Rinuncia alle cure mediche per numero di componenti e quintile di reddito",
    x = "Numero di componenti della famiglia",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(size = 11)) +
  scale_fill_brewer(palette = "Set2")

#Distribuzione rinuncia alle cure per ripartizione geografica (RIP)
table(ehis$RIP)
# Etichette leggibili
rip_labels <- c("1" = "Nord-ovest", "2" = "Nord-est", "3" = "Centro", 
                "4" = "Sud", "5" = "Isole")
un2a_labels <- c("1" = "Sì", "2" = "No", "3" = "No, non ho avuto bisogno")

# Prepara il dataset
df <- ehis %>%
  mutate(
    RIP_LABEL = factor(RIP, levels = 1:5, labels = rip_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(RIP_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = RIP_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Rinuncia alle cure mediche per ripartizione geografica",
    x = "Ripartizione geografica",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(size = 12)) +
  scale_fill_brewer(palette = "Set2")

#Distribuzione rinuncia agli studi in base al titolo di studio (HATLEVEL4)
table(ehis$HATLEVEL4)
ehis$HATLEVEL4[ehis$HATLEVEL4 == -1] <- NA

# Etichette leggibili per titolo di studio
education_labels <- c(
  "1" = "Elementare o nessun titolo",
  "2" = "Licenza media",
  "3" = "Diploma o qualifica",
  "4" = "Titolo post-secondario o universitario"
)

un2a_labels <- c(
  "1" = "Sì",
  "2" = "No",
  "3" = "No, non ho avuto bisogno"
)

# Prepara il dataset
df <- ehis %>%
  mutate(
    EDUCATION_LABEL = factor(HATLEVEL4, levels = 1:4, labels = education_labels),
    UN2A_LABEL = factor(UN2A, levels = 1:3, labels = un2a_labels)
  ) %>%
  filter(!is.na(EDUCATION_LABEL), !is.na(UN2A_LABEL))

# Crea il grafico
ggplot(df, aes(x = EDUCATION_LABEL, fill = UN2A_LABEL)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Rinuncia alle cure mediche per titolo di studio",
    x = "Titolo di studio",
    y = "Percentuale",
    fill = "Ha rinunciato a cure mediche?"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(size = 12, angle = 15, hjust = 1)) +
  scale_fill_brewer(palette = "Set2")


##Alle domande sulla salute mentale rispondono solo coloro che hanno più di 15 anni 
#MH1A: Scarso interesse o piacere nel fare le cose 
table(ehis$MH1A)
#MH1B: Sentirsi giù, depresso o disperato 
#MH1C: Avere problemi ad addormentarsi o a dormire tutta la notte senza svegliarsi, o dormire troppo
#MH1D: Sentirsi stanco o avere poca energia 
#MH1E: Scarso appetito o mangiare troppo 
#MH1F: Provare una scarsa opinione di sé, sentirsi un fallimento oppure sentire di aver deluso se stesso o la sua famiglia 
#MH1G: Difficoltà a concentrarsi su qualcosa, ad esempio leggere il giornale o guardare la televisione 
#MH1D: Muoversi o parlare così lentamente da poter essere notato da altre persone, oppure avvertire irrequietezza o agitazione insolita 
mh_vars <- c("MH1A", "MH1B", "MH1C", "MH1D", "MH1E", "MH1F", "MH1G", "MH1H")

dati_mentale<-ehis[,mh_vars]
table(dati_mentale$MH1H)
dati_mentale[dati_mentale == -3] <- NA

# Calcola la varianza riga per riga, ignorando gli NA
varianze_riga <- apply(dati_mentale, 1, var, na.rm = TRUE)
summary(varianze_riga)
#coerente
#in generale le persone non variano molto tra item, probabilmente risposte coerenti.
dati_mentale$indice_mentale <- rowSums(dati_mentale[mh_vars], na.rm = TRUE)

summary(dati_mentale$indice_mentale)
hist(dati_mentale$indice_mentale, breaks = 20)

#gli 0 sono NA, li rimuovo
hist(dati_mentale$indice_mentale[dati_mentale$indice_mentale!=0], breaks = 20)
# Assicurati che siano fattori con etichette leggibili
dati_mentale$y<-ehis$UN2A


dati_mentale$y<-factor(dati_mentale$y, labels = c("Si", "No","No, non ne ho avuto bisogno"))

ggplot(subset(dati_mentale, !is.na(y) & !is.na(indice_mentale)), 
       aes(x = indice_mentale, fill = y)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Percentuale di rinuncia alle cure per indice mentale",
    y = "Percentuale",
    x = "Indice Mentale",
    fill = "Rinuncia alle cure"
  ) +
  theme_minimal()


# 1. Trasforma 0 in NA
dati_mentale$indice_mentale[dati_mentale$indice_mentale == 0] <- NA


# 4. Assegna le altre classi con condizioni
dati_mentale$indice_gruppi[dati_mentale$indice_mentale >= 4 & dati_mentale$indice_mentale <= 11] <- "Basso"
dati_mentale$indice_gruppi[dati_mentale$indice_mentale >= 12 & dati_mentale$indice_mentale <= 20] <- "Medio-Basso"
dati_mentale$indice_gruppi[dati_mentale$indice_mentale >= 21 & dati_mentale$indice_mentale <= 26] <- "Medio-Alto"
dati_mentale$indice_gruppi[dati_mentale$indice_mentale >= 27 & dati_mentale$indice_mentale <= 32] <- "Alto"


dati_mentale$indice_gruppi <- factor(
  dati_mentale$indice_gruppi,
  levels = c(
    "Basso", "Medio-Basso", "Medio-Alto", "Alto")
)
ehis$indice_mentale<-dati_mentale$indice_gruppi


ggplot(subset(dati_mentale, !is.na(y) & !is.na(indice_gruppi)), 
       aes(x = indice_gruppi, fill = y)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Percentuale di rinuncia alle cure per livello di disagio mentale",
    y = "Percentuale",
    x = "Livello di disagio mentale",
    fill = "Rinuncia alle cure"
  ) +
  theme_minimal()


ehis[ehis == -3] <- NA
ehis[ehis == -1] <- NA
ehis[ehis == -2] <- NA


# Caricamento librerie necessarie
library(dplyr)
library(nnet)      # per multinomial logit
library(survey)    # per gestire i pesi campionari
library(caret)     # per split stratificato

# Supponiamo che i tuoi dati siano in 'ehis' con colonna dei pesi 'WGT'
# e variabile dipendente 'outcome' (sostituisci con il nome effettivo)

# ===== FUNZIONE PER SPLIT PROPORZIONALE AI PESI =====
weighted_split <- function(data, weight_col, outcome_col, train_prop = 0.7, seed = 123) {
  
  set.seed(seed)
  
  # Creare strati basati sui quantili dei pesi per mantenere distribuzione simile
  data$weight_strata <- cut(data[[weight_col]], 
                            breaks = quantile(data[[weight_col]], 
                                              probs = seq(0, 1, 0.1), 
                                              na.rm = TRUE),
                            include.lowest = TRUE,
                            labels = paste0("W", 1:10))
  
  # Creare strati combinati: outcome + peso
  data$combined_strata <- paste(data[[outcome_col]], data$weight_strata, sep = "_")
  
  # Split stratificato
  train_indices <- createDataPartition(data$combined_strata, 
                                       p = train_prop, 
                                       list = FALSE)
  
  train_data <- data[train_indices, ]
  test_data <- data[-train_indices, ]
  
  # Rimuovere le colonne ausiliarie
  train_data$weight_strata <- NULL
  train_data$combined_strata <- NULL
  test_data$weight_strata <- NULL
  test_data$combined_strata <- NULL
  
  return(list(train = train_data, test = test_data))
}

# ===== APPLICAZIONE DELLO SPLIT =====
# Split con la tua variabile dipendente UN2A
split_data <- weighted_split(ehis, 
                             weight_col = "WGT", 
                             outcome_col = "UN2A", 
                             train_prop = 0.7)

train_set <- split_data$train
test_set <- split_data$test

# Verifica della distribuzione dei pesi
cat("Distribuzione pesi nel training set:\n")
summary(train_set$WGT)
cat("\nDistribuzione pesi nel test set:\n")
summary(test_set$WGT)

# Confronto delle distribuzioni
cat("\nConfronto quantili:\n")
rbind(
  Train = quantile(train_set$WGT, probs = c(0.25, 0.5, 0.75)),
  Test = quantile(test_set$WGT, probs = c(0.25, 0.5, 0.75)),
  Original = quantile(ehis$WGT, probs = c(0.25, 0.5, 0.75))
)
# 

# ===== MULTINOMIAL LOGIT CON PESI =====
# Metodo 1: Usando nnet con pesi
# La tua formula per il multinomial logit


model_formula <- as.formula("as.factor(UN2A) ~ as.factor(AGE_CLA75) + as.factor(indice_mentale) + as.factor(SEX) + as.factor(RIP) + as.factor(HHNBPERS) + as.factor(HHINCOME) + as.factor(IC1) + as.factor(HS2) + as.factor(CITIZEN2)+as.factor(IC1)*as.factor(SEX)+as.factor(AGE_CLA75)*as.factor(SEX)+as.factor(ASS_SAN)+as.factor(FUMO)+as.factor(	BMI_CLASS)")

# Modello multinomial logit pesato
multinom_model <- multinom(model_formula, 
                           data = train_set, 
                           weights = train_set$WGT,
                           trace = FALSE)

# Summary del modello
library(broom)
nrow(train_set)
nrow(test_set)
tidy_model <- tidy(multinom_model)

print(tidy_model)
var<-all.vars(model_formula)


righe_con_na <- !complete.cases(train_set[train_set$PROXY!=2,var])
sum(righe_con_na)
nrow(train_set[train_set$PROXY!=2,])

righe_con_na <- !complete.cases(test_set[,var])
sum(righe_con_na)
nrow(test_set)

# ===== PREDIZIONI E VALUTAZIONE =====
# Predizioni sul test set
predictions <- predict(multinom_model, newdata = test_set, type = "class")
probabilities <- predict(multinom_model, newdata = test_set, type = "probs")
library(caret)
confusionMatrix(predictions, as.factor(test_set$UN2A))




#XG BOOSTING

# Rimuovi righe con NA in variabili predittive e target
vars_needed <-var

train_clean <- train_set[complete.cases(train_set[, vars_needed]), ]

# Riformula y e X
train_clean$UN2A_num <- as.numeric(as.factor(train_clean$UN2A)) - 1
y <- train_clean$UN2A_num
w <- train_clean$WGT

X <- model.matrix(~  AGE_CLA75 + indice_mentale + SEX + RIP + HHNBPERS + HHINCOME + 
                    IC1 + HS2 + CITIZEN2 + IC1:SEX + AGE_CLA75:SEX + 
                    ASS_SAN + FUMO + BMI_CLASS,
                  data = train_clean)[, -1]

# Ora le dimensioni dovrebbero combaciare
dtrain <- xgb.DMatrix(data = X, label = y, weight = w)

model_xgb <- xgboost(
  data = dtrain,
  objective = "multi:softprob",  # per probabilità multiclass
  num_class = num_class,
  nrounds = 100,
  max_depth = 6,
  eta = 0.1,
  eval_metric = "mlogloss",
  verbose = 1
)


vars_needed <-var[-1]

test_clean <- test_set[complete.cases(test_set[, vars_needed]), ]
test_clean$UN2A_num <- as.numeric(as.factor(test_clean$UN2A)) - 1
model_formula
X_test <- model.matrix(~  AGE_CLA75 + indice_mentale + SEX + RIP + HHNBPERS + HHINCOME + 
                         IC1 + HS2 + CITIZEN2 + IC1:SEX + AGE_CLA75:SEX + 
                         ASS_SAN + FUMO + BMI_CLASS,
                       data = test_clean)[, -1]


# X_test è la matrice numerica dei dati di test, come sopra
pred_probs <- predict(model_xgb, newdata = X_test)
pred_matrix <- matrix(pred_probs, ncol = num_class, byrow = TRUE)
pred_class <- max.col(pred_matrix) - 1  # classi da 0 a (num_class - 1)


# solo se vuoi valutare predizioni
y_test <- test_clean$UN2A_num
# Confusion matrix
table(Predicted = pred_class, Actual = y_test)
confusionMatrix(as.factor(pred_class),as.factor(y_test))




# # ===== CREAZIONE OGGETTI SURVEY =====
# Creazione di design survey objects per gestire correttamente i pesi
train_design <- svydesign(ids = ~HHID2,
                          weights = ~WGT,
                          data = train_set)

test_design <- svydesign(ids = ~HHID2,
                         weights = ~WGT,
                         data = test_set)
library(svyVGAM)
modello_survey<- svy_vglm(model_formula,
                    family=multinomial(refLevel=1), design=train_design)



# rimuoviamo le righe con NA nelle variabili del modello
vars_needed <- all.vars(model_formula)
# --- Salva l'indice delle righe originali prima del subset ---
test_set$orig_row <- seq_len(nrow(test_set))

# Subset delle righe complete per la predizione
test_set_valid <- test_set[complete.cases(test_set[, vars_needed]), ]

# --- PREDIZIONE ---
pred_probs <- predict(modello_survey$fit, newdata = test_set_valid, type = "response")
pred_class <- colnames(pred_probs)[max.col(pred_probs)]
test_set_valid$predicted_UN2A <- factor(pred_class, levels = colnames(pred_probs))

# --- RIASSEGNA NEL TEST SET COMPLETO ---
test_set$predicted_UN2A <- NA
test_set$predicted_UN2A[test_set_valid$orig_row] <- as.character(test_set_valid$predicted_UN2A)

# --- Rimuovi colonna temporanea ---
test_set$orig_row <- NULL

# Uniforma i livelli
train_set$UN2A <- factor(train_set$UN2A)
livelli_un2a <- levels(train_set$UN2A)

test_set$UN2A <- factor(test_set$UN2A, levels = livelli_un2a)
test_set$predicted_UN2A <- factor(test_set$predicted_UN2A, levels = livelli_un2a)

# Ricrea design per valutazione
test_design_pred <- svydesign(ids = ~HHID2, weights = ~WGT, data = test_set)

# Confusion matrix pesata
svy_conf_mat <- svytable(~ UN2A + predicted_UN2A, design = test_design_pred)
print(svy_conf_mat)

# --- STEP 7: Accuratezza pesata totale ---
weighted_accuracy <- sum(diag(svy_conf_mat)) / sum(svy_conf_mat)
cat("\nWeighted Accuracy:", round(weighted_accuracy, 4), "\n")

# --- STEP 8 (opzionale): Accuratezza per classe ---
class_accuracy <- diag(svy_conf_mat) / rowSums(svy_conf_mat)
print(round(class_accuracy, 3))




# Calcola frequenze inverse
# 1. Calcola i pesi inversi solo sulle classi valide
# Calcola frequenze inverse
train_set_valid <- train_set[!is.na(train_set$UN2A), ]
class_weights <- 1 / table(train_set_valid$UN2A)
# Applica i pesi corretti
train_set_valid$class_wgt <- class_weights[as.character(train_set_valid$UN2A)]
library(survey)

train_design_bal <- svydesign(
  ids = ~HHID2,
  weights = ~WGT * class_wgt,
  data = train_set_valid
)

modello_survey_bal <- svy_vglm(
  model_formula,
  family = multinomial(refLevel = 1),
  design = train_design_bal
)
library(survey)
library(svyVGAM)

# Filtra righe complete per train (senza NA in UN2A e covariate)
train_set_valid <- train_set[!is.na(train_set$UN2A), ]

# Calcola pesi di classe inversi
class_weights <- 1 / table(train_set_valid$UN2A)

# Assegna pesi di classe
train_set_valid$class_wgt <- class_weights[as.character(train_set_valid$UN2A)]

# Design bilanciato
train_design_bal <- svydesign(ids = ~HHID2,
                              weights = ~WGT * class_wgt,
                              data = train_set_valid)
performance_on_test <- function(modello_survey, test_set, model_name = "Modello") {
  cat(paste0("\n===== Valutazione: ", model_name, " =====\n"))
  
  # --- Step 1: Rimuovi righe incomplete ---
  vars_needed <- all.vars(model_formula)
  test_set$orig_row <- seq_len(nrow(test_set))
  
  test_set_valid <- test_set[complete.cases(test_set[, vars_needed]), ]
  
  # --- Step 2: Predizione ---
  pred_probs <- predict(modello_survey$fit, newdata = test_set_valid, type = "response")
  pred_class <- colnames(pred_probs)[max.col(pred_probs)]
  test_set_valid$predicted_UN2A <- factor(pred_class, levels = colnames(pred_probs))
  
  # --- Step 3: Riporta le predizioni nel test_set completo ---
  test_set$predicted_UN2A <- NA
  test_set$predicted_UN2A[test_set_valid$orig_row] <- as.character(test_set_valid$predicted_UN2A)
  test_set$orig_row <- NULL
  
  # --- Step 4: Uniforma livelli ---
  train_set$UN2A <- factor(train_set$UN2A)
  livelli_un2a <- levels(train_set$UN2A)
  test_set$UN2A <- factor(test_set$UN2A, levels = livelli_un2a)
  test_set$predicted_UN2A <- factor(test_set$predicted_UN2A, levels = livelli_un2a)
  
  # --- Step 5: Crea survey design su test set con predizioni ---
  test_design_pred <- svydesign(ids = ~HHID2, weights = ~WGT, data = test_set)
  
  # --- Step 6: Confusion matrix pesata ---
  svy_conf_mat <- svytable(~ UN2A + predicted_UN2A, design = test_design_pred)
  print(round(svy_conf_mat))
  
  # --- Step 7: Accuratezza pesata totale ---
  weighted_accuracy <- sum(diag(svy_conf_mat)) / sum(svy_conf_mat)
  cat("\nWeighted Accuracy:", round(weighted_accuracy, 4), "\n")
  
  # --- Step 8: Accuratezza per classe ---
  class_accuracy <- diag(svy_conf_mat) / rowSums(svy_conf_mat)
  cat("Class Accuracy:\n")
  print(round(class_accuracy, 3))
  
  # --- Output come lista ---
  return(list(
    confusion_matrix = svy_conf_mat,
    weighted_accuracy = weighted_accuracy,
    class_accuracy = class_accuracy
  ))
}

perf_orig <- performance_on_test(modello_survey, test_set, "Originale")
perf_bal <- performance_on_test(modello_survey_bal, test_set, "Bilanciato")


