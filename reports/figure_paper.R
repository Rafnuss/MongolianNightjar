# Stopover probability map #
#Libraries
library(ggplot2)

#Read data
load(paste0("data/4_basic_graph/22BS_basic_graph.Rdata"))
Path_22BS<-as.data.frame(shortest_path)
Path_22BS$Duration_days <- unlist(lapply(static_prob_marginal, function(x) {
  as.numeric(difftime(metadata(x)$temporal_extent[2], metadata(x)$temporal_extent[1], units = "days"))
}))
Path_22BS$Observation<-seq(1,nrow(Path_22BS))

#Probability stopover
Stopover_22BS<-Path_22BS[which(Path_22BS$Duration_days > 1),]
Stopover_Prob_22BS<-static_prob_marginal[Stopover_22BS$Observation]

# reclassify into 4 categories
Stopover_Prob_22BS<- lapply(Stopover_Prob_22BS, function(x){
  summary<-(summary(unique(x)))
  reclass_df<-c(summary[1]-1,summary[2],NA,
                summary[2],summary[3],2,
                summary[3],summary[5],3,
                summary[5],summary[6],4)
  reclass_m <- matrix(reclass_df,ncol = 3,byrow = TRUE)
  x<-reclassify(x,reclass_m)
})
Stopover_Prob_22BS_Spring<-cover(Stopover_Prob_22BS[[13]],Stopover_Prob_22BS[[14]])
Stopover_Prob_22BS<-cover(Stopover_Prob_22BS[[1]],Stopover_Prob_22BS[[2]],Stopover_Prob_22BS[[3]],
                          Stopover_Prob_22BS[[4]],Stopover_Prob_22BS[[5]],Stopover_Prob_22BS[[6]],
                          Stopover_Prob_22BS[[7]],Stopover_Prob_22BS[[8]],Stopover_Prob_22BS[[9]],
                          Stopover_Prob_22BS[[10]],Stopover_Prob_22BS[[11]],Stopover_Prob_22BS[[12]],
                          Stopover_Prob_22BS[[13]])

#Plot
Stopover_Prob_22BS_spdf <- as(Stopover_Prob_22BS, "SpatialPixelsDataFrame")
Stopover_Prob_22BS_df <- as.data.frame(Stopover_Prob_22BS_spdf)
colnames(Stopover_Prob_22BS_df) <- c("value", "x", "y")

Stopover_Prob_22BS_df <- Stopover_Prob_22BS %>%
  as.data.frame(xy=TRUE) %>%
  filter(!is.na(layer)) %>%
  arrange(layer) %>%
  mutate(layerP = cumsum(layer)/sum(layer))

ggplot() +
  geom_tile(data=Stopover_Prob_22BS_df, aes(x=x, y=y, fill=layerP), alpha=0.8,width = 0.5, height = 0.5) +
  scale_fill_fermenter(palette="YlOrRd", direction=1)
