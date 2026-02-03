#!/usr/bin/env Rscript
# ==============================================================================
# Script R : Extraction finale des articles vraiment nouveaux
# Filtre les doublons et récupère toutes les métadonnées + liens full text
# ==============================================================================

library(rentrez)
library(dplyr)
library(xml2)

# ==============================================================================
# 1. LISTE DES AUTEURS DES 26 ARTICLES DÉJÀ INCLUS
# ==============================================================================

# Auteurs principaux extraits des références 14-40 du manuscrit
auteurs_inclus <- c(
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
  "Carr AS", "Pelayo-Negro AL", "Evans MR", "Laurà M", "Stancanelli C",
  # Ref 30 - Hita Villaplana et al
  "Hita Villaplana G", "Hita Rosino E", "López Cubillana P",
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
  "Souza FHC", "Araújo DB", "Abdo CHN", "Bonfá E",
  # Ref 40 - Heřmánková et al

  "Heřmánková B", "Hermankova B", "Špiritović M", "Spiritovic M", "Oreská S", "Štorkánová H"
)

# ==============================================================================
# 2. CHARGER LES ARTICLES HAUTE PERTINENCE
# ==============================================================================

cat("=================================================================\n")
cat("EXTRACTION FINALE DES ARTICLES VRAIMENT NOUVEAUX\n")
cat("=================================================================\n\n")

articles <- read.csv("/home/ffer/article_audrey/output_search/pubmed_NOUVEAUX_HAUTE_PERTINENCE.csv",
                     stringsAsFactors = FALSE)

cat("Articles haute pertinence en entrée:", nrow(articles), "\n\n")

# ==============================================================================
# 3. FILTRER LES DOUBLONS
# ==============================================================================

is_doublon <- function(auteurs_article) {
  if (is.na(auteurs_article) || auteurs_article == "") return(FALSE)

  for (auteur_inclus in auteurs_inclus) {
    if (grepl(auteur_inclus, auteurs_article, ignore.case = TRUE)) {
      return(TRUE)
    }
  }
  return(FALSE)
}

articles$is_doublon <- sapply(articles$Authors, is_doublon)

doublons <- articles %>% filter(is_doublon == TRUE)
nouveaux <- articles %>% filter(is_doublon == FALSE)

cat("--- RÉSULTAT DU FILTRAGE ---\n")
cat("Doublons (déjà inclus)     :", nrow(doublons), "\n")
cat("Articles VRAIMENT nouveaux :", nrow(nouveaux), "\n\n")

if (nrow(doublons) > 0) {
  cat("--- DOUBLONS IDENTIFIÉS ---\n")
  for (i in 1:nrow(doublons)) {
    cat("  -", substr(doublons$Title[i], 1, 70), "...\n")
    cat("    Auteurs:", substr(doublons$Authors[i], 1, 50), "\n")
  }
  cat("\n")
}

# ==============================================================================
# 4. RÉCUPÉRER INFOS COMPLÈTES POUR LES NOUVEAUX ARTICLES
# ==============================================================================

if (nrow(nouveaux) > 0) {
  cat("--- RÉCUPÉRATION DES MÉTADONNÉES COMPLÈTES ---\n\n")

  pmids <- nouveaux$PMID

  # Récupérer les données complètes via l'API PubMed
  all_records <- list()

  for (pmid in pmids) {
    cat("  Traitement PMID:", pmid, "... ")

    tryCatch({
      # Récupérer XML détaillé
      fetch_result <- entrez_fetch(db = "pubmed", id = pmid, rettype = "xml", parsed = FALSE)
      xml_doc <- read_xml(fetch_result)
      article <- xml_find_first(xml_doc, "//PubmedArticle")

      record <- list()
      record$PMID <- pmid

      # Titre
      title_node <- xml_find_first(article, ".//ArticleTitle")
      record$Title <- if (!is.na(title_node)) xml_text(title_node) else NA

      # Auteurs complets
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

      # Journal complet
      journal_node <- xml_find_first(article, ".//Journal/Title")
      record$Journal <- if (!is.na(journal_node)) xml_text(journal_node) else NA

      journal_abbrev <- xml_find_first(article, ".//Journal/ISOAbbreviation")
      record$Journal_Abbrev <- if (!is.na(journal_abbrev)) xml_text(journal_abbrev) else NA

      # Année, mois
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

      # Abstract complet
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

      # PMC ID (pour accès full text)
      pmc_node <- xml_find_first(article, ".//ArticleId[@IdType='pmc']")
      record$PMCID <- if (!is.na(pmc_node)) xml_text(pmc_node) else NA

      # Lien PubMed
      record$PubMed_URL <- paste0("https://pubmed.ncbi.nlm.nih.gov/", pmid, "/")

      # Lien PMC (full text gratuit si disponible)
      if (!is.na(record$PMCID) && record$PMCID != "") {
        record$PMC_URL <- paste0("https://www.ncbi.nlm.nih.gov/pmc/articles/", record$PMCID, "/")
        record$FullText_Available <- "OUI (PMC)"
      } else if (!is.na(record$DOI) && record$DOI != "") {
        record$PMC_URL <- NA
        record$FullText_Available <- "Via DOI"
      } else {
        record$PMC_URL <- NA
        record$FullText_Available <- "NON"
      }

      # Lien DOI
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

      # Type de publication
      pt_nodes <- xml_find_all(article, ".//PublicationType")
      record$Publication_Type <- paste(sapply(pt_nodes, xml_text), collapse = "; ")

      # Langue
      lang_node <- xml_find_first(article, ".//Language")
      record$Language <- if (!is.na(lang_node)) xml_text(lang_node) else NA

      # Pays
      country_node <- xml_find_first(article, ".//MedlineJournalInfo/Country")
      record$Country <- if (!is.na(country_node)) xml_text(country_node) else NA

      all_records[[length(all_records) + 1]] <- record

      cat("OK\n")
      Sys.sleep(0.4)

    }, error = function(e) {
      cat("ERREUR:", e$message, "\n")
    })
  }

  # Convertir en dataframe
  df_final <- bind_rows(all_records)

  # Ajouter colonnes pour le screening
  df_final$Screening_Decision <- ""
  df_final$Screening_Reason <- ""
  df_final$Relevance_Score <- ""
  df_final$Notes <- ""

  # Réorganiser les colonnes
  cols_order <- c(
    "PMID", "Title", "Authors", "Year", "Journal",
    "Abstract", "DOI", "DOI_URL", "PubMed_URL", "PMC_URL", "FullText_Available",
    "Publication_Type", "MeSH_Terms", "Keywords",
    "Screening_Decision", "Screening_Reason", "Relevance_Score", "Notes",
    "Affiliations", "Journal_Abbrev", "Month", "Volume", "Issue", "Pages",
    "PMCID", "Language", "Country"
  )

  # Garder seulement les colonnes qui existent
  cols_exist <- cols_order[cols_order %in% names(df_final)]
  df_final <- df_final[, cols_exist]

} else {
  df_final <- data.frame()
  cat("Aucun nouvel article à traiter.\n")
}

