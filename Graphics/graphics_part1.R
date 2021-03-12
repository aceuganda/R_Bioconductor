#!/usr/bin/env Rscript

#' ---
#' title: "Generating graphics in R - part I"
#' subtitle: "MSB7102: R programming and Bioconductor"
#' author: Poorani Subramanian
#' email: 'poorani.subramanian@nih.gov'
#' ---



#' Data is from:
#' 
#' Choudhury, A., Aron, S., Botigué, L.R. *et al.* High-depth African genomes inform human migration and health. *Nature* **586**, 741–748 (2020). https://doi.org/10.1038/s41586-020-2859-7
#' 
#' This paper analyzed whole genome sequencing data from 585 individuals in order to
#'  characterize their genomic variation.  The individuals
#' were separated into different populations based on their ethnolinguistic group.  The 
#' genomic variants - [single nucleotide variants](https://www.sciencedirect.com/science/article/pii/B9780124047488000083) - were characerized in different ways and summarized 
#' for each population.
#' 
#' Data cleaned in [clean_data.R](clean_data.R) 
#' 
#' read in cleaned data
data <- read.delim("Supp_Meth_T1_Supp_T4_merged.txt", stringsAsFactors = F)
names(data)[names(data) == "X.2x.within.population"] <- "gt.2x.within.population"
data


#' ## ggplot2

#' ggplot2 is based on *The Grammar of Graphics* by [Leland Wilkinson](https://www.cs.uic.edu/~wilkinson/TheGrammarOfGraphics/GOG.html).  In R, we associate [GoG with Hadley Wickham](https://vita.had.co.nz/papers/layered-grammar.pdf) the author of ggplot2.  He is very influential in R programming - started the "tidyverse."  ggplot2 is probably the MOST popular plotting package in R.

library(ggplot2)

#' ### Basics

#' 1. start with ggplot function - specify data and "aesthetics"
#' 2. add "geoms" which are the type of plot (points, lines, bars, etc)
#' 3. add "scales" which further specify the aesthetics: axes, colors, sizes
#'

#' *Aesthetics* map from variables in the data to components of the graph. A **scatterplot**
ggplot(data, aes(x=Population.Code, y=Sequence.Count)) + geom_point()


#' ## Scales (inc. Colors)
#'
#' Plot log of Sequence Count first making separate column logSC holding
#' log10 of data
data$logSC <- log10(data$Sequence.Count)
ggplot(data, aes(x=Population.Code, y=logSC)) + geom_point()



#' Could also change the scale.  *Scales* change the scale (quantitative or qualitative) of an aesthetic mapping.
ggplot(data, aes(x=Population.Code, y=Sequence.Count)) + geom_point() + scale_y_log10()




#' Change the breaks, labels (plotmath), limits
ggplot(data, aes(x=Population.Code, y=Sequence.Count)) + geom_point() + scale_y_log10(breaks=c(3*pi,20,30, 40, 50))

ggplot(data, aes(x=Population.Code, y=Sequence.Count)) + geom_point() + scale_y_log10(breaks=c(3*pi,20,30, 40, 50), labels=c(9.42, 20, 30, 40, 50))

#' very fancy label
ggplot(data, aes(x=Population.Code, y=Sequence.Count)) + geom_point() + scale_y_log10(breaks=c(3*pi, 20,30, 40, 50), labels=do.call(expression, c(bquote(3*pi), 20,30, 40, 50)))


#' We can color the points based on Country
ggplot(data, aes(x=Population.Code, y=Sequence.Count, color=Country)) + geom_point()

#' We can color the points based on total number of variants
ggplot(data, aes(x=Population.Code, y=Sequence.Count, color=Total.Variants)) + geom_point()

#' **Q:** Why the difference in the color scales?
#'
#' **A:** Because we have different classes of variables.  Total.Variants is a continuous numeric. And Country is a discrete character/factor.
class(data$Total.Variants)
class(data$Country)

