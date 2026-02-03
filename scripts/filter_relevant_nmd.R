#!/usr/bin/env Rscript
# ==============================================================================
# Script R : Filtrage des articles pertinents NMD
# Applique un filtre de pertinence sur les nouveaux articles
# ==============================================================================

library(dplyr)
library(stringr)

# Charger les nouveaux articles
articles <- read.csv("/home/ffer/article_audrey/output_search/pubmed_NOUVEAUX_articles.csv",
                     stringsAsFactors = FALSE)

cat("Articles en entrée:", nrow(articles), "\n\n")

# ==============================================================================
# DÉFINITION DES CRITÈRES DE PERTINENCE
# ==============================================================================

# Termes NMD SPÉCIFIQUES (doivent être présents dans titre, abstract OU MeSH)
termes_nmd_specifiques <- c(
  # Dystrophies musculaires
  "duchenne", "becker muscular", "facioscapulohumeral", "limb-girdle", "limb girdle",
  "emery-dreifuss", "oculopharyngeal", "congenital muscular dystrophy",
  "distal muscular dystrophy", "distal myopathy",

  # Dystrophie myotonique
  "myotonic dystrophy", "steinert disease", "steinert's disease",

  # Neurone moteur
  "amyotrophic lateral sclerosis", "motor neuron disease", "motor neurone disease",
  "spinal muscular atrophy", "kennedy disease", "spinal and bulbar muscular atrophy",
  "primary lateral sclerosis",

  # Jonction NM

  "myasthenia gravis", "lambert-eaton", "congenital myasthenic syndrome",

  # Neuropathies héréditaires
  "charcot-marie-tooth", "hereditary motor and sensory neuropathy",
  "hereditary neuropathy with liability", "HNPP",
  "chronic inflammatory demyelinating polyneuropathy",
  "chronic inflammatory demyelinating polyradiculoneuropathy",
  "guillain-barre syndrome", "guillain-barré",

  # Amyloidoses NM
  "transthyretin amyloidosis", "ATTR amyloidosis", "hereditary transthyretin",
  "familial amyloid polyneuropathy", "amyloid neuropathy",

  # Myopathies spécifiques
  "inflammatory myopathy", "inflammatory myopathies",
  "dermatomyositis", "polymyositis", "inclusion body myositis",
  "immune-mediated necrotizing myopathy", "antisynthetase syndrome",

  # Myopathies métaboliques
  "pompe disease", "acid maltase deficiency", "McArdle disease",
  "glycogen storage disease type II", "glycogen storage disease type V",

  # Myopathies congénitales
  "congenital myopathy", "congenital myopathies", "nemaline myopathy",
  "centronuclear myopathy", "myotubular myopathy",

  # Canalopathies
  "periodic paralysis", "myotonia congenita", "paramyotonia congenita",

  # Termes génériques NMD (moins spécifiques mais pertinents)
  "neuromuscular disease", "neuromuscular disorder", "muscular dystrophy"
)

# Termes d'EXCLUSION (articles à exclure si ces termes dominent)
termes_exclusion <- c(
  # Myopathies secondaires/médicamenteuses
  "statin-induced", "statin myopathy", "drug-induced myopathy",
  "toxic myopathy", "alcoholic myopathy",

  # Neuropathies non-NMD
  "diabetic neuropathy", "diabetic polyneuropathy",
  "HIV neuropathy", "HIV-associated",
  "chemotherapy-induced", "chemotherapy neuropathy",
  "alcoholic neuropathy",

  # ÉTUDES ANIMALES
  "animal model", "mouse model", "rat model", "mice", "mouse", "murine",
  "rodent", "canine", "dog model", "porcine", "pig model", "zebrafish",
  "drosophila", "c. elegans", "animal study", "animal experiment",
  "poultry", "chicken", "broiler", "bovine", "ovine",

  # Autres contextes non pertinents
  "in vitro", "cell line", "cell culture"
)

# ==============================================================================
# FONCTION DE FILTRAGE
# ==============================================================================

is_relevant_nmd <- function(title, abstract, mesh) {
  # Combiner tous les textes
  all_text <- tolower(paste(
    ifelse(is.na(title), "", title),
    ifelse(is.na(abstract), "", abstract),
    ifelse(is.na(mesh), "", mesh),
    sep = " "
  ))

  # Vérifier présence de termes NMD spécifiques
  has_nmd_term <- any(sapply(termes_nmd_specifiques, function(t) {
    grepl(tolower(t), all_text, fixed = TRUE)
  }))

  # Vérifier absence de termes d'exclusion dominants
  # (on tolère leur présence si un terme NMD spécifique est aussi présent)
  exclusion_count <- sum(sapply(termes_exclusion, function(t) {
    grepl(tolower(t), all_text, fixed = TRUE)
  }))

  # Logique de décision
  if (has_nmd_term) {
    return(TRUE)  # Pertinent si terme NMD spécifique trouvé
  } else if (exclusion_count > 0) {
    return(FALSE) # Non pertinent si exclusion sans NMD spécifique
  } else {
    return(FALSE) # Par défaut non pertinent si aucun terme NMD spécifique
  }
}

