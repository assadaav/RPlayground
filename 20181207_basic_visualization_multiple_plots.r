#http://www.thinkingondata.com/6-tips-to-make-your-visualizations-look-professional/

library(ggplot2)
visualization <- ggplot(diamonds, aes(carat, fill=cut))+
  geom_histogram(bin=30)
visualization

# Context: title, subtitle and citation
visualization <- visualization +
  labs(
    title = "Histogram for Diamond dataset",
    subtitle = "This is a blahblah",
    caption = "source: gglopt2 package\nauthor: thinkingondata.com"
  )

# Color palette
visualization <- visualization +
  scale_fill_viridis_d()
visualization

# Theme
visualization <- visualization +
  theme_minimal()
visualization

# Remove variables
visualization <- visualization +
  theme(axis.title.x=element_blank(),
        axis.title.y = element_blank())
visualization


# gridExtra: Multiple pics on on page
library(gridExtra)
vis_a <- ggplot(diamonds, aes(x=price, fill=cut))+
  geom_bar(stat="bin")
vis_b <- ggplot(diamonds, aes(x=clarity, fill=clarity))+
  geom_bar()
grid.arrange(vis_a, vis_b)

vis_text <- labs(
  title="Diamond",
  caption = "source: ggplot2 package"
)
vis_a <- ggplot(diamonds, aes(x=price, fill=cut))+
  geom_bar(stat="bin")+
  theme_minimal()+
  vis_text
vis_b <- ggplot(diamonds, aes(x=clarity, fill=clarity))+
  geom_bar()+
  vis_text
grid.arrange(vis_a, vis_b)

# Useful packages for multiple graphs
# 1. gridExtra
# 2. cowplot
# 3. patchwork
