#!/usr/bin/env Rscript
# ==============================================================================
# R Script: Filtering relevant NMD articles
# Applies a relevance filter on new articles
# ==============================================================================

library(dplyr)
library(stringr)

# Load new articles
articles <- read.csv("/home/ffer/article_audrey/output_search/pubmed_NEW_articles.csv",
                     stringsAsFactors = FALSE)

cat("Input articles:", nrow(articles), "\n\n")

# ==============================================================================
# RELEVANCE CRITERIA DEFINITION
# ==============================================================================

# SPECIFIC NMD terms (must be present in title, abstract OR MeSH)
specific_nmd_terms <- c(
  # Muscular dystrophies
  "duchenne", "becker muscular", "facioscapulohumeral", "limb-girdle", "limb girdle",
  "emery-dreifuss", "oculopharyngeal", "congenital muscular dystrophy",
  "distal muscular dystrophy", "distal myopathy",

  # Myotonic dystrophy
  "myotonic dystrophy", "steinert disease", "steinert's disease",

  # Motor neuron
  "amyotrophic lateral sclerosis", "motor neuron disease", "motor neurone disease",
  "spinal muscular atrophy", "kennedy disease", "spinal and bulbar muscular atrophy",
  "primary lateral sclerosis",

  # NM junction

  "myasthenia gravis", "lambert-eaton", "congenital myasthenic syndrome",

  # Hereditary neuropathies
  "charcot-marie-tooth", "hereditary motor and sensory neuropathy",
  "hereditary neuropathy with liability", "HNPP",
  "chronic inflammatory demyelinating polyneuropathy",
  "chronic inflammatory demyelinating polyradiculoneuropathy",
  "guillain-barre syndrome", "guillain-barré",

  # NM amyloidosis
  "transthyretin amyloidosis", "ATTR amyloidosis", "hereditary transthyretin",
  "familial amyloid polyneuropathy", "amyloid neuropathy",

  # Specific myopathies
  "inflammatory myopathy", "inflammatory myopathies",
  "dermatomyositis", "polymyositis", "inclusion body myositis",
  "immune-mediated necrotizing myopathy", "antisynthetase syndrome",

  # Metabolic myopathies
  "pompe disease", "acid maltase deficiency", "McArdle disease",
  "glycogen storage disease type II", "glycogen storage disease type V",

  # Congenital myopathies
  "congenital myopathy", "congenital myopathies", "nemaline myopathy",
  "centronuclear myopathy", "myotubular myopathy",

  # Channelopathies
  "periodic paralysis", "myotonia congenita", "paramyotonia congenita",

  # Generic NMD terms (less specific but relevant)
  "neuromuscular disease", "neuromuscular disorder", "muscular dystrophy"
)

# EXCLUSION terms (articles to exclude if these terms dominate)
exclusion_terms <- c(
  # Secondary/drug-induced myopathies
  "statin-induced", "statin myopathy", "drug-induced myopathy",
  "toxic myopathy", "alcoholic myopathy",

  # Non-NMD neuropathies
  "diabetic neuropathy", "diabetic polyneuropathy",
  "HIV neuropathy", "HIV-associated",
  "chemotherapy-induced", "chemotherapy neuropathy",
  "alcoholic neuropathy",

  # ANIMAL STUDIES
  "animal model", "mouse model", "rat model", "mice", "mouse", "murine",
  "rodent", "canine", "dog model", "porcine", "pig model", "zebrafish",
  "drosophila", "c. elegans", "animal study", "animal experiment",
  "poultry", "chicken", "broiler", "bovine", "ovine",

  # Other non-relevant contexts
  "in vitro", "cell line", "cell culture"
)

# ==============================================================================
# FILTERING FUNCTION
# ==============================================================================

