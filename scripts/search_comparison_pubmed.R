#!/usr/bin/env Rscript
# ==============================================================================
# Script R : Comparaison des stratégies de recherche PubMed
# Scoping Review - Sexual health in neuromuscular diseases
#
# Version 3 : SANS acronymes ambigus (SMA, ALS, BMD, MG, FAP, IBM, etc.)
#             Uniquement formes longues pour éviter les faux positifs
# ==============================================================================

library(rentrez)
library(dplyr)
library(tidyr)
library(xml2)

# ==============================================================================
# 1. DÉFINITION DES BLOCS DE RECHERCHE
# ==============================================================================

# --- Bloc SEXUALITÉ (commun) ---
bloc_sexualite <- '(
  "sexual behaviour"[MeSH Terms] OR
  "sexuality"[MeSH Terms] OR
  "sexual dysfunction, physiological"[MeSH Terms] OR
  "sexual dysfunctions, psychological"[MeSH Terms] OR
  "sexual health"[All Fields] OR
  "sexual function"[All Fields] OR
  "sexual dysfunction"[All Fields] OR
  "erectile dysfunction"[All Fields] OR
  "libido"[All Fields] OR
  "dyspareunia"[All Fields] OR
  "orgasm"[All Fields] OR
  "sexual satisfaction"[All Fields] OR
  "sexual"[Title/Abstract] OR
  "sexuality"[Title/Abstract]
)'

# --- Bloc EXCLUSIONS (commun) ---
bloc_exclusions <- 'NOT (
  "neurofibromatosis"[MeSH Terms] OR
  "diabetes mellitus"[MeSH Terms] OR
  "fibromyalgia"[MeSH Terms] OR
  "fatigue syndrome, chronic"[MeSH Terms] OR
  "mice"[MeSH Terms] OR
  "mouse"[Title/Abstract]
)'

# --- Filtre période ---
filtre_date <- 'AND ("1983/01/01"[Date - Publication] : "2024/12/31"[Date - Publication])'

# --- Bloc NMD ORIGINAL ---
bloc_nmd_original <- '(
  "neuromuscular diseases"[MeSH Terms] OR
  "neuromuscular diseases"[All Fields] OR
  "neuromuscular disorders"[All Fields] OR
  "neuromuscular disease"[All Fields] OR
  "neuromuscular disorder"[All Fields]
)'

# ==============================================================================
# BLOCS NMD ÉTENDUS - VERSION CORRIGÉE (SANS ACRONYMES AMBIGUS)
# ==============================================================================

# Groupe 1 : Umbrella + Myopathies générales
bloc_nmd_ext_1 <- '(
  "neuromuscular diseases"[MeSH Terms] OR
  "neuromuscular disease"[Title/Abstract] OR
  "neuromuscular disorder"[Title/Abstract] OR
  "myopathy"[Title/Abstract] OR "myopathies"[Title/Abstract] OR
  "muscular dystrophy"[Title/Abstract] OR "muscular dystrophies"[Title/Abstract] OR
  "Muscular Dystrophies"[MeSH Terms] OR
  "congenital myopathy"[Title/Abstract] OR "congenital myopathies"[Title/Abstract] OR
  "metabolic myopathy"[Title/Abstract] OR
  "mitochondrial myopathy"[Title/Abstract] OR "Mitochondrial Myopathies"[MeSH Terms]
)'

# Groupe 2 : Myosites et inflammatoires (SANS "IBM" ambigu)
bloc_nmd_ext_2 <- '(
  "myositis"[MeSH Terms] OR
  "inflammatory myopathy"[Title/Abstract] OR "inflammatory myopathies"[Title/Abstract] OR
  "dermatomyositis"[Title/Abstract] OR "Dermatomyositis"[MeSH Terms] OR
  "polymyositis"[Title/Abstract] OR "Polymyositis"[MeSH Terms] OR
  "inclusion body myositis"[Title/Abstract] OR "Myositis, Inclusion Body"[MeSH Terms] OR
  "necrotizing myopathy"[Title/Abstract] OR
  "immune-mediated necrotizing myopathy"[Title/Abstract] OR
  "antisynthetase syndrome"[Title/Abstract]
)'

