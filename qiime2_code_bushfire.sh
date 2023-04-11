#!/bin/bash

#Activate qiime2

conda activate qiime2-2022.2

#change into working directory

cd /qiime_working 

#1) import manifest file

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest_file.txt \
  --output-path paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

	#view demux sequences
	qiime demux summarize \
	  --i-data paired-end-demux.qza \
	  --o-visualization demux_seqs.qzv

#2) join paired reads 

qiime vsearch join-pairs \
  --i-demultiplexed-seqs paired-end-demux.qza \
  --o-joined-sequences demux-joined.qza

	#view paired reads
	qiime demux summarize \
	  --i-data demux-joined.qza \
	  --o-visualization demux-joined.qzv

#3) quality filter joined reads
	  
qiime quality-filter q-score \
  --i-demux demux-joined.qza \
  --o-filtered-sequences demux-joined-filtered.qza \
  --o-filter-stats demux-joined-filter-stats.qza
 
 
#4) use deblur and trim to 250bp (based on visualising joined reads)
  
qiime deblur denoise-16S \
  --i-demultiplexed-seqs demux-joined-filtered.qza \
  --p-trim-length 250 \
  --p-sample-stats \
  --o-representative-sequences rep-seqs.qza \
  --o-table table.qza \
  --o-stats deblur-stats.qza
  
  qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv

#5) generate tree for phylogenetic diversity analysis 

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
  
#6) alpha rarefaction (choose the number where sampling depth keeps 50% of samples)
qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 57000 \
  --m-metadata-file sample-metadata-bushfire.txt \
  --o-visualization alpha-rarefaction.qzv
  
#7) core metrics alpha and beta diversity (choose number where rarefraction curve plateaus and keep as many samples as possible)
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 35000 \
  --m-metadata-file sample-metadata-bushfire.txt \
  --output-dir core-metrics-results
  
  
#Alpha diversity metrics:
  
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/observed_features_vector.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --o-visualization core-metrics-results/observed_features_vector.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --o-visualization core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --o-visualization core-metrics-results/evenness-group-significance.qzv
  
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/shannon_vector.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --o-visualization core-metrics-results/shannon-group-significance.qzv
  
#Beta diversity metrics:

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column fire-area \
  --o-visualization core-metrics-results/unweighted-unifrac-fire-area-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column fire-area \
  --o-visualization core-metrics-results/weighted-unifrac-fire-area-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column fire-time \
  --o-visualization core-metrics-results/unweighted-unifrac-fire-time-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column fire-time \
  --o-visualization core-metrics-results/weighted-unifrac-fire-time-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column fire-category \
  --o-visualization core-metrics-results/unweighted-unifrac-fire-category-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column fire-category \
  --o-visualization core-metrics-results/weighted-unifrac-fire-category-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column season \
  --o-visualization core-metrics-results/unweighted-unifrac-season-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column season \
  --o-visualization core-metrics-results/weighted-unifrac-season-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column breeding-season \
  --o-visualization core-metrics-results/unweighted-unifrac-breeding-season-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --m-metadata-column breeding-season \
  --o-visualization core-metrics-results/weighted-unifrac-breeding-season-significance.qzv \
  --p-pairwise
  
  
#8) Classifying taxa 
qiime feature-classifier classify-sklearn \
  --i-classifier SILVA-v138-515f-806r-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
  
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file sample-metadata-bushfire.txt \
  --o-visualization taxa-bar-plots.qzv