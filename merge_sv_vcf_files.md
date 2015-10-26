
For structural variants, when converted from vcf to bedpe, we have two breakends for each variant per row.

Now, it is necessary to merge the variant calls when both the breakend A and B overlaps for some calls.

It seems to be a very common taskm but it turns out to be much trickier as one thinks.

see posts:
[Merging Structural Variant Calls from Different Callers](http://simpsonlab.github.io/2015/06/15/merging-sv-calls/)  
[how to simplify / merge junction calls in bedpe format](https://groups.google.com/forum/#!topic/bedtools-discuss/JXZbJSwVxUo) on bedtools google group.
>There is no merging functionality for BEDPE files.  I think your best option would be to use pairToPair to find junctions that overlap on both ends (the default), and then write a script around the output to merge the coordinates.  I recognize that this is a non-trivial problem, as I have faced it myself.  Essentially, what you are try to do is equivalent to structural variant clustering algorithms such as VariationHunter or my own Hydra.  If the former solution is inadequate, you could consider using Hydra on the BEDPE input (you'd have to add a few dummy columns) to cluster the junctions.

>Best,
>Aaron

tools I am now looking at:
[mergeVcf](https://github.com/ljdursi/mergevcf)
[lumpy-merge](https://github.com/hall-lab/lumpy-merge)