# Groupe 3 : Neurone moteur (SANS "ALS" et "SMA" ambigus - formes longues uniquement)
bloc_nmd_ext_3 <- '(
  "motor neuron disease"[Title/Abstract] OR "motor neurone disease"[Title/Abstract] OR
  "Motor Neuron Disease"[MeSH Terms] OR
  "amyotrophic lateral sclerosis"[Title/Abstract] OR "Amyotrophic Lateral Sclerosis"[MeSH Terms] OR
  "spinal muscular atrophy"[Title/Abstract] OR "Muscular Atrophy, Spinal"[MeSH Terms] OR
  "spinal and bulbar muscular atrophy"[Title/Abstract] OR "Bulbo-Spinal Atrophy, X-Linked"[MeSH Terms] OR
  "Kennedy disease"[Title/Abstract] OR
  "primary lateral sclerosis"[Title/Abstract]
)'

# Groupe 4 : Neuropathies périphériques (SANS acronymes ambigus)
bloc_nmd_ext_4 <- '(
  "peripheral neuropathy"[Title/Abstract] OR "peripheral neuropathies"[Title/Abstract] OR
  "polyneuropathy"[Title/Abstract] OR "polyneuropathies"[Title/Abstract] OR
  "Polyneuropathies"[MeSH Terms] OR
  "hereditary motor and sensory neuropathy"[Title/Abstract] OR
  "Charcot-Marie-Tooth disease"[Title/Abstract] OR "Charcot-Marie-Tooth Disease"[MeSH Terms] OR
  "hereditary neuropathy with liability to pressure palsies"[Title/Abstract] OR
  "chronic inflammatory demyelinating polyneuropathy"[Title/Abstract] OR
  "chronic inflammatory demyelinating polyradiculoneuropathy"[Title/Abstract] OR
  "Polyradiculoneuropathy, Chronic Inflammatory Demyelinating"[MeSH Terms] OR
  "Guillain-Barre syndrome"[Title/Abstract] OR "Guillain-Barre Syndrome"[MeSH Terms] OR
  "multifocal motor neuropathy"[Title/Abstract]
)'

# Groupe 5 : Amyloidoses (SANS "FAP" ambigu - forme longue uniquement)
bloc_nmd_ext_5 <- '(
  "transthyretin amyloidosis"[Title/Abstract] OR
  "ATTR amyloidosis"[Title/Abstract] OR
  "hereditary transthyretin amyloidosis"[Title/Abstract] OR
  "Amyloid Neuropathies, Familial"[MeSH Terms] OR
  "familial amyloid polyneuropathy"[Title/Abstract] OR
  "amyloid neuropathy"[Title/Abstract]
)'

# Groupe 6 : Jonction neuromusculaire (SANS "MG" et "LEMS" ambigus)
bloc_nmd_ext_6 <- '(
  "neuromuscular junction disease"[Title/Abstract] OR
  "Neuromuscular Junction Diseases"[MeSH Terms] OR
  "myasthenia gravis"[Title/Abstract] OR "Myasthenia Gravis"[MeSH Terms] OR
  "Lambert-Eaton myasthenic syndrome"[Title/Abstract] OR "Lambert-Eaton Myasthenic Syndrome"[MeSH Terms] OR
  "congenital myasthenic syndrome"[Title/Abstract] OR "congenital myasthenic syndromes"[Title/Abstract] OR
  "Myasthenic Syndromes, Congenital"[MeSH Terms]
)'

# Groupe 7 : Dystrophie myotonique et canalopathies (SANS "DM1" "DM2" ambigus)
bloc_nmd_ext_7 <- '(
  "myotonic dystrophy"[Title/Abstract] OR "Myotonic Dystrophy"[MeSH Terms] OR
  "Steinert disease"[Title/Abstract] OR
  "myotonia congenita"[Title/Abstract] OR "Myotonia Congenita"[MeSH Terms] OR
  "paramyotonia congenita"[Title/Abstract] OR
  "periodic paralysis"[Title/Abstract] OR
  "hyperkalemic periodic paralysis"[Title/Abstract] OR
  "hypokalemic periodic paralysis"[Title/Abstract] OR
  "muscle channelopathy"[Title/Abstract] OR "muscular channelopathy"[Title/Abstract]
)'

