#!/usr/bin/env Rscript
# ==============================================================================
# R Script: Final extraction of truly new articles
# Filters duplicates and retrieves all metadata + full text links
# ==============================================================================

library(rentrez)
library(dplyr)
library(xml2)

# ==============================================================================
# 1. LIST OF AUTHORS FROM THE 26 ALREADY INCLUDED ARTICLES
# ==============================================================================

# Principal authors extracted from references 14-40 of the manuscript
included_authors <- c(
  # Ref 14 - Anderson & Bardach
  "Anderson F", "Bardach",
  # Ref 15 - Antonini et al (DM1 erectile)
  "Antonini G", "Clemenzi A", "Bucci E", "Morino S", "Garibaldi M",
  # Ref 16 - Mastrogiacomo et al
  "Mastrogiacomo I", "Bonanni G", "Menegazzo E",
  # Ref 17 - Peric et al
  "Peric S", "Nisic T", "Milicev M", "Basta I",
  # Ref 18 - Antonini et al (DM1 hormones)
  "Di Pasquale A",
  # Ref 19 - Fisette-Paulhus et al (pelvic floor DM1)
  "Fisette-Paulhus I", "Gagnon C", "Morin M",
  # Ref 20 - Heatwole et al (DM1)
  "Heatwole C", "Bode R", "Johnson N", "Quinn C",
  # Ref 21 - Heatwole et al (DM2)
  "Dekdebrun J", "Dilek N", "Hilbert JE",
  # Ref 22 - Hagerman et al
  "Hagerman KA", "Howe SJ",
  # Ref 23 - Bird et al (CMT impotence)
  "Bird TD", "Lipe HP", "Crabtree LD",
  # Ref 24 - Vinci et al
  "Vinci P", "Gargiulo P", "Navarro-Cremades F",
  # Ref 25 - Cannarella et al
  "Cannarella R", "Burgio G", "La Vignera S", "Calogero AE",
  # Ref 26 - Krhut et al
  "Krhut J", "Mazanec R", "Seeman P", "Zvara P",
  # Ref 27 - Gargiulo et al (CMT women)
  "Rellini AH",
  # Ref 28 - Rellini et al
  "Nappi RE", "Vaccaro P", "Meston CM",
  # Ref 29 - Carr et al (ATTR)
  "Carr AS", "Pelayo-Negro AL", "Evans MR", "Laura M", "Stancanelli C",
  # Ref 30 - Hita Villaplana et al
  "Hita Villaplana G", "Hita Rosino E", "Lopez Cubillana P",
  # Ref 31 - Gomes et al (FAP women)
  "Gomes MJ", "Martins da Silva A", "Salinas J",
  # Ref 32 - Oliveira-e-Silva et al
  "Oliveira-e-Silva T", "Campos Pinheiro L", "Rocha Mendes J", "Barroso E",
  # Ref 33 - Wasner et al (ALS sexuality)
  "Wasner M", "Bold U", "Vollmer TC", "Borasio GD",
  # Ref 34 - Shahbazi et al
  "Shahbazi M", "Holzberg S", "Thirunavukkarasu S", "Ciani G",
  # Ref 35 - Barrera et al (DMD clinical)
  "Barrera E", "Baronas JM", "Sutherland S", "Boskey",
  # Ref 36 - Hoskin et al (DMD qualitative)
  "Hoskin J", "Cheetham TD", "Mitchell RT", "Wong SC", "Wood CL",
  # Ref 37 - Wang et al (MG)
  "Wang J", "Yan C", "Zhao Z", "Chen H", "Shi Z", "Du Q",
  # Ref 38 - Papadopoulos (MG methotrexate)
  "Papadopoulos C", "Papadimas GK",
  # Ref 39 - Souza et al (IIM)
  "Souza FHC", "Araujo DB", "Abdo CHN", "Bonfa E",
  # Ref 40 - Hermankova et al
  "Hermankova B", "Spiritovic M", "Oreska S", "Storkanova H"
)

# ==============================================================================
# 2. LOAD HIGH RELEVANCE ARTICLES
# ==============================================================================

cat("=================================================================\n")
cat("FINAL EXTRACTION OF TRULY NEW ARTICLES\n")
cat("=================================================================\n\n")

articles <- read.csv("/home/ffer/article_audrey/output_search/pubmed_NEW_HIGH_RELEVANCE.csv",
                     stringsAsFactors = FALSE)

cat("High relevance input articles:", nrow(articles), "\n\n")

# ==============================================================================
# 3. FILTER DUPLICATES
# ==============================================================================

is_duplicate <- function(article_authors) {
  if (is.na(article_authors) || article_authors == "") return(FALSE)

  for (included_author in included_authors) {
    if (grepl(included_author, article_authors, ignore.case = TRUE)) {
      return(TRUE)
    }
  }
  return(FALSE)
}

articles$is_duplicate <- sapply(articles$Authors, is_duplicate)

duplicates <- articles %>% filter(is_duplicate == TRUE)
new_articles <- articles %>% filter(is_duplicate == FALSE)

