library('ggplot2')
library('reshape2')
library('scales')
library('plyr')
setwd('/Users/nikhil/docs/data/tpp')

matrix <- read.csv('csv/voting_similarity.csv')
ordered.vals <- subset(matrix[order(matrix$sim_pct, decreasing=T), ], sim_pct < 1)
ordered.vals <- subset(ordered.vals, select = -c(X))

{
p <- ggplot(matrix, aes(partner, voting_country)) + geom_tile(aes(fill = sim_pct)) +
    scale_fill_gradient(low = "white", high = "#002d3d")
}
p

ggsave(p, file='R/similarity_heatmap.png')
