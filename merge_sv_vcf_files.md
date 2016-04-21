
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
[mergeVcf](https://github.com/ljdursi/mergevcf). [A post on it](http://simpsonlab.github.io/2015/06/15/merging-sv-calls/)  
[lumpy-merge](https://github.com/hall-lab/lumpy-merge)  
[svtools](https://github.com/hall-lab/svtools). migrating the `lumpy-merge` to `svtools`, still under active development.  
see a [workflow](https://github.com/hall-lab/svtools/blob/master/svtools_demo.sh) using svtools.  

[mergeSVcallers](https://github.com/zeeev/mergeSVcallers) from Zev who also developed [Wham](https://github.com/zeeev/wham), a new SV caller. merging for translocations are not implemented yet, but in the plan of Zev.

**I have written a blog [post](http://crazyhottommy.blogspot.com/2016/03/breakpoints-clustering-for-structural.html) for this type of task using InteractionSet bioconductor pacakge** 

In the next release of bioconductor (April 22, 2016), the `rtracklayer` package will have a way to [represent GRange pairs](https://support.bioconductor.org/p/78082/#79195).
