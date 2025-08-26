# Lesson 24: Transcriptomic Subtype Discovery with Consensus Clustering

## Objective
To perform unsupervised clustering on transcriptomic data to identify distinct molecular subtypes and annotate them with biologically meaningful names (Classical, Mesenchymal, Proneural, Neural), following the landmark TCGA glioblastoma study approach.

## Why This is Important
This analysis bridges our findings with the established TCGA literature by identifying the well-known molecular archetypes of glioma in our dataset. Unlike the supervised approaches in previous lessons, this unsupervised method discovers natural groupings in the data without prior knowledge of clinical outcomes, providing an independent validation of tumor heterogeneity.

## Methods
1. **Gene Selection**: Uses a focused set of the most important marker genes from the Verhaak et al. signature rather than all 840 genes, for more robust and interpretable results.

2. **Consensus Clustering**: Employs the `ConsensusClusterPlus` algorithm to perform robust, iterative clustering that determines the most stable number of clusters through resampling.

3. **Biological Annotation**: Maps numerical clusters to established biological subtypes by:
   - Calculating mean expression of marker gene sets for each cluster
   - Assigning biological names based on which cluster has highest expression of corresponding markers
   - Handling potential conflicts through systematic assignment rules

4. **Visualization**:
   - **Heatmap**: Shows gene expression patterns across samples ordered by subtype
   - **Survival Analysis**: Tests whether the identified subtypes have prognostic significance

## Expected Results
The analysis will identify 4 molecular subtypes corresponding to the classical TCGA categories. The heatmap will show distinct expression patterns for each subtype, and the survival analysis will reveal whether these molecular classifications have clinical relevance in this cohort.

## Key Innovation
This implementation uses a robust annotation strategy that handles edge cases and conflicts in subtype assignment, ensuring reliable biological interpretation of the clustering results.
