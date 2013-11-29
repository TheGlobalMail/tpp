library('ggplot2')
library('reshape2')
library('scales')
library('plyr')
setwd('/Users/nikhil/docs/data/tpp')

# {
#     positions <- read.csv('mds_positions.csv')

#     p <- ggplot(positions, aes(X0, X1, label=country_name)) +
#         geom_point(size=6) +
#         geom_text(vjust=-1)
#     p

#     ggfilename = paste('country_decisions', i, '.png', sep='')
#     print(ggfilename)
#     ggsave(filename=ggfilename, plot=p)

#     i <- i + 1
# }

matrix <- read.csv('voting_similarity.csv')
ordered.vals <- subset(matrix[order(matrix$sim_pct, decreasing=T), ], sim_pct < 1)
ordered.vals <- subset(ordered.vals, select = -c(X))

{
p <- ggplot(matrix, aes(voting_country, partner)) + geom_tile(aes(fill = sim_pct)) +
    scale_fill_gradient(low = "white", high = "black")
}
p

write.csv(ordered.vals, 'ordered_similarity.csv')