#==============================================================================
### Motivation: NMDS analysis and plots
### Author: Ian Rambo
### Thirteen... that's a mighty unlucky number... for somebody!
#==============================================================================
library(vegan)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
set.seed(47)
#------------------------------------------------------------------------------
#Run python GFF annotation parser to extract KO and COG accessions and their products
input_anno <- "/Users/ian/Documents/phd_research/MANERR_JGI/analysis/metaT/annotation/MANERR_IMG_functional_annotations_metaT.gff"
output_anno <- "/Users/ian/Documents/phd_research/MANERR_JGI/analysis/metaT/annotation/MANERR_IMG_functional_annotations_metaT_products.gff"
parser_path <- "~/development/MetaT/src/img_func_parse.py"
parser_command <- paste("python3",parser_path,"--input",input_anno,"--output",output_anno, sep=' ')
system(parser_command)
#------------------------------------------------------------------------------
###---Metatranscriptome functional annotation
metat_gff_cols <- c("sampleid", "seqid", "source", "type", "start", "stop", "score", "strand", "phase", "product", "accession")
metat_func <- read.table("MANERR_IMG_functional_annotations_metaT_products.gff", sep = "\t", header = FALSE, col.names = metat_gff_cols) %>%
  mutate(sample_date = stringr::str_extract(sampleid, "([0-9]{4})"),
         vegetation_type = stringr::str_extract(sampleid, "[USM]"),
         depth = stringr::str_extract(sampleid, "[USM]([:digit:]{2})")) %>% 
  mutate(depth = as.factor(substr(depth, 2, 3))) %>%
  filter(!grepl("Hypo-rule", accession))
metat_func$vegetation_type[which(metat_func$vegetation_type == "M")] <- "Mangrove"
metat_func$vegetation_type[which(metat_func$vegetation_type == "S")] <- "Spartina"
metat_func$vegetation_type[which(metat_func$vegetation_type == "U")] <- "Unvegetated/Seagrass"
metat_func$sample_date[which(metat_func$sample_date == "0606")] <- "2018-06-06"
metat_func$sample_date[which(metat_func$sample_date == "0608")] <- "2018-06-08"
metat_func$sample_date[which(metat_func$sample_date == "0817")] <- "2018-08-17"
metat_func$sample_date[which(metat_func$sample_date == "0819")] <- "2018-08-19"
#------------------------------------------------------------------------------
###---Accession mapping files
kegg_pathways <- read.table("/Users/ian/development/MetaT/data/annotation_mapping/KEGG_KO_PATHS.txt", sep = "\t", quote = "", header = TRUE) %>%
  dplyr::rename(accession = KO)
cog_names <- read.table("/Users/ian/development/MetaT/data/annotation_mapping/cognames2003-2014.tab", sep = "\t", quote = "", header = TRUE)
cog_func <- read.table("/Users/ian/development/MetaT/data/annotation_mapping/fun2003-2014.tab", sep = "\t", quote = "", header = TRUE) %>%
  dplyr::rename(func = Code) %>%
  dplyr::rename(fcategory = Name)
cog_name_func <- left_join(cog_names, cog_func) %>% rename(accession = COG)
#------------------------------------------------------------------------------
#Randomly sampled toy dataset to make sure things work
#metat_func_toy <- metat_func %>% dplyr::sample_n(size=15000, replace=FALSE)

ko_geochem <- c("Photosynthesis","Methane metabolism","Sulfur metabolism","Pentose phosphate pathway",
                "Starch and sucrose metabolism","Fatty acid metabolism","Carbon fixation pathways in prokaryotes",
                "Biotin metabolism","Nitrogen metabolism","Oxidative phosphorylation")

#Prodigal genes, KO annotations
metat_func_ko_prodigal <- metat_func %>%
  filter(grepl("K[0-9]+", accession) & grepl("Prodigal", source)) %>%
  left_join(kegg_pathways) %>%
  mutate(pathway = as.character(pathway)) %>%
  filter(pathway != is.na(pathway) & pathway != "" & pathway %in% ko_geochem)
#GeneMark genes, KO annotations
metat_func_ko_genemark <- metat_func %>%
  filter(grepl("K[0-9]+", accession) & grepl("GeneMark", source)) %>%
  left_join(kegg_pathways) %>%
  mutate(pathway = as.character(pathway)) %>%
  filter(pathway != is.na(pathway) & pathway != "")
#Prodigal genes, COG annotations
metat_func_cog_prodigal <- metat_func %>%
  filter(grepl("COG[0-9]+", accession) & grepl("Prodigal", source)) %>%
  left_join(cog_name_func) %>%
  na.omit()
#GeneMark genes, COG annotations
metat_func_cog_genemark <- metat_func %>% filter(grepl("COG[0-9]+", accession) & grepl("GeneMark", source)) %>%
  left_join(cog_name_func) %>%
  na.omit()
#------------------------------------------------------------------------------
#Get counts of genes corresponding with each metabolic pathway, and convert
#to a matrix
ko_prodigal_tally <- metat_func_ko_prodigal %>% 
  select(sampleid, pathway) %>% 
  group_by(sampleid, pathway) %>% 
  tally()

ko_prodigal_tally_wide <- ko_prodigal_tally %>%
  tidyr::spread(key = pathway, value = n, fill = 0) %>%
  as.data.frame()

rownames(ko_prodigal_tally_wide) <- ko_prodigal_tally_wide$sampleid
ko_prodigal_tally_wide <- ko_prodigal_tally_wide %>% select(-sampleid)
ko_prodigal_matrix <- as.matrix(ko_prodigal_tally_wide)

ko_prodigal_mds <- vegan::metaMDS(ko_prodigal_matrix, distance="bray",
                                  k=2, maxit=10000, autotransform=TRUE,
                                  weakties=FALSE)

#Shepard/stess plot shows scatter around the regression between the interpoint
#distances in the final configuration (the distances between each pair of communities)
#against their original dissimilarities.
vegan::stressplot(ko_prodigal_mds)

ko_prodigal_mds_scores <- as.data.frame(vegan::scores(ko_prodigal_mds))
ko_prodigal_mds_scores$sampleid <- rownames(ko_prodigal_mds_scores)
ko_prodigal_mds_scores <- ko_prodigal_mds_scores %>%
  right_join(metat_func %>% select(sampleid, vegetation_type, sample_date, depth) %>% distinct()) %>%
  na.omit()

ko_pathway_prodigal_scores <- as.data.frame(vegan::scores(ko_prodigal_mds, "species"))
ko_pathway_prodigal_scores$pathway <- rownames(ko_pathway_prodigal_scores)

ggplot() + 
  geom_text(data=ko_pathway_prodigal_scores,aes(x=NMDS1,y=NMDS2,label=pathway),alpha=0.5,vjust=0.3) +  # add the pathway labels
  geom_point(data=ko_prodigal_mds_scores,aes(x=NMDS1,y=NMDS2,shape=vegetation_type,colour=depth),size=3) + # add the point markers
  geom_text(data=ko_prodigal_mds_scores,aes(x=NMDS1,y=NMDS2,label=sample_date),size=2,vjust=0) +  # add the sample labels
  coord_equal() +
  theme_bw()