#' Other continuous palettes we can use for gradients with built-in color palette
?rainbow
ggplot(data, aes(x=Population.Code, y=Sequence.Count, color=Total.Variants)) + geom_point() + scale_color_gradientn(colors=rainbow(5))


#' What factors affect Total Variants? Sequence.Count? Post.QC.Count? Approximate.Seq.Depth?
#' The dataset has one sequence/sample per individual in the study.  Does the total number of
#' variants increase with the number of sequences?  
#' 
#' We should use the Post.QC.Count column instead of Sequence.Count because some 
#' sequences were eliminated due to poor quality, so the variants were only
#' determined from those that passed QC.
ggplot(data, aes(x=Population.Code, y=Post.QC.Count, color=Total.Variants)) + geom_point() + scale_color_gradientn(colors=rainbow(5))


#' The legend represents the scale, so use scale function to change some elements.
#' Change limits to 14000000 up to 22000000.  What happens to points with
#' `Total.Variants < 14000000`?
ggplot(data, aes(x=Population.Code, y=Post.QC.Count, color=Total.Variants)) + geom_point() + scale_color_gradientn(colors=rainbow(5), limits=c(14000000, 22000000))


#' Turn off scientific notation labels using format explicitly or as function
labels <- 10^6*c(12,14,16,18,20)
newlabels <- format(labels, scientific=F)

ggplot(data, aes(x=Population.Code, y=Post.QC.Count, color=Total.Variants)) + geom_point() + scale_color_gradientn(colors=rainbow(5), labels = newlabels)

ggplot(data, aes(x=Population.Code, y=Post.QC.Count, color=Total.Variants)) + geom_point() + scale_color_gradientn(colors=rainbow(5), labels = function(x) format(x, scientific=F))


#' Change name of legend
ggplot(data, aes(x=Population.Code, y=Post.QC.Count, color=Total.Variants)) + geom_point() + scale_color_gradientn(colors=rainbow(5), labels = function(x) format(x, scientific=F), name="total num\nof variants")



#' **Let's make a plot like Fig. 3b in paper**
#' 
#' Reading the paper, Figure 3 only used the data from the H3Africa dataset
#' that had 30x sequencing depth.  So we make a subset data frame with only those
#' populations
sub <- subset(data, !is.na(Count.after.outlier.removal))

#' The populations in 3b were sorted in decreasing order of the number of Novel variants,
#' so we sort our data frame the same way.
neworder <- order(sub$Novel.variants, decreasing = T)
sub <- sub[neworder,]

#' In the paper, they say:  
#' 
#' >Novel variant discovery was also represented as a cumulative function, in which we sequentially plotted the number of novel variants that were discovered each time a new population was included.
#' 
#' I am not sure the exact method used - they may have only added the novel variants
#' that were not shared with previous population in sequential order
#' But, we do not have the fine-grained information on how many variants are shared between
#' each pair of populations.  So, we will approximate this (disregarding the shared variants) 
#' using the `cumsum` function to calculate the cumulative sum.
sub$Add.variants <- cumsum(sub$Novel.variants)
sub

ggplot(sub, aes(x=Population.Code, y=Add.variants, color=Country)) + geom_point()

#' The x-axis is not in the correct order.  What kind of scale is it?  Discrete! 
#' We use the *limits* arg of `scale_x_discrete` to change the order.
ggplot(sub, aes(x=Population.Code, y=Add.variants, color=Country)) + geom_point() + scale_x_discrete(limits=sub$Population.Code)

#' For discrete color scales, we use `scale_color_manual` to *manually* change the colors.  We give one color for every distinct value of Country in our data. And use color scale to manually set the colors(see `help(colors)` for different colors you can use).  Can also change size of points in geom_point.
length(unique(sub$Country))
colors <- c("red", "green", "yellow", "blue", "purple", "brown", "orange")

