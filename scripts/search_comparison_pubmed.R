#!/usr/bin/env Rscript
# ==============================================================================
# R Script: PubMed Search Strategy Comparison
# Scoping Review - Sexual health in neuromuscular diseases
#
# Version 3: WITHOUT ambiguous acronyms (SMA, ALS, BMD, MG, FAP, IBM, etc.)
#            Only full-length disease names to avoid false positives
# ==============================================================================

library(rentrez)
library(dplyr)
library(tidyr)
library(xml2)

# ==============================================================================
# 1. SEARCH BLOCK DEFINITIONS
# ==============================================================================

# --- SEXUALITY block (common) ---
sexuality_block <- '(
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

# --- EXCLUSIONS block (common) ---
exclusions_block <- 'NOT (
  "neurofibromatosis"[MeSH Terms] OR
  "diabetes mellitus"[MeSH Terms] OR
  "fibromyalgia"[MeSH Terms] OR
  "fatigue syndrome, chronic"[MeSH Terms] OR
  "mice"[MeSH Terms] OR
  "mouse"[Title/Abstract]
)'

# --- Date filter ---
date_filter <- 'AND ("1983/01/01"[Date - Publication] : "2024/12/31"[Date - Publication])'

# --- ORIGINAL NMD block ---
nmd_block_original <- '(
  "neuromuscular diseases"[MeSH Terms] OR
  "neuromuscular diseases"[All Fields] OR
  "neuromuscular disorders"[All Fields] OR
  "neuromuscular disease"[All Fields] OR
  "neuromuscular disorder"[All Fields]
)'

# ==============================================================================
# EXTENDED NMD BLOCKS - CORRECTED VERSION (WITHOUT AMBIGUOUS ACRONYMS)
# ==============================================================================

# Group 1: Umbrella + General myopathies
nmd_block_ext_1 <- '(
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

# Group 2: Myositis and inflammatory (WITHOUT ambiguous "IBM")
nmd_block_ext_2 <- '(
  "myositis"[MeSH Terms] OR
  "inflammatory myopathy"[Title/Abstract] OR "inflammatory myopathies"[Title/Abstract] OR
  "dermatomyositis"[Title/Abstract] OR "Dermatomyositis"[MeSH Terms] OR
  "polymyositis"[Title/Abstract] OR "Polymyositis"[MeSH Terms] OR
  "inclusion body myositis"[Title/Abstract] OR "Myositis, Inclusion Body"[MeSH Terms] OR
  "necrotizing myopathy"[Title/Abstract] OR
  "immune-mediated necrotizing myopathy"[Title/Abstract] OR
  "antisynthetase syndrome"[Title/Abstract]
)'

# Group 3: Motor neuron (WITHOUT ambiguous "ALS" and "SMA" - full names only)
nmd_block_ext_3 <- '(
  "motor neuron disease"[Title/Abstract] OR "motor neurone disease"[Title/Abstract] OR
  "Motor Neuron Disease"[MeSH Terms] OR
  "amyotrophic lateral sclerosis"[Title/Abstract] OR "Amyotrophic Lateral Sclerosis"[MeSH Terms] OR
  "spinal muscular atrophy"[Title/Abstract] OR "Muscular Atrophy, Spinal"[MeSH Terms] OR
  "spinal and bulbar muscular atrophy"[Title/Abstract] OR "Bulbo-Spinal Atrophy, X-Linked"[MeSH Terms] OR
  "Kennedy disease"[Title/Abstract] OR
  "primary lateral sclerosis"[Title/Abstract]
)'

# Group 4: Peripheral neuropathies (WITHOUT ambiguous acronyms)
nmd_block_ext_4 <- '(
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

# Group 5: Amyloidosis (WITHOUT ambiguous "FAP" - full name only)
nmd_block_ext_5 <- '(
  "transthyretin amyloidosis"[Title/Abstract] OR
  "ATTR amyloidosis"[Title/Abstract] OR
  "hereditary transthyretin amyloidosis"[Title/Abstract] OR
  "Amyloid Neuropathies, Familial"[MeSH Terms] OR
  "familial amyloid polyneuropathy"[Title/Abstract] OR
  "amyloid neuropathy"[Title/Abstract]
)'

# Group 6: Neuromuscular junction (WITHOUT ambiguous "MG" and "LEMS")
nmd_block_ext_6 <- '(
  "neuromuscular junction disease"[Title/Abstract] OR
  "Neuromuscular Junction Diseases"[MeSH Terms] OR
  "myasthenia gravis"[Title/Abstract] OR "Myasthenia Gravis"[MeSH Terms] OR
  "Lambert-Eaton myasthenic syndrome"[Title/Abstract] OR "Lambert-Eaton Myasthenic Syndrome"[MeSH Terms] OR
  "congenital myasthenic syndrome"[Title/Abstract] OR "congenital myasthenic syndromes"[Title/Abstract] OR
  "Myasthenic Syndromes, Congenital"[MeSH Terms]
)'