cat("--- FILTERING RESULT ---\n")
cat("Duplicates (already included) :", nrow(duplicates), "\n")
cat("TRULY new articles            :", nrow(new_articles), "\n\n")

if (nrow(duplicates) > 0) {
  cat("--- IDENTIFIED DUPLICATES ---\n")
  for (i in 1:nrow(duplicates)) {
    cat("  -", substr(duplicates$Title[i], 1, 70), "...\n")
    cat("    Authors:", substr(duplicates$Authors[i], 1, 50), "\n")
  }
  cat("\n")
}

# ==============================================================================
# 4. RETRIEVE COMPLETE INFO FOR NEW ARTICLES
# ==============================================================================

if (nrow(new_articles) > 0) {
  cat("--- FETCHING COMPLETE METADATA ---\n\n")

  pmids <- new_articles$PMID

  # Retrieve complete data via PubMed API
  all_records <- list()

  for (pmid in pmids) {
    cat("  Processing PMID:", pmid, "... ")

    tryCatch({
      # Retrieve detailed XML
      fetch_result <- entrez_fetch(db = "pubmed", id = pmid, rettype = "xml", parsed = FALSE)
      xml_doc <- read_xml(fetch_result)
      article <- xml_find_first(xml_doc, "//PubmedArticle")

      record <- list()
      record$PMID <- pmid

      # Title
      title_node <- xml_find_first(article, ".//ArticleTitle")
      record$Title <- if (!is.na(title_node)) xml_text(title_node) else NA

      # Complete authors
      authors <- xml_find_all(article, ".//Author")
      author_list <- sapply(authors, function(a) {
        lastname <- xml_text(xml_find_first(a, ".//LastName"))
        forename <- xml_text(xml_find_first(a, ".//ForeName"))
        if (!is.na(lastname)) {
          if (!is.na(forename)) paste(lastname, forename, sep = " ") else lastname
        } else NA
      })
      record$Authors <- paste(na.omit(author_list), collapse = "; ")

      # Affiliations
      affil_nodes <- xml_find_all(article, ".//Affiliation")
      record$Affiliations <- paste(sapply(affil_nodes, xml_text), collapse = " | ")

      # Complete journal
      journal_node <- xml_find_first(article, ".//Journal/Title")
      record$Journal <- if (!is.na(journal_node)) xml_text(journal_node) else NA

      journal_abbrev <- xml_find_first(article, ".//Journal/ISOAbbreviation")
      record$Journal_Abbrev <- if (!is.na(journal_abbrev)) xml_text(journal_abbrev) else NA

      # Year, month
      year_node <- xml_find_first(article, ".//PubDate/Year")
      record$Year <- if (!is.na(year_node)) xml_text(year_node) else NA

      month_node <- xml_find_first(article, ".//PubDate/Month")
      record$Month <- if (!is.na(month_node)) xml_text(month_node) else NA

      # Volume, Issue, Pages
      volume_node <- xml_find_first(article, ".//JournalIssue/Volume")
      record$Volume <- if (!is.na(volume_node)) xml_text(volume_node) else NA

      issue_node <- xml_find_first(article, ".//JournalIssue/Issue")
      record$Issue <- if (!is.na(issue_node)) xml_text(issue_node) else NA

      pages_node <- xml_find_first(article, ".//Pagination/MedlinePgn")
      record$Pages <- if (!is.na(pages_node)) xml_text(pages_node) else NA

      # Complete abstract
      abstract_parts <- xml_find_all(article, ".//AbstractText")
      if (length(abstract_parts) > 0) {
        abstract_texts <- sapply(abstract_parts, function(p) {
          label <- xml_attr(p, "Label")
          text <- xml_text(p)
          if (!is.na(label) && label != "") paste0("[", label, "] ", text) else text
        })
        record$Abstract <- paste(abstract_texts, collapse = " ")
      } else {
        record$Abstract <- NA
      }

      # DOI
      doi_node <- xml_find_first(article, ".//ArticleId[@IdType='doi']")
      record$DOI <- if (!is.na(doi_node)) xml_text(doi_node) else NA

      # PMC ID (for full text access)
      pmc_node <- xml_find_first(article, ".//ArticleId[@IdType='pmc']")
      record$PMCID <- if (!is.na(pmc_node)) xml_text(pmc_node) else NA

      # PubMed link
      record$PubMed_URL <- paste0("https://pubmed.ncbi.nlm.nih.gov/", pmid, "/")

      # PMC link (free full text if available)
      if (!is.na(record$PMCID) && record$PMCID != "") {
        record$PMC_URL <- paste0("https://www.ncbi.nlm.nih.gov/pmc/articles/", record$PMCID, "/")
        record$FullText_Available <- "YES (PMC)"
      } else if (!is.na(record$DOI) && record$DOI != "") {
        record$PMC_URL <- NA
        record$FullText_Available <- "Via DOI"
      } else {
        record$PMC_URL <- NA
        record$FullText_Available <- "NO"
      }

      # DOI link
      if (!is.na(record$DOI) && record$DOI != "") {
        record$DOI_URL <- paste0("https://doi.org/", record$DOI)
      } else {
        record$DOI_URL <- NA
      }

      # MeSH Terms
      mesh_nodes <- xml_find_all(article, ".//MeshHeading/DescriptorName")
      record$MeSH_Terms <- paste(sapply(mesh_nodes, xml_text), collapse = "; ")

      # Keywords
      kw_nodes <- xml_find_all(article, ".//Keyword")
      record$Keywords <- paste(sapply(kw_nodes, xml_text), collapse = "; ")

      # Publication type
      pt_nodes <- xml_find_all(article, ".//PublicationType")
      record$Publication_Type <- paste(sapply(pt_nodes, xml_text), collapse = "; ")

      # Language
      lang_node <- xml_find_first(article, ".//Language")
      record$Language <- if (!is.na(lang_node)) xml_text(lang_node) else NA

      # Country
      country_node <- xml_find_first(article, ".//MedlineJournalInfo/Country")
      record$Country <- if (!is.na(country_node)) xml_text(country_node) else NA

      all_records[[length(all_records) + 1]] <- record

      cat("OK\n")
      Sys.sleep(0.4)

    }, error = function(e) {
      cat("ERROR:", e$message, "\n")
    })
  }

  # Convert to dataframe
  df_final <- bind_rows(all_records)

  # Add screening columns
  df_final$Screening_Decision <- ""
  df_final$Screening_Reason <- ""
  df_final$Relevance_Score <- ""
  df_final$Notes <- ""

  # Reorder columns
  cols_order <- c(
    "PMID", "Title", "Authors", "Year", "Journal",
    "Abstract", "DOI", "DOI_URL", "PubMed_URL", "PMC_URL", "FullText_Available",
    "Publication_Type", "MeSH_Terms", "Keywords",
    "Screening_Decision", "Screening_Reason", "Relevance_Score", "Notes",
    "Affiliations", "Journal_Abbrev", "Month", "Volume", "Issue", "Pages",
    "PMCID", "Language", "Country"
  )

  # Keep only existing columns
  cols_exist <- cols_order[cols_order %in% names(df_final)]
  df_final <- df_final[, cols_exist]

} else {
  df_final <- data.frame()
  cat("No new articles to process.\n")
}

