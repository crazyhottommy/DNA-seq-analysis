## Notes and tips for speedseq structural variants calling

### For Structural variants
From Colby Chiang:
> QUAL score is usually best to filter sv from speedseq if you've run SVTyper. SU >=3 (supporting reads) if you have not. 
[vawk](https://github.com/cc2qe/vawk) is helpful.
> we've been using QUAL>10 lately but we haven't profiled it's behavior on that many data sets yet

### filtering rules 
See a [post](http://bcb.io/2014/08/12/validated-whole-genome-structural-variation-detection-using-multiple-callers/) by Brad Chapman  and his anwswers to my questions at the comments part.  

> **4 supporting reads is total read evidence (either split reads or paired reads)**

Two more questions. when filtering somatic SVs, I require normal genotype to be 0/0 and tumor genotype to be 0/1 or 1/1 and 0 supporting reads for normal, 4 supporting reads for tumor. Do you think 0 is too stringent? pybamview is good for visualizing deletions, but for translocations, it does not color the discordant read pairs like IGV does (correct me if I am wrong). What's your solution? Thanks! I am learning how to analyze svs by myself...and I appreciate your suggestions.

>That sounds like a reasonable approach for somatic-only SVs. In bcbio we require 4 support reads of evidence and different tumor/normal genotypes as you suggest (0/0 -> 0/1 or 1/1) and don't look specifically at background reads. I don't think that's a bad idea but don't know how much it adds for the extra effort. For visualization, I use IGV or [svviz](https://github.com/svviz/svviz) which has some nice features for handling more complex cases.  

I just found out that Wham tool filters against low complexity regions http://zeeev.github.io/wham/

download the low complexity region (LCR) [here: LCR-hs37d5.bed](https://github.com/zeeev/wham/blob/master/data/LCR-hs37d5.bed)
filter calls overlapping the LCR regions:  

```
pairToBed -type neither  -a NA12878.lumpy.s.bedpe -b LCR-hs37d5.bed

```


**when filtering SV calls, one needs to take account of sequencing depth, tumor purity etc.**

The deeper the sequencing is, the more SV calls. we usually use supporting reads to filter the SV call. Say >= 4 supporting reads. However, if your tumor sample is not pure, even you sequence into the same depth as other samples, you may relax this cut-off to 2?

### For SNVs
From Colby Chiang:  
>The filtering criteria we used in the paper is specified in the methods. Basically SSC is the proper tuning parameter. the default, which is what we used in the paper was 18  

Testing from Siyuan Zheng:
>Siyuan Zheng, 8/28/2015

SpeedSeq is a new computational pipeline that offers fast and integrative processing of whole genome sequencing data. Even though it generally follows the best practice of DNA analysis steps proposed by the Broad, its performance in mutation calling has not been tested. I asked Tommy to run MuTect on BAMs processed by varying settings and compared the outputs. Results were summarized in the excel file. I briefly describe the results in the following document.  

1.	MuTect on original TCGA BAM and SpeedSeq realigned BAM (comparison_1.R)
Tommy’s MuTect results were essentially identical with Hoon’s previous results. In this comparison MuTect was called with default parameters on both BAMs. The realigned BAM clearly yielded more mutations, and the pattern is consistent with all chromosomes. Overall the overlapped mutations took 76% of mutations called on the original BAM and 66% of mutations called on the realigned BAM. Increasing the VAF criterion led to higher overlap. When set the VAF to 0.1, the overlap rose to 88% and 87% respectively.  

2.	MuTect vs SpeedSeq caller (comparison_2.R)  
Both tools were used on the SpeedSeq aligned BAM. SpeedSeq output requires further filtering for fair comparison because it also identifies indels. Furthermore, it has a somatic score (SSC) to indicate the confidence of somatic mutations. In their paper they used SSC 18. To ensure fair comparison, only mutations (a) in canonical chromosomes (b) with “FLAG” as “PASS” (c) single nucleotide variation were retained.   

+ 2.1	In the first comparison MuTect was called with default parameters. SpeedSeq used default SSC (“PASS”, ssc >18). SpeedSeq generated much more mutations than MuTect (51842 vs. 17011), and a total of 11135 overlapped mutations were found. This overlap only accounted for 21% of all speedseq variants. Increasing the SSC cutoff increased the overlap for SpeedSeq. Notably SpeedSeq results were sensitive to this SSC cutoff. SSC>30 reduced the mutation number to 22951, and SSC>40 further reduced it to 10034. After 40 it seems SSC filtering had limited effect.   

+ 2.2	Notably in some cases SpeedSeq called mutations had substantial number of allele reads in normal, which can be used as a criterion to filter its calls. Removal of all mutations with more than 2 variant allele reads in normal dramatically decreased the mutation list to half (from 51842 to 24792). On top of this filter, the increase of SSC to 30 trimmed down the list to 13041, with 10476 overlapped with MuTect (61% to MuTect, 80% to SpeedSeq).   

+ 2.3	On top of 2.2, I limited the minimum VAF to 0.1 for both MuTect and SpeedSeq calls. At SSC >40 the overlapped mutations (n=10023) accounted for 78% and 93% of MuTect and SpeedSeq calls, respectively (n=12850 & n=10747). The fact that the VAF 0.1 cutoff did not affect SpeedSeq calls much at SSC 30 or 40 indicates at these criteria all mutations essentially had VAF more than 0.1. It appears SSC ≥ 40 & n_alt_count ≤ 2 are reasonable cutoff to obtain high quality mutation calls from SpeedSeq. 
