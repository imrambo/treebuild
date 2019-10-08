#install.packages("vegan")
library(vegan)
set.seed(2)
community_matrix=matrix(
  sample(1:100,300,replace=T),nrow=10,
  dimnames=list(paste("community",1:10,sep=""),paste("sp",1:30,sep="")))

example_NMDS=metaMDS(community_matrix, # Our community-by-species matrix
                     k=2)

stressplot(example_NMDS)



plot(example_NMDS)

ordiplot(example_NMDS,type="n")
orditorp(example_NMDS,display="species",col="red",air=0.01)
orditorp(example_NMDS,display="sites",cex=1.25,air=0.01)


treat=c(rep("Treatment1",5),rep("Treatment2",5))

ordiplot(example_NMDS,type="n")
ordihull(example_NMDS,groups=treat,draw="polygon",col="grey90",label=F)
orditorp(example_NMDS,display="species",col="red",air=0.01)
orditorp(example_NMDS,display="sites",col=c(rep("green",5),rep("blue",5)),
         air=0.01,cex=1.25)


#Color convex hulls by treatment
# First, create a vector of color values corresponding of the 
# same length as the vector of treatment values
colors=c(rep("red",5),rep("blue",5))
ordiplot(example_NMDS,type="n")
#Plot convex hulls with colors baesd on treatment
for(i in unique(treat)) {
  ordihull(example_NMDS$point[grep(i,treat),],draw="polygon",
           groups=treat[treat==i],col=colors[grep(i,treat)],label=F) } 
orditorp(example_NMDS,display="species",col="black",air=0.01)
orditorp(example_NMDS,display="sites",col=c(rep("green",5),
                                            rep("blue",5)),air=0.01,cex=1.25)



#If treatment is continuous 
# Define random elevations for previous example
elevation=runif(10,0.5,1.5)
# Use the function ordisurf to plot contour lines
ordisurf(example_NMDS,elevation,main="",col="forestgreen")
# Finally, display species on plot
orditorp(example_NMDS,display="species",col="grey30",air=0.1,
         cex=1)

library(dplyr)
library(tidyr)

setwd("/Users/ian/Documents/phd_research/MANERR_JGI/analysis/metaT/annotation")
#Annotation using KO, COG, SMART, etc. 
metat_gff_cols <- c("sampleid", "seqid", "source", "type", "start", "stop", "score", "strand", "phase", "att")
metat_func_anno <- read.table("MANERR_IMG_functional_annotations_metaT.gff", sep = "\t", header = FALSE, col.names = metat_gff_cols)
#RFAM annotation 
metat_rfam <- read.table("MANERR_IMG_rfam_metaT.gff", sep = "\t", header = FALSE, quote = "")

metat_func_anno %>% mutate(product_source = substring(attr, regexpr("product_source=.*?;", attr) + 1)) %>% head()