# Groupe 8 : Dystrophies spécifiques (SANS "DMD" "BMD" "FSHD" "LGMD" "EDMD" ambigus)
bloc_nmd_ext_8 <- '(
  "Duchenne muscular dystrophy"[Title/Abstract] OR "Muscular Dystrophy, Duchenne"[MeSH Terms] OR
  "Becker muscular dystrophy"[Title/Abstract] OR
  "facioscapulohumeral muscular dystrophy"[Title/Abstract] OR "Muscular Dystrophy, Facioscapulohumeral"[MeSH Terms] OR
  "limb-girdle muscular dystrophy"[Title/Abstract] OR "limb girdle muscular dystrophy"[Title/Abstract] OR
  "Muscular Dystrophies, Limb-Girdle"[MeSH Terms] OR
  "Emery-Dreifuss muscular dystrophy"[Title/Abstract] OR "Muscular Dystrophy, Emery-Dreifuss"[MeSH Terms] OR
  "oculopharyngeal muscular dystrophy"[Title/Abstract] OR
  "distal muscular dystrophy"[Title/Abstract] OR "distal myopathy"[Title/Abstract] OR
  "congenital muscular dystrophy"[Title/Abstract]
)'

# Groupe 9 : Myopathies métaboliques
bloc_nmd_ext_9 <- '(
  "Pompe disease"[Title/Abstract] OR "Glycogen Storage Disease Type II"[MeSH Terms] OR
  "acid maltase deficiency"[Title/Abstract] OR
  "McArdle disease"[Title/Abstract] OR "Glycogen Storage Disease Type V"[MeSH Terms] OR
  "glycogen storage disease myopathy"[Title/Abstract]
)'

# ==============================================================================
# 2. FONCTIONS
# ==============================================================================

clean_query <- function(q) {
  q <- gsub("\\s+", " ", q)
  q <- trimws(q)
  return(q)
}

search_pubmed_pmids <- function(query, description = "Recherche") {
  query <- clean_query(query)
  cat("  ->", description, "... ")

  tryCatch({
    search_result <- entrez_search(db = "pubmed", term = query, retmax = 10000)
    cat(search_result$count, "résultats\n")
    Sys.sleep(0.5)
    return(search_result$ids)
  }, error = function(e) {
    cat("ERREUR:", e$message, "\n")
    return(c())
  })
}

fetch_pubmed_details <- function(pmids, description = "Récupération") {
  if (length(pmids) == 0) return(data.frame())

  cat("\n", description, ":", length(pmids), "articles\n")

  all_records <- list()
  batch_size <- 100

  for (i in seq(1, length(pmids), by = batch_size)) {
    batch_end <- min(i + batch_size - 1, length(pmids))
    batch_pmids <- pmids[i:batch_end]

    cat("  Métadonnées", i, "-", batch_end, "sur", length(pmids), "\n")

    tryCatch({
      fetch_result <- entrez_fetch(db = "pubmed", id = batch_pmids, rettype = "xml", parsed = FALSE)
      xml_doc <- read_xml(fetch_result)
      articles <- xml_find_all(xml_doc, "//PubmedArticle")

      for (article in articles) {
        record <- list()

        record$PMID <- xml_text(xml_find_first(article, ".//PMID"))

        title_node <- xml_find_first(article, ".//ArticleTitle")
        record$Title <- if (!is.na(title_node)) xml_text(title_node) else NA

        authors <- xml_find_all(article, ".//Author")
        author_names <- sapply(authors, function(a) {
          lastname <- xml_text(xml_find_first(a, ".//LastName"))
          initials <- xml_text(xml_find_first(a, ".//Initials"))
          if (!is.na(lastname)) paste0(lastname, " ", initials) else NA
        })
        record$Authors <- paste(na.omit(author_names), collapse = "; ")

        journal_node <- xml_find_first(article, ".//Journal/Title")
        record$Journal <- if (!is.na(journal_node)) xml_text(journal_node) else NA

        year_node <- xml_find_first(article, ".//PubDate/Year")
        if (is.na(year_node)) year_node <- xml_find_first(article, ".//PubDate/MedlineDate")
        record$Year <- if (!is.na(year_node)) substr(xml_text(year_node), 1, 4) else NA

        abstract_parts <- xml_find_all(article, ".//AbstractText")
        if (length(abstract_parts) > 0) {
          abstract_texts <- sapply(abstract_parts, function(p) {
            label <- xml_attr(p, "Label")
            text <- xml_text(p)
            if (!is.na(label) && label != "") paste0(label, ": ", text) else text
          })
          record$Abstract <- paste(abstract_texts, collapse = " ")
        } else {
          record$Abstract <- NA
        }

        doi_node <- xml_find_first(article, ".//ArticleId[@IdType='doi']")
        record$DOI <- if (!is.na(doi_node)) xml_text(doi_node) else NA

        mesh_nodes <- xml_find_all(article, ".//MeshHeading/DescriptorName")
        record$MeSH <- paste(sapply(mesh_nodes, xml_text), collapse = "; ")

        kw_nodes <- xml_find_all(article, ".//Keyword")
        record$Keywords <- paste(sapply(kw_nodes, xml_text), collapse = "; ")

        pt_nodes <- xml_find_all(article, ".//PublicationType")
        record$PublicationType <- paste(sapply(pt_nodes, xml_text), collapse = "; ")

        all_records[[length(all_records) + 1]] <- record
      }
    }, error = function(e) {
      cat("  ERREUR batch:", e$message, "\n")
    })

    Sys.sleep(0.5)
  }

  df <- bind_rows(all_records)
  cat("  -> Terminé:", nrow(df), "enregistrements\n")
  return(df)
}

