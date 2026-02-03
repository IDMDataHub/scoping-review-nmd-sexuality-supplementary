# Search Strategy Sensitivity Analysis

## Sexual Health in Neuromuscular Diseases: A Scoping Review

[![DOI](https://img.shields.io/badge/OSF-10.17605%2FOSF.IO%2F35B96-blue)](https://doi.org/10.17605/OSF.IO/35B96)

This repository contains the sensitivity analysis conducted to verify the comprehensiveness of the search strategy used in the scoping review:

> **"Sexual health in neuromuscular diseases: neglected challenges revealed by a scoping review"**

---

## Context

As PubMed MeSH does not include a single unified heading for all neuromuscular diseases (NMDs), articles indexed only under disease-specific terms (e.g., "Duchenne muscular dystrophy", "amyotrophic lateral sclerosis") might not be captured by umbrella "neuromuscular" terms.

This sensitivity analysis tests whether disease-specific search terms identify additional relevant articles.

---

# Original Search Strategies

## PubMed - Original Search Equation

```
("sexual behaviour"[MeSH Terms] OR ("sexual"[All Fields] AND "behaviour"[All Fields])
 OR "sexual behaviour"[All Fields] OR "sexual"[All Fields] OR "sexually"[All Fields]
 OR "sexualities"[All Fields] OR "sexuality"[MeSH Terms] OR "sexuality"[All Fields]
 OR "sexualization"[All Fields] OR "sexualize"[All Fields] OR "sexualized"[All Fields]
 OR "sexualizing"[All Fields] OR "sexuals"[All Fields])

AND

("neuromuscular diseases"[MeSH Terms] OR ("neuromuscular"[All Fields] AND "diseases"[All Fields])
 OR "neuromuscular diseases"[All Fields] OR ("neuromuscular"[All Fields] AND "disorders"[All Fields])
 OR "neuromuscular disorders"[All Fields])

NOT (neurofibromatosis[MeSH Terms])
NOT (diabetes[MeSH Terms])
NOT (fibromyalgia[MeSH Terms])
NOT (chronic fatigue syndrome[MeSH Terms])
NOT (mice OR mouse)
```

**Period:** 1983-2024

## Google Scholar - Original Search Equation

```
sexuality neuromuscular disorders sexual OR life
-dimorphic -"cerebral palsy" -prostatitis -cancer -stroke
-"chronic respiratory failure" -"multiple sclerosis" -epilepsy
-abuse -diabetes -cardiac -fibromyalgia -neurofibromatosis
-"spinal cord injury" -mouse -"cauda equina lesions"
```

## Cochrane Library - Original Search Equation

```
("sexual dysfunction" OR "sexual function" OR "sexual health" OR "sexuality"
 OR "libido" OR "erectile dysfunction" OR "dyspareunia" OR "orgasmic disorder"
 OR "hypoactive sexual desire disorder" OR "sexual satisfaction")

AND

("neuromuscular disease" OR "neuromuscular disorder")

NOT

("diabetes" OR "fibromyalgia" OR "neurofibromatosis" OR "multiple sclerosis"
 OR "cancer" OR "stroke" OR "epilepsy" OR "spinal cord injury"
 OR "mouse" OR "animal model")
```

---

# Extended Search Strategy

## Rationale

Since PubMed MeSH does not include a single unified heading for all neuromuscular diseases, articles indexed only under disease-specific terms might not be captured by umbrella "neuromuscular" terms.

## Disease-Specific Terms Added (PubMed)

The search strategy was expanded to include specific disease names in **9 groups**:

### Group 1: Umbrella + General Myopathies
```
"neuromuscular diseases"[MeSH Terms] OR "neuromuscular disease"[Title/Abstract]
OR "neuromuscular disorder"[Title/Abstract] OR "myopathy"[Title/Abstract]
OR "myopathies"[Title/Abstract] OR "muscular dystrophy"[Title/Abstract]
OR "muscular dystrophies"[Title/Abstract] OR "Muscular Dystrophies"[MeSH Terms]
OR "congenital myopathy"[Title/Abstract] OR "metabolic myopathy"[Title/Abstract]
OR "mitochondrial myopathy"[Title/Abstract]
```

### Group 2: Inflammatory Myopathies
```
"myositis"[MeSH Terms] OR "inflammatory myopathy"[Title/Abstract]
OR "dermatomyositis"[Title/Abstract] OR "Dermatomyositis"[MeSH Terms]
OR "polymyositis"[Title/Abstract] OR "Polymyositis"[MeSH Terms]
OR "inclusion body myositis"[Title/Abstract] OR "necrotizing myopathy"[Title/Abstract]
OR "antisynthetase syndrome"[Title/Abstract]
```

### Group 3: Motor Neuron Diseases
```
"motor neuron disease"[Title/Abstract] OR "motor neurone disease"[Title/Abstract]
OR "Motor Neuron Disease"[MeSH Terms] OR "amyotrophic lateral sclerosis"[Title/Abstract]
OR "Amyotrophic Lateral Sclerosis"[MeSH Terms] OR "spinal muscular atrophy"[Title/Abstract]
OR "Muscular Atrophy, Spinal"[MeSH Terms] OR "spinal and bulbar muscular atrophy"[Title/Abstract]
OR "Kennedy disease"[Title/Abstract] OR "primary lateral sclerosis"[Title/Abstract]
```

### Group 4: Peripheral Neuropathies
```
"peripheral neuropathy"[Title/Abstract] OR "polyneuropathy"[Title/Abstract]
OR "Polyneuropathies"[MeSH Terms] OR "hereditary motor and sensory neuropathy"[Title/Abstract]
OR "Charcot-Marie-Tooth disease"[Title/Abstract] OR "Charcot-Marie-Tooth Disease"[MeSH Terms]
OR "chronic inflammatory demyelinating polyneuropathy"[Title/Abstract]
OR "Guillain-Barre syndrome"[Title/Abstract] OR "Guillain-Barre Syndrome"[MeSH Terms]
OR "multifocal motor neuropathy"[Title/Abstract]
```

### Group 5: Amyloid Neuropathies
```
"transthyretin amyloidosis"[Title/Abstract] OR "ATTR amyloidosis"[Title/Abstract]
OR "hereditary transthyretin amyloidosis"[Title/Abstract]
OR "Amyloid Neuropathies, Familial"[MeSH Terms]
OR "familial amyloid polyneuropathy"[Title/Abstract]
```

### Group 6: Neuromuscular Junction Disorders
```
"Neuromuscular Junction Diseases"[MeSH Terms]
OR "myasthenia gravis"[Title/Abstract] OR "Myasthenia Gravis"[MeSH Terms]
OR "Lambert-Eaton myasthenic syndrome"[Title/Abstract]
OR "congenital myasthenic syndrome"[Title/Abstract]
```

### Group 7: Myotonic Dystrophy and Channelopathies
```
"myotonic dystrophy"[Title/Abstract] OR "Myotonic Dystrophy"[MeSH Terms]
OR "Steinert disease"[Title/Abstract] OR "myotonia congenita"[Title/Abstract]
OR "paramyotonia congenita"[Title/Abstract] OR "periodic paralysis"[Title/Abstract]
```

### Group 8: Specific Muscular Dystrophies
```
"Duchenne muscular dystrophy"[Title/Abstract] OR "Muscular Dystrophy, Duchenne"[MeSH Terms]
OR "Becker muscular dystrophy"[Title/Abstract]
OR "facioscapulohumeral muscular dystrophy"[Title/Abstract]
OR "limb-girdle muscular dystrophy"[Title/Abstract]
OR "Emery-Dreifuss muscular dystrophy"[Title/Abstract]
OR "oculopharyngeal muscular dystrophy"[Title/Abstract]
OR "congenital muscular dystrophy"[Title/Abstract]
```

### Group 9: Metabolic Myopathies
```
"Pompe disease"[Title/Abstract] OR "Glycogen Storage Disease Type II"[MeSH Terms]
OR "acid maltase deficiency"[Title/Abstract] OR "McArdle disease"[Title/Abstract]
```

## Important Note: Ambiguous Acronyms Avoided

**Ambiguous acronyms were deliberately avoided** to prevent false positives:

| Acronym | Intended meaning | Common false positive |
|---------|-----------------|----------------------|
| SMA | Spinal Muscular Atrophy | Smooth Muscle Actin (histology) |
| ALS | Amyotrophic Lateral Sclerosis | Acid-labile subunit, Advanced life support |
| BMD | Becker Muscular Dystrophy | Bone Mineral Density |
| MG | Myasthenia Gravis | Magnesium |
| FAP | Familial Amyloid Polyneuropathy | Familial Adenomatous Polyposis |
| IBM | Inclusion Body Myositis | Company name |

**Only full disease names were used** in the extended search.

---

# Extended Search - Cochrane Library

**Database:** Cochrane Library (CENTRAL)
**Search date:** February 2026
**Publication date limit:** 1983-2024

```
#1 Sexual health terms (Title, Abstract, Keywords):
("sexual dysfunction" OR "sexual function" OR "sexual health" OR "sexuality"
 OR "erectile dysfunction" OR "libido" OR "dyspareunia" OR "orgasmic disorder"
 OR "hypoactive sexual desire" OR "sexual satisfaction" OR "impotence"):ti,ab,kw

#2 Neuromuscular disease terms (Title, Abstract, Keywords):
("neuromuscular disease" OR "neuromuscular disorder" OR "muscular dystrophy"
 OR "myotonic dystrophy" OR "Steinert disease" OR "amyotrophic lateral sclerosis"
 OR "motor neuron disease" OR "spinal muscular atrophy" OR "Kennedy disease"
 OR "myasthenia gravis" OR "Lambert-Eaton" OR "Charcot-Marie-Tooth"
 OR "dermatomyositis" OR "polymyositis" OR "inclusion body myositis"
 OR "myopathy" OR "polyneuropathy" OR "Guillain-Barre"
 OR "transthyretin amyloidosis" OR "familial amyloid polyneuropathy"
 OR "Duchenne" OR "Becker muscular dystrophy" OR "facioscapulohumeral"
 OR "limb-girdle" OR "Emery-Dreifuss" OR "Pompe disease"
 OR "periodic paralysis" OR "myotonia congenita"):ti,ab,kw

#3 Exclusions:
NOT ("diabetes" OR "diabetic neuropathy" OR "fibromyalgia" OR "neurofibromatosis"
 OR "multiple sclerosis" OR "cancer" OR "stroke" OR "epilepsy"
 OR "spinal cord injury" OR "animal model" OR "mice" OR "mouse"):ti,ab,kw

#4 Final search: #1 AND #2 AND #3
```

**Result:** No additional relevant articles identified.

---

# Extended Search - Google Scholar

Due to Google Scholar's limitations (maximum query length, no MeSH support), the search was conducted using **10 targeted queries**:

| # | Search Query | Results Screened |
|---|-------------|------------------|
| 1 | `"sexual dysfunction" OR "sexuality" "spinal muscular atrophy"` | First 100 |
| 2 | `"sexual dysfunction" OR "sexuality" "myotonic dystrophy" OR "Steinert disease"` | First 100 |
| 3 | `"sexual function" OR "sexuality" "Duchenne muscular dystrophy"` | First 100 |
| 4 | `"sexuality" OR "sexual health" "amyotrophic lateral sclerosis"` | First 100 |
| 5 | `"sexual dysfunction" OR "erectile dysfunction" "myasthenia gravis"` | First 100 |
| 6 | `"sexuality" OR "sexual function" "Charcot-Marie-Tooth"` | First 100 |
| 7 | `"sexual function" OR "sexuality" "dermatomyositis" OR "polymyositis"` | First 100 |
| 8 | `"erectile dysfunction" "transthyretin amyloidosis" OR "familial amyloid polyneuropathy"` | First 100 |
| 9 | `"sexual dysfunction" "Kennedy disease" OR "spinal and bulbar muscular atrophy"` | First 100 |
| 10 | `"sexuality" OR "sexual function" "facioscapulohumeral muscular dystrophy"` | First 100 |

**Exclusion filters applied manually:** diabetes, multiple sclerosis, spinal cord injury, animal studies, pediatric populations.

**Result:** No additional relevant articles identified.

---

# Results

## Search Comparison Summary

| Step | N |
|------|--:|
| Original search (PubMed, umbrella terms only) | 791 |
| Extended search (disease-specific terms) | 1,082 |
| New records identified | 301 |
| High relevance (NMD term in title) | 18 |
| After duplicate removal with included studies | 16 |
| **Meeting inclusion criteria** | **1** |

---

## Complete Screening Table: 16 Additional Articles

| PMID | Year | Title | Decision | Justification |
|------|------|-------|----------|---------------|
| [6191009](https://pubmed.ncbi.nlm.nih.gov/6191009/) | 1983 | X-linked adult form of spinal muscular atrophy | **INCLUDE** | **INCLUDED.** Sexual and reproductive aspects are addressed within the systemic endocrine phenotype of SBMA: gynecomastia, reduced fertility, testicular atrophy, impaired spermatogenesis, erectile dysfunction, and reduced libido. |
| [25356310](https://pubmed.ncbi.nlm.nih.gov/25356310/) | 2014 | The relationship between sexual function and quality of sleep in caregiving mothers of sons with duchenne muscular dystrophy | EXCLUDE | Study focuses on caregiving mothers, not patients with NMD. Population does not meet inclusion criteria. |
| [8789451](https://pubmed.ncbi.nlm.nih.gov/8789451/) | 1996 | Deletions in Xq28 in two boys with myotubular myopathy and abnormal genital development define a new contiguous gene syndrome | EXCLUDE | Describes congenital genital malformations, not sexual dysfunction. No data on sexual function provided. |
| [38162906](https://pubmed.ncbi.nlm.nih.gov/38162906/) | 2024 | Non-motor symptoms in motor neuron disease: prevalence, assessment and impact | EXCLUDE | Sexual dysfunction listed among symptoms but no specific prevalence data or characterization provided. Focus on overall non-motor symptom burden. |
| [23776379](https://pubmed.ncbi.nlm.nih.gov/23776379/) | 2012 | Familial amyloidotic polyneuropathy: current and emerging treatment options for transthyretin-mediated amyloidosis | EXCLUDE | Treatment review. Erectile dysfunction briefly mentioned but no original data on sexual dysfunction provided. |
| [20143571](https://pubmed.ncbi.nlm.nih.gov/20143571/) | 2009 | Familial transthyretin amyloidosis (Russian) | EXCLUDE | Language not meeting criteria (Russian). Erectile dysfunction mentioned only as one symptom without detailed assessment. |
| [19078586](https://pubmed.ncbi.nlm.nih.gov/19078586/) | 2000 | Duchenne muscular dystrophy and glycerol kinase deficiency: a rare contiguous gene syndrome | EXCLUDE | "Sexual ambiguity" relates to adrenal hypoplasia affecting genital development, not sexual dysfunction. |
| [22389795](https://pubmed.ncbi.nlm.nih.gov/22389795/) | 2011 | Patient preference assessment reveals disease aspects not covered by recommended outcomes in polymyositis and dermatomyositis | EXCLUDE | No specific data on sexual dysfunction prevalence or characteristics. Focus on patient-reported outcome priorities. |
| [36339574](https://pubmed.ncbi.nlm.nih.gov/36339574/) | 2022 | Synergistic association of resveratrol and histone deacetylase inhibitors as treatment in amyotrophic lateral sclerosis | EXCLUDE | No content related to sexual function. Focus entirely on neuroprotective treatment strategies. |
| [32707986](https://pubmed.ncbi.nlm.nih.gov/32707986/) | 2020 | Predictors of Depression in Caucasian Patients with Amyotrophic Lateral Sclerosis in Romania | EXCLUDE | No specific data on sexual function. Focus on mood disorders. |
| [32377479](https://pubmed.ncbi.nlm.nih.gov/32377479/) | 2020 | Human T-cell Lymphotropic Virus Type I Associated with Amyotrophic Lateral Sclerosis Syndrome | EXCLUDE | "Sexual" appears only in context of viral transmission, not sexual dysfunction. |
| [30069287](https://pubmed.ncbi.nlm.nih.gov/30069287/) | 2018 | Allgrove syndrome and motor neuron disease | EXCLUDE | No data on sexual function. Focus on neurological phenotype and diagnosis. |
| [32232748](https://pubmed.ncbi.nlm.nih.gov/32232748/) | 2020 | Impact of Non-Cardiac Clinicopathologic Characteristics on Survival in Transthyretin Amyloid Polyneuropathy | EXCLUDE | No data on sexual function. Focus on survival outcomes. |
| [31583185](https://pubmed.ncbi.nlm.nih.gov/31583185/) | 2019 | Carpal tunnel syndrome and associated symptoms as first manifestation of hATTR amyloidosis | EXCLUDE | No content related to sexual function. Focus on early diagnostic features. |
| [34234969](https://pubmed.ncbi.nlm.nih.gov/34234969/) | 2021 | Diffuse Gonococcal Infection in a Patient with Myasthenia Gravis Treated with Eculizumab | EXCLUDE | Co-occurrence incidental. No data on sexual dysfunction related to MG. Focus on infectious disease. |
| [22815032](https://pubmed.ncbi.nlm.nih.gov/22815032/) | 2012 | Congenital adrenal hyperplasia masquerading as periodic paralysis in an adolescent girl | EXCLUDE | Not a primary NMD but endocrine disorder with neuromuscular manifestations. Does not meet inclusion criteria. |

---

## Summary of Exclusion Reasons

| Exclusion Reason | N |
|------------------|--:|
| Population not meeting criteria (caregivers, not patients) | 1 |
| Congenital/developmental abnormalities, not sexual dysfunction | 2 |
| No specific data on sexual dysfunction reported | 7 |
| Language not meeting criteria (Russian) | 1 |
| Not a primary neuromuscular disease | 1 |
| Focus on other outcomes (treatment, survival, infection) | 3 |

---

## Article Added to Review

**Hausmanowa-Petrusewicz I, Borkowska J, Janczewski Z. (1983)**
*X-linked adult form of spinal muscular atrophy.*
Journal of Neurology. [PMID: 6191009](https://pubmed.ncbi.nlm.nih.gov/6191009/)

This article reports original data on **Kennedy disease (SBMA)**:
- Sexual dysfunction: erectile dysfunction, reduced libido
- Reproductive abnormalities: reduced fertility, testicular atrophy, impaired spermatogenesis

---

# Conclusion

The extended search strategy using disease-specific terms identified **301 additional records** not captured by the original umbrella terms.

After screening:
- **1 article met inclusion criteria** and was added to the review
- **15 articles were excluded** (see table above)

**Impact on review:**
- Total included studies: **27** (26 original + 1 additional)
- The additional study provides data on **Kennedy disease (SBMA)**, not previously covered

**This confirms the comprehensiveness of the original search strategy combined with citation tracking.**

---

# Repository Structure

```
├── README.md                          # This file (complete analysis)
├── sensitivity_analysis_report.Rmd    # R Markdown report (reproducible)
├── scripts/
│   ├── search_comparison_pubmed.R     # PubMed search comparison
│   ├── filter_relevant_nmd.R          # Relevance filtering
│   ├── extract_new_articles_final.R   # Metadata extraction
│   └── create_exclusion_table.R       # Final exclusion table
├── results/
│   ├── FINAL_EXCLUSION_TABLE_EN.csv   # Screening decisions with justifications
│   ├── pubmed_original_search.csv     # Original search results (791)
│   ├── pubmed_new_articles_raw.csv    # New articles from extended search (301)
│   ├── pubmed_new_high_relevance.csv  # High relevance articles (18)
│   └── new_articles_for_screening.csv # Final screening (16)
└── data/
    └── equation.txt                   # Original search equations
```

---

# Reproducibility

## Requirements
- R (>= 4.0)
- R packages: `rentrez`, `dplyr`, `xml2`, `knitr`, `kableExtra`

## Running the Analysis
```r
install.packages(c("rentrez", "dplyr", "xml2", "knitr", "kableExtra"))
source("scripts/search_comparison_pubmed.R")
rmarkdown::render("sensitivity_analysis_report.Rmd")
```

---

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

---

*Sensitivity analysis conducted: February 2026*