# ==============================================================================
# APPLICATION DU FILTRE
# ==============================================================================

cat("Application du filtre de pertinence...\n")

articles$is_relevant <- mapply(
  is_relevant_nmd,
  articles$Title,
  articles$Abstract,
  articles$MeSH
)

# Séparer les articles
articles_pertinents <- articles %>% filter(is_relevant == TRUE)
articles_exclus <- articles %>% filter(is_relevant == FALSE)

cat("\n--- RÉSULTATS DU FILTRAGE ---\n")
cat("Articles pertinents NMD :", nrow(articles_pertinents), "\n")
cat("Articles exclus         :", nrow(articles_exclus), "\n")

# ==============================================================================
# STATISTIQUES SUR LES ARTICLES PERTINENTS
# ==============================================================================

if (nrow(articles_pertinents) > 0) {
  cat("\n--- MALADIES DÉTECTÉES (articles pertinents) ---\n")

  keywords_check <- c(
    "duchenne", "becker", "facioscapulohumeral", "limb-girdle",
    "emery-dreifuss", "myotonic dystrophy",
    "amyotrophic lateral sclerosis", "motor neuron disease",
    "spinal muscular atrophy", "kennedy disease",
    "myasthenia gravis", "lambert-eaton",
    "charcot-marie-tooth", "guillain-barre",
    "dermatomyositis", "polymyositis", "inclusion body myositis",
    "pompe disease", "transthyretin", "familial amyloid",
    "periodic paralysis", "congenital myopathy"
  )

  for (kw in keywords_check) {
    n <- sum(grepl(kw, paste(articles_pertinents$Title, articles_pertinents$Abstract),
                   ignore.case = TRUE))
    if (n > 0) cat("  ", kw, ":", n, "\n")
  }

  cat("\n--- RÉPARTITION PAR ANNÉE ---\n")
  print(table(articles_pertinents$Year))

  cat("\n--- TOP 10 JOURNAUX ---\n")
  print(head(sort(table(articles_pertinents$Journal), decreasing = TRUE), 10))
}

# ==============================================================================
# EXPORT
# ==============================================================================

output_dir <- "/home/ffer/article_audrey/output_search"

# Export articles pertinents
write.csv(
  articles_pertinents %>% select(-is_relevant),
  file.path(output_dir, "pubmed_NOUVEAUX_PERTINENTS.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

# Export articles exclus (pour vérification)
write.csv(
  articles_exclus %>% select(-is_relevant),
  file.path(output_dir, "pubmed_NOUVEAUX_EXCLUS.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

# Mise à jour du rapport
rapport <- paste0(
  "=================================================================\n",
  "RAPPORT DE FILTRAGE - ARTICLES PERTINENTS NMD\n",
  "=================================================================\n",
  "\n",
  "Date : ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
  "\n",
  "--- RÉSULTATS ---\n",
  "Articles nouveaux (bruts)      : ", nrow(articles), "\n",
  "Articles PERTINENTS (filtrés)  : ", nrow(articles_pertinents), "\n",
  "Articles exclus                : ", nrow(articles_exclus), "\n",
  "\n",
  "--- CRITÈRES DE FILTRAGE ---\n",
  "Inclusion : présence d'au moins un terme NMD spécifique\n",
  "(duchenne, becker, myotonic dystrophy, ALS, SMA, myasthenia gravis, etc.)\n",
  "\n",
  "Exclusion : articles sur myopathies/neuropathies secondaires\n",
  "(diabétiques, médicamenteuses, HIV, etc.) sans terme NMD spécifique\n",
  "\n",
  "--- FICHIERS GÉNÉRÉS ---\n",
  "1. pubmed_NOUVEAUX_PERTINENTS.csv : ", nrow(articles_pertinents), " articles\n",
  "2. pubmed_NOUVEAUX_EXCLUS.csv     : ", nrow(articles_exclus), " articles (à vérifier)\n",
  "\n",
  "--- POUR LE REVIEWER ---\n",
  "X = ", nrow(articles_pertinents), " articles additionnels pertinents identifiés\n",
  "Y = [à compléter après screening manuel]\n",
  "\n",
  "=================================================================\n"
)

writeLines(rapport, file.path(output_dir, "rapport_filtrage.txt"))

cat("\n\n--- FICHIERS EXPORTÉS ---\n")
cat("- pubmed_NOUVEAUX_PERTINENTS.csv :", nrow(articles_pertinents), "articles\n")
cat("- pubmed_NOUVEAUX_EXCLUS.csv     :", nrow(articles_exclus), "articles\n")
cat("- rapport_filtrage.txt\n")

cat("\n>>> FILTRAGE TERMINÉ <<<\n")