# Group 7: Myotonic dystrophy and channelopathies (WITHOUT ambiguous "DM1" "DM2")
nmd_block_ext_7 <- '(
  "myotonic dystrophy"[Title/Abstract] OR "Myotonic Dystrophy"[MeSH Terms] OR
  "Steinert disease"[Title/Abstract] OR
  "myotonia congenita"[Title/Abstract] OR "Myotonia Congenita"[MeSH Terms] OR
  "paramyotonia congenita"[Title/Abstract] OR
  "periodic paralysis"[Title/Abstract] OR
  "hyperkalemic periodic paralysis"[Title/Abstract] OR
  "hypokalemic periodic paralysis"[Title/Abstract] OR
  "muscle channelopathy"[Title/Abstract] OR "muscular channelopathy"[Title/Abstract]
)'

# Group 8: Specific dystrophies (WITHOUT ambiguous "DMD" "BMD" "FSHD" "LGMD" "EDMD")
nmd_block_ext_8 <- '(
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

# Group 9: Metabolic myopathies
nmd_block_ext_9 <- '(
  "Pompe disease"[Title/Abstract] OR "Glycogen Storage Disease Type II"[MeSH Terms] OR
  "acid maltase deficiency"[Title/Abstract] OR
  "McArdle disease"[Title/Abstract] OR "Glycogen Storage Disease Type V"[MeSH Terms] OR
  "glycogen storage disease myopathy"[Title/Abstract]
)'

# ==============================================================================
# 2. FUNCTIONS
# ==============================================================================

clean_query <- function(q) {
  q <- gsub("\\s+", " ", q)
  q <- trimws(q)
  return(q)
}

search_pubmed_pmids <- function(query, description = "Search") {
  query <- clean_query(query)
  cat("  ->", description, "... ")

  tryCatch({
    search_result <- entrez_search(db = "pubmed", term = query, retmax = 10000)
    cat(search_result$count, "results\n")
    Sys.sleep(0.5)
    return(search_result$ids)
  }, error = function(e) {
    cat("ERROR:", e$message, "\n")
    return(c())
  })
}

fetch_pubmed_details <- function(pmids, description = "Fetching") {
  if (length(pmids) == 0) return(data.frame())

  cat("\n", description, ":", length(pmids), "articles\n")

  all_records <- list()
  batch_size <- 100

  for (i in seq(1, length(pmids), by = batch_size)) {
    batch_end <- min(i + batch_size - 1, length(pmids))
    batch_pmids <- pmids[i:batch_end]

    cat("  Metadata", i, "-", batch_end, "of", length(pmids), "\n")

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
      cat("  ERROR batch:", e$message, "\n")
    })

    Sys.sleep(0.5)
  }

  df <- bind_rows(all_records)
  cat("  -> Done:", nrow(df), "records\n")
  return(df)
}

# ==============================================================================
# 3. SEARCH EXECUTION
# ==============================================================================