# ==============================================================================
# 5. EXPORT
# ==============================================================================

output_dir <- "/home/ffer/article_audrey/output_search"

# Export CSV principal (compatible Excel)
output_file <- file.path(output_dir, "ARTICLES_NOUVEAUX_POUR_SCREENING.csv")
write.csv(df_final, output_file, row.names = FALSE, fileEncoding = "UTF-8", na = "")

cat("\n\n=================================================================\n")
cat("RÉSUMÉ FINAL\n")
cat("=================================================================\n")
cat("\nArticles haute pertinence analysés :", nrow(articles), "\n")
cat("Doublons (déjà dans les 26 inclus) :", nrow(doublons), "\n")
cat("Articles VRAIMENT nouveaux         :", nrow(nouveaux), "\n")
cat("\nFichier exporté :", output_file, "\n")

# Afficher les titres des nouveaux articles
if (nrow(df_final) > 0) {
  cat("\n--- LISTE DES", nrow(df_final), "ARTICLES À SCREENER ---\n\n")
  for (i in 1:nrow(df_final)) {
    ft <- ifelse(!is.na(df_final$FullText_Available[i]), df_final$FullText_Available[i], "?")
    cat(i, ". [", df_final$Year[i], "] ", substr(df_final$Title[i], 1, 80), "...\n", sep = "")
    cat("   Full text: ", ft, " | PMID: ", df_final$PMID[i], "\n", sep = "")
  }
}

# Créer aussi un rapport texte
rapport <- paste0(
  "=================================================================\n",
  "RAPPORT FINAL - ARTICLES NOUVEAUX POUR SCREENING\n",
  "=================================================================\n",
  "\n",
  "Date: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
  "\n",
  "--- CONTEXTE ---\n",
  "Équation originale : termes 'neuromuscular' uniquement\n",
  "Équation étendue   : + catégories (myopathy, dystrophy, etc.)\n",
  "                     + maladies spécifiques (formes longues)\n",
  "\n",
  "--- RÉSULTATS ---\n",
  "Articles haute pertinence (terme NMD dans titre) : ", nrow(articles), "\n",
  "Doublons avec les 26 articles inclus             : ", nrow(doublons), "\n",
  "Articles VRAIMENT nouveaux à screener            : ", nrow(df_final), "\n",
  "\n",
  "--- FICHIER GÉNÉRÉ ---\n",
  "ARTICLES_NOUVEAUX_POUR_SCREENING.csv\n",
  "\n",
  "Colonnes pour le screening :\n",
  "- Screening_Decision : INCLUDE / EXCLUDE\n",
  "- Screening_Reason   : raison de l'inclusion/exclusion\n",
  "- Relevance_Score    : 1-5 (pertinence pour la revue)\n",
  "- Notes              : commentaires libres\n",
  "\n",
  "--- POUR LE REVIEWER ---\n",
  "La stratégie étendue a identifié ", nrow(df_final), " articles additionnels\n",
  "potentiellement pertinents, qui n'avaient pas été captés par l'équation\n",
  "originale utilisant uniquement 'neuromuscular disease/disorder'.\n",
  "\n",
  "=================================================================\n"
)

writeLines(rapport, file.path(output_dir, "rapport_final_screening.txt"))

cat("\n>>> EXTRACTION TERMINÉE <<<\n")
