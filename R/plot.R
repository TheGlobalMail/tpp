library('ggplot2')

positions <- read.csv('positions.csv')

p <- ggplot(positions, aes(X0, X1, color=country_name)) + geom_point(size=6)

# ggsave(filename='country_decisions.png', plot=p)