cat("\n")
cat("################################################################\n")
cat("# PUBMED SEARCH STRATEGY COMPARISON                            #\n")
cat("# Version 3 - WITHOUT AMBIGUOUS ACRONYMS                       #\n")
cat("# Date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "              #\n")
cat("################################################################\n")

# --- ORIGINAL EQUATION ---
cat("\n\n========================================\n")
cat("ORIGINAL EQUATION\n")
cat("========================================\n")

eq_original <- paste(sexuality_block, "AND", nmd_block_original, exclusions_block, date_filter)
pmids_original <- search_pubmed_pmids(eq_original, "Full search")

# --- EXTENDED EQUATIONS (by group) ---
cat("\n\n========================================\n")
cat("EXTENDED EQUATIONS (by groups - without ambiguous acronyms)\n")
cat("========================================\n")

extended_blocks <- list(
  "Group 1 - Umbrella/Myopathies" = nmd_block_ext_1,
  "Group 2 - Myositis/Inflammatory" = nmd_block_ext_2,
  "Group 3 - Motor neuron" = nmd_block_ext_3,
  "Group 4 - Peripheral neuropathies" = nmd_block_ext_4,
  "Group 5 - Amyloidosis" = nmd_block_ext_5,
  "Group 6 - NM junction" = nmd_block_ext_6,
  "Group 7 - Myotonic/Channelopathies" = nmd_block_ext_7,
  "Group 8 - Specific dystrophies" = nmd_block_ext_8,
  "Group 9 - Metabolic" = nmd_block_ext_9
)

pmids_extended_all <- c()

for (name in names(extended_blocks)) {
  eq <- paste(sexuality_block, "AND", extended_blocks[[name]], exclusions_block, date_filter)
  pmids_group <- search_pubmed_pmids(eq, name)
  pmids_extended_all <- c(pmids_extended_all, pmids_group)
}

pmids_extended <- unique(pmids_extended_all)

cat("\n--- Total after deduplication ---\n")
cat("Unique PMIDs (extended):", length(pmids_extended), "\n")

# ==============================================================================
# 4. IDENTIFICATION OF NEW ARTICLES
# ==============================================================================

cat("\n\n========================================\n")
cat("COMPARATIVE ANALYSIS\n")
cat("========================================\n")

pmids_original <- unique(pmids_original)
pmids_new <- setdiff(pmids_extended, pmids_original)

cat("\nOriginal equation    :", length(pmids_original), "unique articles\n")
cat("Extended equation    :", length(pmids_extended), "unique articles\n")
cat("NEW articles (X)     :", length(pmids_new), "articles\n")

# ==============================================================================
# 5. FETCHING DETAILS
# ==============================================================================

cat("\n\n========================================\n")
cat("FETCHING METADATA\n")
cat("========================================\n")

results_original <- fetch_pubmed_details(pmids_original, "Original equation")

if (length(pmids_new) > 0) {
  results_new <- fetch_pubmed_details(pmids_new, "New articles")
} else {
  results_new <- data.frame()
  cat("\nNo new articles to fetch.\n")
}

# ==============================================================================
# 6. STATISTICS ON NEW ARTICLES
# ==============================================================================

if (nrow(results_new) > 0) {
  cat("\n\n========================================\n")
  cat("STATISTICS - NEW ARTICLES\n")
  cat("========================================\n")

  cat("\n--- Distribution by year ---\n")
  year_table <- table(results_new$Year)
  print(year_table)

  cat("\n--- Top 15 journals ---\n")
  journal_table <- sort(table(results_new$Journal), decreasing = TRUE)
  print(head(journal_table, 15))

  # NMD keyword search in titles (full names)
  cat("\n--- NMD diseases detected in titles ---\n")
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
    n <- sum(grepl(kw, results_new$Title, ignore.case = TRUE))
    if (n > 0) cat("  ", kw, ":", n, "\n")
  }
}

# ==============================================================================
# 7. EXPORT RESULTS
# ==============================================================================

output_dir <- "/home/ffer/article_audrey/output_search"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

write.csv(results_original, file.path(output_dir, "pubmed_original_equation.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

if (nrow(results_new) > 0) {
  write.csv(results_new, file.path(output_dir, "pubmed_NEW_articles.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
}

# Report
report <- paste0(
  "=================================================================\n",
  "COMPARISON REPORT - PUBMED SEARCH STRATEGIES\n",
  "Version 3 - Without ambiguous acronyms\n",
  "=================================================================\n",
  "\n",
  "Execution date: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
  "Period covered: 1983-2024\n",
  "\n",
  "ACRONYMS REMOVED (ambiguous):\n",
  "- SMA (Smooth Muscle Actin vs Spinal Muscular Atrophy)\n",
  "- ALS (multiple meanings)\n",
  "- BMD (Bone Mineral Density vs Becker Muscular Dystrophy)\n",
  "- MG (Magnesium vs Myasthenia Gravis)\n",
  "- FAP (Familial Adenomatous Polyposis vs Familial Amyloid Polyneuropathy)\n",
  "- IBM (company vs Inclusion Body Myositis)\n",
  "- DMD, FSHD, LGMD, EDMD, DM1, DM2, LEMS, CMT, CIDP, GBS, HNPP\n",
  "\n",
  "--- RESULTS ---\n",
  "Original equation    : ", length(pmids_original), " articles\n",
  "Extended equation    : ", length(pmids_extended), " articles\n",
  "NEW articles (X)     : ", length(pmids_new), " articles\n",
  "\n",
  "--- FILES GENERATED ---\n",
  "1. pubmed_original_equation.csv : ", nrow(results_original), " articles\n",
  "2. pubmed_NEW_articles.csv      : ", nrow(results_new), " articles\n",
  "3. comparison_report.txt        : this file\n",
  "\n",
  "=================================================================\n"
)

writeLines(report, file.path(output_dir, "comparison_report.txt"))

cat("\n\n")
cat("################################################################\n")
cat("# FILES EXPORTED                                               #\n")
cat("################################################################\n")
cat("\nFolder:", output_dir, "\n")
cat("- pubmed_original_equation.csv\n")
if (nrow(results_new) > 0) cat("- pubmed_NEW_articles.csv\n")
cat("- comparison_report.txt\n")

cat("\n>>> SCRIPT COMPLETED <<<\n")
