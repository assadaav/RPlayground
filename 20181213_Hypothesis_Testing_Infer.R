# https://www.andrewheiss.com/blog/2018/12/05/test-any-hypothesis/
# Hypothesis testing with package infer()
# Detailed function number still needs to be
# clarified later.

# Load libraries
library(tidyverse)
library(ggridges)
library(scales)
library(infer)

set.seed(1234)  # Make all random draws reproducible

# https://datacatalog.worldbank.org/dataset/worldwide-bureaucracy-indicators
wwbi <- read_csv("WWBIData.csv")

# Create a list of indicators we want to work with
indicators <- c(
  "BI.PWK.PRVS.FE.ZS",  # females as share of private paid employees
  "BI.PWK.PUBS.FE.ZS"   # females as share of public paid employees
)

# Make a small, cleaner subset of the WWBI data
wwbi_small <- wwbi %>% 
  # Only select the columns we care about
  select(country = `Country Name`, country_code = `Country Code`, 
         indicator = `Indicator Code`, starts_with("20")) %>% 
  # Keep only the indicators we care about
  filter(indicator %in% indicators) %>% 
  # Gather all the year-based columns into two long columns
  gather(year, value, starts_with("20")) %>% 
  # Spread the data back out so that there are columns for each indicator
  spread(indicator, value) %>% 
  # Make these indicator names human readable
  rename(share_female_private = `BI.PWK.PRVS.FE.ZS`,
         share_female_public = `BI.PWK.PUBS.FE.ZS`) %>% 
  # Amid all the gathering and spreading, every column has become a character.
  # This converts the year and all the share_* variables back to numbers
  mutate_at(vars(year, starts_with("share")), as.numeric)

wwbi_2012 <- wwbi_small %>% 
  filter(year == 2012) %>% 
  # Get rid of rows that are missing data in the share_* columns
  drop_na(starts_with("share")) %>% 
  # Make this tidy and long, with a column for private or public
  gather(sector, proportion, starts_with("share")) %>% 
  # Make these values even nicer
  mutate(sector = recode(sector,
                         share_female_private = "Women in private sector",
                         share_female_public = "Women in public sector"))

ggplot(wwbi_2012, aes(x = proportion, y = sector, fill = sector)) +
  stat_density_ridges(quantile_lines = TRUE, quantiles = 2, scale = 3, color = "white") + 
  scale_fill_manual(values = c("#98823c", "#9a5ea1"), guide = FALSE) + 
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  labs(x = "Percent of women employed in the sector", y = NULL) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

diff_prop <- wwbi_2012 %>% 
  specify(proportion ~ sector) %>% 
  calculate("diff in medians", 
            order = c("Women in private sector", "Women in public sector"))
diff_prop

pub_private_null <- wwbi_2012 %>% 
  specify(proportion ~ sector) %>% 
  hypothesize(null = "independence") %>% 
  generate(reps = 5000) %>% 
  calculate("diff in medians", 
            order = c("Women in private sector", "Women in public sector"))

# Conveniently, the visualize() function that comes with infer returns a ggplot
# object, so we can continue to add ggplot layers to enhance and clean the plot
pub_private_null %>% 
  visualize(obs_stat = diff_prop) + 
  labs(x = "Difference in median proportion\n(Women in private sector − women in public sector)",
       y = "Count",
       subtitle = "Red line shows observed difference in median proportions") +
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

pub_private_null %>% 
  get_pvalue(obs_stat = diff_prop, direction = "both")