# ==============================================================================
# 3. EXÉCUTION DES RECHERCHES
# ==============================================================================

cat("\n")
cat("################################################################\n")
cat("# COMPARAISON DES STRATÉGIES DE RECHERCHE PUBMED              #\n")
cat("# Version 3 - SANS ACRONYMES AMBIGUS                          #\n")
cat("# Date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "              #\n")
cat("################################################################\n")

# --- ÉQUATION ORIGINALE ---
cat("\n\n========================================\n")
cat("ÉQUATION ORIGINALE\n")
cat("========================================\n")

eq_original <- paste(bloc_sexualite, "AND", bloc_nmd_original, bloc_exclusions, filtre_date)
pmids_original <- search_pubmed_pmids(eq_original, "Recherche complète")

# --- ÉQUATIONS ÉTENDUES (par groupe) ---
cat("\n\n========================================\n")
cat("ÉQUATIONS ÉTENDUES (par groupes - sans acronymes ambigus)\n")
cat("========================================\n")

blocs_etendus <- list(
  "Groupe 1 - Umbrella/Myopathies" = bloc_nmd_ext_1,
  "Groupe 2 - Myosites/Inflammatoires" = bloc_nmd_ext_2,
  "Groupe 3 - Neurone moteur" = bloc_nmd_ext_3,
  "Groupe 4 - Neuropathies périph." = bloc_nmd_ext_4,
  "Groupe 5 - Amyloidoses" = bloc_nmd_ext_5,
  "Groupe 6 - Jonction NM" = bloc_nmd_ext_6,
  "Groupe 7 - Myotonies/Canalopathies" = bloc_nmd_ext_7,
  "Groupe 8 - Dystrophies spécifiques" = bloc_nmd_ext_8,
  "Groupe 9 - Métaboliques" = bloc_nmd_ext_9
)

pmids_etendu_all <- c()

for (nom in names(blocs_etendus)) {
  eq <- paste(bloc_sexualite, "AND", blocs_etendus[[nom]], bloc_exclusions, filtre_date)
  pmids_groupe <- search_pubmed_pmids(eq, nom)
  pmids_etendu_all <- c(pmids_etendu_all, pmids_groupe)
}

pmids_etendu <- unique(pmids_etendu_all)

cat("\n--- Total après dédoublonnage ---\n")
cat("PMIDs uniques (étendu):", length(pmids_etendu), "\n")

# ==============================================================================
# 4. IDENTIFICATION DES NOUVEAUX ARTICLES
# ==============================================================================

cat("\n\n========================================\n")
cat("ANALYSE COMPARATIVE\n")
cat("========================================\n")

pmids_original <- unique(pmids_original)
pmids_nouveaux <- setdiff(pmids_etendu, pmids_original)

cat("\nÉquation originale    :", length(pmids_original), "articles uniques\n")
cat("Équation étendue      :", length(pmids_etendu), "articles uniques\n")
cat("Articles NOUVEAUX (X) :", length(pmids_nouveaux), "articles\n")

# ==============================================================================
# 5. RÉCUPÉRATION DES DÉTAILS
# ==============================================================================

cat("\n\n========================================\n")
cat("RÉCUPÉRATION DES MÉTADONNÉES\n")
cat("========================================\n")

results_original <- fetch_pubmed_details(pmids_original, "Équation originale")

if (length(pmids_nouveaux) > 0) {
  results_nouveaux <- fetch_pubmed_details(pmids_nouveaux, "Nouveaux articles")
} else {
  results_nouveaux <- data.frame()
  cat("\nAucun nouvel article à récupérer.\n")
}

# ==============================================================================
# 6. STATISTIQUES SUR LES NOUVEAUX ARTICLES
# ==============================================================================

if (nrow(results_nouveaux) > 0) {
  cat("\n\n========================================\n")
  cat("STATISTIQUES - NOUVEAUX ARTICLES\n")
  cat("========================================\n")

  cat("\n--- Répartition par année ---\n")
  year_table <- table(results_nouveaux$Year)
  print(year_table)

  cat("\n--- Top 15 journaux ---\n")
  journal_table <- sort(table(results_nouveaux$Journal), decreasing = TRUE)
  print(head(journal_table, 15))

  # Recherche de mots-clés NMD dans les titres (formes longues)
  cat("\n--- Maladies NMD détectées dans les titres ---\n")
  keywords_nmd <- c(
    "duchenne", "becker", "muscular dystrophy", "myotonic dystrophy",
    "amyotrophic lateral sclerosis", "motor neuron disease",
    "spinal muscular atrophy", "charcot-marie-tooth", "myasthenia gravis",
    "myopathy", "neuropathy", "polyneuropathy", "dermatomyositis",
    "polymyositis", "pompe", "facioscapulohumeral", "limb-girdle",
    "guillain-barre", "myositis", "lambert-eaton", "kennedy disease",
    "periodic paralysis", "emery-dreifuss", "transthyretin", "amyloid"
  )

  for (kw in keywords_nmd) {
    n <- sum(grepl(kw, results_nouveaux$Title, ignore.case = TRUE))
    if (n > 0) cat("  ", kw, ":", n, "\n")
  }
}

# ==============================================================================
# 7. EXPORT DES RÉSULTATS
# ==============================================================================

output_dir <- "/home/ffer/article_audrey/output_search"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

write.csv(results_original, file.path(output_dir, "pubmed_equation_originale.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

if (nrow(results_nouveaux) > 0) {
  write.csv(results_nouveaux, file.path(output_dir, "pubmed_NOUVEAUX_articles.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
}

# Rapport
rapport <- paste0(
  "=================================================================\n",
  "RAPPORT DE COMPARAISON - STRATÉGIES DE RECHERCHE PUBMED\n",
  "Version 3 - Sans acronymes ambigus\n",
  "=================================================================\n",
  "\n",
  "Date d'exécution : ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
  "Période couverte : 1983-2024\n",
  "\n",
  "ACRONYMES RETIRÉS (ambigus) :\n",
  "- SMA (Smooth Muscle Actin vs Spinal Muscular Atrophy)\n",
  "- ALS (multiples significations)\n",
  "- BMD (Bone Mineral Density vs Becker Muscular Dystrophy)\n",
  "- MG (Magnesium vs Myasthenia Gravis)\n",
  "- FAP (Familial Adenomatous Polyposis vs Familial Amyloid Polyneuropathy)\n",
  "- IBM (compagnie vs Inclusion Body Myositis)\n",
  "- DMD, FSHD, LGMD, EDMD, DM1, DM2, LEMS, CMT, CIDP, GBS, HNPP\n",
  "\n",
  "--- RÉSULTATS ---\n",
  "Équation originale    : ", length(pmids_original), " articles\n",
  "Équation étendue      : ", length(pmids_etendu), " articles\n",
  "Articles NOUVEAUX (X) : ", length(pmids_nouveaux), " articles\n",
  "\n",
  "--- FICHIERS GÉNÉRÉS ---\n",
  "1. pubmed_equation_originale.csv  : ", nrow(results_original), " articles\n",
  "2. pubmed_NOUVEAUX_articles.csv   : ", nrow(results_nouveaux), " articles\n",
  "3. rapport_comparaison.txt        : ce fichier\n",
  "\n",
  "--- POUR LE REVIEWER ---\n",
  "X = ", length(pmids_nouveaux), " articles additionnels identifiés\n",
  "Y = [à compléter après screening manuel]\n",
  "\n",
  "=================================================================\n"
)

writeLines(rapport, file.path(output_dir, "rapport_comparaison.txt"))

cat("\n\n")
cat("################################################################\n")
cat("# FICHIERS EXPORTÉS                                           #\n")
cat("################################################################\n")
cat("\nDossier:", output_dir, "\n")
cat("- pubmed_equation_originale.csv\n")
if (nrow(results_nouveaux) > 0) cat("- pubmed_NOUVEAUX_articles.csv\n")
cat("- rapport_comparaison.txt\n")

cat("\n>>> SCRIPT TERMINÉ <<<\n")