is_relevant_nmd <- function(title, abstract, mesh) {
  # Combine all text
  all_text <- tolower(paste(
    ifelse(is.na(title), "", title),
    ifelse(is.na(abstract), "", abstract),
    ifelse(is.na(mesh), "", mesh),
    sep = " "
  ))

  # Check presence of specific NMD terms
  has_nmd_term <- any(sapply(specific_nmd_terms, function(t) {
    grepl(tolower(t), all_text, fixed = TRUE)
  }))

  # Check absence of dominant exclusion terms
  # (tolerated if a specific NMD term is also present)
  exclusion_count <- sum(sapply(exclusion_terms, function(t) {
    grepl(tolower(t), all_text, fixed = TRUE)
  }))

  # Decision logic
  if (has_nmd_term) {
    return(TRUE)  # Relevant if specific NMD term found
  } else if (exclusion_count > 0) {
    return(FALSE) # Not relevant if exclusion without specific NMD
  } else {
    return(FALSE) # Default not relevant if no specific NMD term
  }
}

# ==============================================================================
# APPLY FILTER
# ==============================================================================

cat("Applying relevance filter...\n")

articles$is_relevant <- mapply(
  is_relevant_nmd,
  articles$Title,
  articles$Abstract,
  articles$MeSH
)

# Separate articles
relevant_articles <- articles %>% filter(is_relevant == TRUE)
excluded_articles <- articles %>% filter(is_relevant == FALSE)

cat("\n--- FILTERING RESULTS ---\n")
cat("Relevant NMD articles :", nrow(relevant_articles), "\n")
cat("Excluded articles     :", nrow(excluded_articles), "\n")

# ==============================================================================
# STATISTICS ON RELEVANT ARTICLES
# ==============================================================================

if (nrow(relevant_articles) > 0) {
  cat("\n--- DISEASES DETECTED (relevant articles) ---\n")

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
    n <- sum(grepl(kw, paste(relevant_articles$Title, relevant_articles$Abstract),
                   ignore.case = TRUE))
    if (n > 0) cat("  ", kw, ":", n, "\n")
  }

  cat("\n--- DISTRIBUTION BY YEAR ---\n")
  print(table(relevant_articles$Year))

  cat("\n--- TOP 10 JOURNALS ---\n")
  print(head(sort(table(relevant_articles$Journal), decreasing = TRUE), 10))
}

# ==============================================================================
# EXPORT
# ==============================================================================

output_dir <- "/home/ffer/article_audrey/output_search"

# Export relevant articles
write.csv(
  relevant_articles %>% select(-is_relevant),
  file.path(output_dir, "pubmed_NEW_RELEVANT.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

# Export excluded articles (for verification)
write.csv(
  excluded_articles %>% select(-is_relevant),
  file.path(output_dir, "pubmed_NEW_EXCLUDED.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

# Update report
report <- paste0(
  "=================================================================\n",
  "FILTERING REPORT - RELEVANT NMD ARTICLES\n",
  "=================================================================\n",
  "\n",
  "Date: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
  "\n",
  "--- RESULTS ---\n",
  "New articles (raw)       : ", nrow(articles), "\n",
  "RELEVANT articles        : ", nrow(relevant_articles), "\n",
  "Excluded articles        : ", nrow(excluded_articles), "\n",
  "\n",
  "--- FILTERING CRITERIA ---\n",
  "Inclusion: presence of at least one specific NMD term\n",
  "(duchenne, becker, myotonic dystrophy, ALS, SMA, myasthenia gravis, etc.)\n",
  "\n",
  "Exclusion: articles on secondary myopathies/neuropathies\n",
  "(diabetic, drug-induced, HIV, etc.) without specific NMD term\n",
  "\n",
  "--- FILES GENERATED ---\n",
  "1. pubmed_NEW_RELEVANT.csv : ", nrow(relevant_articles), " articles\n",
  "2. pubmed_NEW_EXCLUDED.csv : ", nrow(excluded_articles), " articles (to verify)\n",
  "\n",
  "=================================================================\n"
)

writeLines(report, file.path(output_dir, "filtering_report.txt"))

cat("\n\n--- FILES EXPORTED ---\n")
cat("- pubmed_NEW_RELEVANT.csv :", nrow(relevant_articles), "articles\n")
cat("- pubmed_NEW_EXCLUDED.csv :", nrow(excluded_articles), "articles\n")
cat("- filtering_report.txt\n")

cat("\n>>> FILTERING COMPLETED <<<\n")
