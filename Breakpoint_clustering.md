When structural variants are represented in `bedpe` format, 
each structural variant is represented as two lined breakpoints. 
Each breakpoint is represented as a genomic interval (Granges).

e.g.

`chr1 100 200  chr2  300 400` 

one of the common task is to merge the breakpoints when they are overlapping.
         
---------|---------|-----------------------|----------|-----    

-----|---------|-------------------------|---------------|---

merged to 

-----|-------------|---------------------|---------------|---

It is not a trival problem as stated by Aaron Qunlan in this [post](https://groups.google.com/forum/#!topic/bedtools-discuss/JXZbJSwVxUo)

It is the so called "breakpoint clustering" problem. I am going to use `InteractionSet` bioconductor package to 
solve this problem.

Please also check `clusterPairs` function in the [diffHic](https://www.bioconductor.org/packages/release/bioc/html/diffHic.html) package.

see [answer](https://support.bioconductor.org/p/78082/#79139) from the author of `InteractionSet`. Note that `InteractionSet` 
is still under development. Install it using devtools: `install_github("LTLA/InteractionSet")`

Make some dummy GRanges.
```{r}
library(InteractionSet)
all.regions <- GRanges(rep("chrA",8), 
    IRanges(c(1,6,2,9,5,2,15,20), c(3,10,4,12,7,4,18,23)))
index.1 <- c(1,3,5,7)
index.2 <- c(2,4,6,8) 
```


Using `mode`=`strict` when constructing the GInteraction object or using the `swapAnchors` method is to ensure that the first anchor index is always less than the second anchor index for each interaction. This eliminates redundant permutations of anchor regions and ensures that an interaction between regions #1 and #2 is treated the same as an interaction between regions #2 and #1. Obviously, this assumes that redundant permutations are uninteresting.

```{r}
gi <- GInteractions(index.1, index.2, all.regions, mode ="strict")

gi
```

The first three pairs of interactions can be merged. Note that two anchors of each pair are overlapping. First, use `findOverlaps` for GInteraction object to find out which pairs with two anchors are overlapping. (2D overlapping)

```{r}

out<- findOverlaps(gi)

out
```

This will identify all pairs of interactions in gi that have two-dimensional overlaps with each other, i.e., both anchor regions in one interaction overlap with corresponding anchor regions in the other interaction. Using graph algorithm to cluster the anchors (I myself is by no means an algorithm person :)). We then do:

```{r}
library(RBGL)

## need to trick the function by specifying edgemode to be directional
g <- ftM2graphNEL(as.matrix(out), W=NULL, V=NULL, edgemode="directed")

## if you want to see what's going on
library(Rgraphviz)
plot(g)

## change it back to undirected
edgemode(g) <- "undirected"

plot(g)
connections <- connectedComp(g)
```

To identify groups of interactions that overlap at least one other interaction in the same group (i.e., "single-linkage clusters" of interactions that have overlapping areas in the two-dimensional interaction space). The clusters can be explicitly identified using:

```{r}
cluster <- integer(length(gi))
for (i in seq_along(connections)) {
    cluster[as.integer(connections[[i]])] <- i
}
```

We can then identify the bounding box (merge the overlapping interactions) for each cluster of interactions with:

```{r}
boundingBox(gi, cluster)

```


### overlap with one anchor and get the othe anchor
I have `of.interest` overlaps with the `second` anchor, and I want to return the `first` anchor. how can I do it?

e.g.


        first (promoters)                      second
------|-------------|----------------------|------------|--------   gi

                                   |------------|        of.interest (enhancers)

```{r}

# get overlaps between of.interest and first anchor
hits1 <- findOverlaps(gi, of.interest, use.region="first")
anchors(gi[queryHits(hits1),], type="first") # overlapping
anchors(gi[queryHits(hits1),], type="second") # "other"
of.interest[subjectHits(hits1)]

# get overlaps # between of.interest and second anchor
hits2 <- findOverlaps(gi, of.interest, use.region="second")
anchors(gi[queryHits(hits2),], type="second") # overlapping
anchors(gi[queryHits(hits2),], type="first") # "other"
of.interest[subjectHits(hits2)]

```


If you're willing to sacrifice some information, you might consider using the linearize method:

```{r}
gi$index <- seq_along(gi)
linearize(gi, of.interest[1])
linearize(gi, of.interest[2])

```

This will return a GRanges containing the "other" anchor region for all interactions that overlap each entry in of.interest (you can figure out what those interactions were by looking at index in the returned object). linearize also provides options for handling "internal" interactions where both anchor regions overlap the specified entry of of.interest; by default, the union of the two anchor regions is returned for such interactions, but they can be removed entirely by setting internal=FALSE.


### Alternatively, if you already have two sets of regions(promoters, enhancers) you want to know which enhancer links to which promoter

```{r}
all.enhancers<- GRanges(c("chrA","chrA"), IRanges(c(2,17), c(5,19)))
all.genes<- GRanges(c("chrA","chrA"), IRanges(c(4,6), c(7,16)))

linkOverlaps(gi, all.genes, all.enhancers)
```

which two genes are linked?

```{r}
linkOverlaps(gi, all.genes)
```

which two enhancers are linked? 

```{r}
linkOverlaps(gi, all.enhancers)
```