ggplot(sub, aes(x=Population.Code, y=Add.variants, color=Country)) + geom_point() + scale_x_discrete(limits=sub$Population.Code) + scale_color_manual(values=colors)

#' Increase the size of the points using *size* argument to `geom_point`. 
ggplot(sub, aes(x=Population.Code, y=Add.variants, color=Country)) + geom_point(size=3) + scale_x_discrete(limits=sub$Population.Code) + scale_color_manual(values=colors)

#' ### Saving plots
#'
#' Save most recent plot to file
ggsave("plot1.pdf")

#' Can also assign variable name to plot and then save that.
myplot <- ggplot(data, aes(x=Population.Code, y=Post.QC.Count, color=Total.Variants)) + geom_point() + scale_color_gradientn(colors=rainbow(5), labels = function(x) format(x, scientific=F), name="total num\nof variants")
ggsave("myplot.pdf", plot=myplot)

#' ## Geoms
#'
#' Change **geom** to change type of plot
ggplot(sub, aes(x=Population.Code, y=Novel.variants)) + geom_col()

#' ### Long vs wide data

#' Suppose we want to plot a **Stacked bar graph** of the novel variants, showing
#' the proportion of singletons and proportion found >=2 times in the population
sub$singleton <- sub$Novel.variants - sub$gt.2x.within.population


#' ggplot expects **long data**.  Long data is where each column corresponds to a single variable, so you can match up variables to aesthetics.

#' Use `pivot_longer` from tidyr or `melt` from reshape2
long <- reshape2::melt(sub, measure.vars = c("singleton", "gt.2x.within.population"), variable.name="Frequency", value.name = "Num.variants")

long <- tidyr::pivot_longer(sub, cols = c("singleton", "gt.2x.within.population"), names_to="Frequency", values_to="Num.variants")

#' Now we can color our bars based on the Frequency
ggplot(long, aes(x=Population.Code, y=Num.variants, fill=Frequency)) + geom_col()

#' Unstacked barplot using position dodge or fill
ggplot(long, aes(x=Population.Code, y=Num.variants, fill=Frequency)) + geom_col(position = "dodge") 
ggplot(long, aes(x=Population.Code, y=Num.variants, fill=Frequency)) + geom_col(position = "fill") 



#' ## Theme
#'
#' Can make cosmetic changes with `theme`. text angle, justification, size, background colors, etc
?theme
?element_text
ggplot(long, aes(x=Population.Code, y=Num.variants, fill=Frequency)) + geom_col() + theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))


#' Save your theme to a variable, so you can re-use it over and over.
mytheme <- theme_light() + theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5))
ggplot(long, aes(x=Population.Code, y=Num.variants, fill=Frequency)) + geom_col() + mytheme


#' ## Facets
#'
#' For **pie graph** add polar coordinates mapping y to angle
#' - try different geom_col position
ggplot(long, aes(x=Population.Code, y=Num.variants, fill=Frequency)) + geom_col(position="fill") + coord_polar(theta="y")

#' plot single pie with x=0
longsub <- subset(long, Population.Code == "BOT")
ggplot(longsub, aes(x=0, y=Num.variants, fill=Frequency)) + geom_col(position="fill") + coord_polar(theta="y")

#' if we try plotting the entire dataset, it makes a single pie, adding up all the singleton
#' and gt.2x.within.population for the proportions.  can see this better if we don't use
#' *position="fill"* because then we can see the actual values instead of the proportions.
#' We see values like 2x10^6 - much greater than any value in `Num.variants` column
ggplot(long, aes(x=0, y=Num.variants, fill=Frequency)) + geom_col() + coord_polar(theta="y") 


#' to separate them out by population, use facets
ggplot(long, aes(x=0, y=Num.variants, fill=Frequency)) + geom_col(position = "fill") + coord_polar(theta="y") + facet_wrap(vars(Population.Code)) + mytheme

