# Search Strategy Sensitivity Analysis

## Sexual Health in Neuromuscular Diseases: A Scoping Review

[![DOI](https://img.shields.io/badge/OSF-10.17605%2FOSF.IO%2F35B96-blue)](https://doi.org/10.17605/OSF.IO/35B96)

This repository contains the sensitivity analysis conducted to verify the comprehensiveness of the search strategy used in the scoping review:

> **"Sexual health in neuromuscular diseases: neglected challenges revealed by a scoping review"**

---

## Context

This repository documents a **sensitivity analysis** conducted to verify the comprehensiveness of the search strategy used in the scoping review.

As PubMed MeSH does not include a single unified heading for all neuromuscular diseases (NMDs), articles indexed only under disease-specific terms might not be captured by umbrella "neuromuscular" terms. This analysis tests whether disease-specific search terms identify additional relevant articles.

---

## Methods

### Original Search Strategy
- Umbrella terms: `"neuromuscular diseases"`, `"neuromuscular disorders"`
- Combined with sexual health terms
- Period: 1983-2024

### Extended Search Strategy
Disease-specific terms were added:
- **Dystrophies**: Duchenne, Becker, myotonic dystrophy, facioscapulohumeral, limb-girdle, Emery-Dreifuss
- **Motor neuron diseases**: amyotrophic lateral sclerosis, spinal muscular atrophy, Kennedy disease
- **Inflammatory myopathies**: dermatomyositis, polymyositis, inclusion body myositis
- **Neuropathies**: Charcot-Marie-Tooth, Guillain-Barré, CIDP, transthyretin amyloidosis
- **Neuromuscular junction**: myasthenia gravis, Lambert-Eaton syndrome
- **Metabolic**: Pompe disease, McArdle disease

**Note**: Ambiguous acronyms (SMA, ALS, BMD, MG, etc.) were avoided to prevent false positives.

---

## Results

| Step | N |
|------|---|
| Original search (PubMed) | 791 |
| Extended search (disease-specific) | 1,082 |
| New records identified | 301 |
| High relevance (NMD in title) | 18 |
| After duplicate removal | 16 |
| **Meeting inclusion criteria** | **1** |

### Article Added to Review

**Hausmanowa-Petrusewicz I, Borkowska J, Janczewski Z. (1983)**
*X-linked adult form of spinal muscular atrophy.*
Journal of Neurology. [PMID: 6191009](https://pubmed.ncbi.nlm.nih.gov/6191009/)

This article reports original data on sexual dysfunction (erectile dysfunction, reduced libido) and reproductive abnormalities in **Kennedy disease (SBMA)**.

### Cochrane Library & Google Scholar

Extended searches were also conducted in Cochrane Library and Google Scholar using disease-specific terms. **No additional relevant articles were identified.**

---

## Repository Structure

```
├── README.md
├── sensitivity_analysis_report.Rmd    # Full analysis report (R Markdown)
├── sensitivity_analysis_report.html   # Rendered HTML report
├── scripts/
│   ├── search_comparison_pubmed.R     # PubMed search comparison
│   ├── filter_relevant_nmd.R          # Relevance filtering
│   ├── extract_new_articles_final.R   # Metadata extraction
│   └── create_exclusion_table.R       # Final exclusion table
├── results/
│   ├── FINAL_EXCLUSION_TABLE_EN.csv   # Screening decisions with justifications
│   ├── pubmed_original_search.csv     # Original search results (791 articles)
│   ├── pubmed_new_articles_raw.csv    # New articles from extended search (301)
│   ├── pubmed_new_high_relevance.csv  # High relevance articles (18)
│   ├── new_articles_for_screening.csv # Articles for final screening (16)
│   └── [filtering reports]
└── data/
    └── equation.txt                   # Original search equations
```

---

## Key Files

| File | Description |
|------|-------------|
| `sensitivity_analysis_report.Rmd` | Complete reproducible analysis |
| `results/FINAL_EXCLUSION_TABLE_EN.csv` | All 16 articles with inclusion/exclusion decisions and justifications |
| `scripts/search_comparison_pubmed.R` | Main PubMed search script |

---

## Reproducibility

### Requirements
- R (>= 4.0)
- R packages: `rentrez`, `dplyr`, `xml2`, `knitr`, `kableExtra`

### Running the Analysis
```r
# Install required packages
install.packages(c("rentrez", "dplyr", "xml2", "knitr", "kableExtra"))

# Run the search comparison
source("scripts/search_comparison_pubmed.R")

# Render the report
rmarkdown::render("sensitivity_analysis_report.Rmd")
```

---

## Citation

If you use this analysis, please cite the original scoping review:

> [Authors]. Sexual health in neuromuscular diseases: neglected challenges revealed by a scoping review. [Journal]. [Year].

---

## License

This work is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

---

## Contact

For questions regarding this analysis, please open an issue or contact the corresponding author.

*Sensitivity analysis conducted: February 2026*
