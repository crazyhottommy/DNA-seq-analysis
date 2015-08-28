# DNA-seq

### Tips and lessons learned during my DNA-seq data analysis journey.  

1. [Allel frequency](https://en.wikipedia.org/wiki/Allele_frequency)  
  Allele frequency, or gene frequency, is the proportion of a particular allele (variant of a gene) among all allele copies       being considered. It can be formally defined as the percentage of all alleles at a given locus on a chromosome in a population   gene pool represented by a particular allele.

2. "for SNVs, we are interested in genotype 0/1, 1/1 for tumor and 0/0 for normal. 1/1 genotype is very rare.  
   It requires the same mutation occurs at the same place in two sister chromsomes which is very rare. one possible way to get 
   1/1 is deletion of one chromosome and duplication of the mutated chromosome". Quote from Siyuan Zheng.

3. "Mutect analysis on the TCGA samples finds around 5000 ~ 8000 SNVs per sample." Quote from Siyuan Zheng. 
