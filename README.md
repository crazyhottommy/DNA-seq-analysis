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
6. the devil 0 based and 1 based coordinate systems! Make sure you know which system your file is using:
![](https://camo.githubusercontent.com/3937606a47ad455b9bf2ba9bfca9e91f5afbb3a8/68747470733a2f2f692e696d6775722e636f6d2f337449445574442e706e67)

credit from Vince Buffalo.
Also, read this [post](https://standage.github.io/on-genomic-interval-notation.html) and this [post](https://www.biostars.org/p/84686/)  


### Mutation caller, structural variant caller

* paper [Making the difference: integrating structural variation detection tools](http://bib.oxfordjournals.org/content/16/5/852.short?rss=1&utm_source=twitterfeed&utm_medium=twitter)
* [GATK HaplotypeCaller Analysis of BWA (mem) mapped Illumina reads](http://wiki.bits.vib.be/index.php/GATK_HaplotypeCaller_Analysis_of_BWA_(mem)_mapped_Illumina_reads)
* [NGS-DNASeq_GATK-session.pdf](https://github.com/crazyhottommy/DNA-seq-analysis/files/94758/NGS-DNASeq_GATK-session.pdf)  
* [GATK pipeline](https://github.com/crazyhottommy/GATK-pipeline)  
* [An ensemble approach to accurately detect somatic mutations using SomaticSeq](http://www.genomebiology.com/2015/16/1/197#B14) [tool github page](https://github.com/bioinform/somaticseq/)
* [lumpy](https://github.com/arq5x/lumpy-sv)
* [wham](https://github.com/zeeev/wham)
* [SV-Bay](https://github.com/InstitutCurie/SV-Bay )  
* [Delly](https://github.com/tobiasrausch/delly)
* [COSMOS](http://seselab.org/cosmos/): Somatic Large Structural Variation Detector
* Fusion And Chromosomal Translocation Enumeration and Recovery Algorithm [(FACTERA)](https://factera.stanford.edu/)  

**A series of posts from Brad Chapman**  

1. [Validating multiple cancer variant callers and prioritization in tumor-only samples](http://bcb.io/2015/03/05/cancerval/)  
2. [Benchmarking variation and RNA-seq analyses on Amazon Web Services with Docker](http://bcb.io/2014/12/19/awsbench/)  
3. [Validating generalized incremental joint variant calling with GATK HaplotypeCaller, FreeBayes, Platypus and samtools](http://bcb.io/2014/10/07/joint-calling/)  
4. [Validated whole genome structural variation detection using multiple callers](http://bcb.io/2014/08/12/validated-whole-genome-structural-variation-detection-using-multiple-callers/)  
5. [Validated variant calling with human genome build 38](http://bcb.io/2015/09/17/hg38-validation/)


### Copy number variants 
* [Interactive analysis and assessment of single-cell copy-number variations](http://www.nature.com/nmeth/journal/vaop/ncurrent/full/nmeth.3578.html): [Ginkgo](http://qb.cshl.edu/ginkgo)   
* 

### Tools for visulization 
1. [New app gene.iobio](http://bib.oxfordjournals.org/content/14/6/671.full)  
[App here](http://gene.iobio.io/?rel0=proband&rel1=mother&rel2=father) I will definetely have it a try.

### Tools for vcf files
1. [tools for pedigree files](https://github.com/brentp/peddy). It can determine sex from PED and VCF files. Developed by Brent Pedersen. I really like tools from Aaron Quinlan's lab.
2. [cyvcf2](https://github.com/brentp/cyvcf2) is a cython wrapper around htslib built for fast parsing of Variant Call Format (VCF) files
3. [PyVCF](http://pyvcf.readthedocs.org/en/latest/) - A Variant Call Format Parser for Python

### Annotate variants
1. Variant Effect Predictor: [VEP](http://useast.ensembl.org/info/docs/tools/vep/index.html)
2. [SNPEFF](http://snpeff.sourceforge.net/)
3. [vcfanno](https://github.com/brentp/vcfanno)
4. [myvariant.info](http://myvariant.info/) [tutorial](https://github.com/SuLab/myvariant.info/blob/master/docs/ipynb/myvariant_R_miller.ipynb) 
5. [FunSeq2](http://funseq2.gersteinlab.org/)- A flexible framework to prioritize regulatory mutations from cancer genome sequencing
6. [ClinVar](https://github.com/macarthur-lab/clinvar)  
7. [ExAC](http://exac.broadinstitute.org/)

### Plotting
1.[oncoprint](https://bioconductor.org/packages/release/bioc/vignettes/ComplexHeatmap/inst/doc/s8.oncoprint.html)

### Tumor purity
* ESTIMATE
* ABSOLUTE
* THetA
* [Reference-free deconvolution of DNA methylation data and mediation by cell composition effects](http://biorxiv.org/content/early/2016/01/22/037671)
* [paper: Toward understanding and exploiting tumor heterogeneity](http://www.ncbi.nlm.nih.gov/pubmed/26248267)  
* [paper: The prognostic landscape of genes and infiltrating immune cells across human cancers](http://www.ncbi.nlm.nih.gov/pubmed/26193342)  from Alizadeh lab.
* [Robust enumeration of cell subsets from tissue expression profiles](http://www.nature.com/nmeth/journal/v12/n5/abs/nmeth.3337.html)  from Alizadeh lab, and the [CIBERSORT tool](https://cibersort.stanford.edu/index.php)  

### mutual exclusiveness of mutations
* [MEGSA](http://biorxiv.org/content/early/2015/04/09/017731): A powerful and flexible framework for analyzing mutual exclusivity of tumor mutations.
* [CoMet](https://github.com/raphael-group/comet)  

### Non-coding mutations
* [Large-scale Analysis of Variants in noncoding Annotations](http://larva.gersteinlab.org/)


### CRISPR
*[The caRpools package - Analysis of pooled CRISPR Screens](https://cran.r-project.org/web/packages/caRpools/vignettes/CaRpools.html)