# ==============================================================================
# 5. EXPORT
# ==============================================================================

output_dir <- "/home/ffer/article_audrey/output_search"

# Main CSV export (Excel compatible)
output_file <- file.path(output_dir, "NEW_ARTICLES_FOR_SCREENING.csv")
write.csv(df_final, output_file, row.names = FALSE, fileEncoding = "UTF-8", na = "")

cat("\n\n=================================================================\n")
cat("FINAL SUMMARY\n")
cat("=================================================================\n")
cat("\nHigh relevance articles analyzed    :", nrow(articles), "\n")
cat("Duplicates (in the 26 included)     :", nrow(duplicates), "\n")
cat("TRULY new articles                  :", nrow(new_articles), "\n")
cat("\nFile exported:", output_file, "\n")

# Display new article titles
if (nrow(df_final) > 0) {
  cat("\n--- LIST OF", nrow(df_final), "ARTICLES TO SCREEN ---\n\n")
  for (i in 1:nrow(df_final)) {
    ft <- ifelse(!is.na(df_final$FullText_Available[i]), df_final$FullText_Available[i], "?")
    cat(i, ". [", df_final$Year[i], "] ", substr(df_final$Title[i], 1, 80), "...\n", sep = "")
    cat("   Full text: ", ft, " | PMID: ", df_final$PMID[i], "\n", sep = "")
  }
}

# Create text report
report <- paste0(
  "=================================================================\n",
  "FINAL REPORT - NEW ARTICLES FOR SCREENING\n",
  "=================================================================\n",
  "\n",
  "Date: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
  "\n",
  "--- CONTEXT ---\n",
  "Original equation : 'neuromuscular' terms only\n",
  "Extended equation : + categories (myopathy, dystrophy, etc.)\n",
  "                    + specific diseases (full names)\n",
  "\n",
  "--- RESULTS ---\n",
  "High relevance articles (NMD term in title) : ", nrow(articles), "\n",
  "Duplicates with the 26 included articles    : ", nrow(duplicates), "\n",
  "TRULY new articles to screen                : ", nrow(df_final), "\n",
  "\n",
  "--- FILE GENERATED ---\n",
  "NEW_ARTICLES_FOR_SCREENING.csv\n",
  "\n",
  "Screening columns:\n",
  "- Screening_Decision : INCLUDE / EXCLUDE\n",
  "- Screening_Reason   : reason for inclusion/exclusion\n",
  "- Relevance_Score    : 1-5 (relevance to review)\n",
  "- Notes              : free comments\n",
  "\n",
  "=================================================================\n"
)

writeLines(report, file.path(output_dir, "final_screening_report.txt"))

cat("\n>>> EXTRACTION COMPLETED <<<\n")
