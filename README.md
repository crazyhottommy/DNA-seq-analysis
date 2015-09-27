# DNA-seq

### Databases for variants
* [Disease Variant Store](https://rvs.u.hpc.mssm.edu/divas/)
* 



### Tips and lessons learned during my DNA-seq data analysis journey.  

1. [Allel frequency](https://en.wikipedia.org/wiki/Allele_frequency)  
  Allele frequency, or gene frequency, is the proportion of a particular allele (variant of a gene) among all allele copies       being considered. It can be formally defined as the percentage of all alleles at a given locus on a chromosome in a population   gene pool represented by a particular allele.

2. "for SNVs, we are interested in genotype 0/1, 1/1 for tumor and 0/0 for normal. 1/1 genotype is very rare.  
   It requires the same mutation occurs at the same place in two sister chromsomes which is very rare. one possible way to get 
   1/1 is deletion of one chromosome and duplication of the mutated chromosome". Quote from Siyuan Zheng.

3. "Mutect analysis on the TCGA samples finds around 5000 ~ 8000 SNVs per sample." Quote from Siyuan Zheng. 
4. Cell lines might be contamintated or mislabled. [The Great Big Clean-Up](http://mobile.the-scientist.com/article/43821/the-great-big-clean-up)  
5. Tumor samples are not pure, you will always have stromal cells and infiltrating immnue cells in the tumor bulk. When you analyze the data, keep this in mind.


### Mutation caller, structural variant caller

* paper [Making the difference: integrating structural variation detection tools](http://bib.oxfordjournals.org/content/16/5/852.short?rss=1&utm_source=twitterfeed&utm_medium=twitter)
* [An ensemble approach to accurately detect somatic mutations using SomaticSeq](http://www.genomebiology.com/2015/16/1/197#B14) [tool github page](https://github.com/bioinform/somaticseq/)

**A series of posts from Brad Chapman**  

1. [Validating multiple cancer variant callers and prioritization in tumor-only samples](http://bcb.io/2015/03/05/cancerval/)  
2. [Benchmarking variation and RNA-seq analyses on Amazon Web Services with Docker](http://bcb.io/2014/12/19/awsbench/)  
3. [Validating generalized incremental joint variant calling with GATK HaplotypeCaller, FreeBayes, Platypus and samtools](Validating generalized incremental joint variant calling with GATK HaplotypeCaller, FreeBayes, Platypus and samtools)  
4. [Validated whole genome structural variation detection using multiple callers](Validated whole genome structural variation detection using multiple callers)  
5. [Validated variant calling with human genome build 38](http://bcb.io/2015/09/17/hg38-validation/)


### Copy number variants 
* [Interactive analysis and assessment of single-cell copy-number variations](http://www.nature.com/nmeth/journal/vaop/ncurrent/full/nmeth.3578.html): [Ginkgo](http://qb.cshl.edu/ginkgo)   
* 

### Tools for visulization 
1. [New app gene.iobio](http://bib.oxfordjournals.org/content/14/6/671.full)  
[App here](http://gene.iobio.io/?rel0=proband&rel1=mother&rel2=father) I will definetely have it a try.

### Tools for vcf files
1. [tools for pedigree files](https://github.com/brentp/peddy). It can determine sex from PED and VCF files. Developed by Brent Pedersen. I really like tools from Aaron Quinlan's lab.
