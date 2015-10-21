
### This is a review of the basic concept of cytoband in molecular/cell biology.

See the original [link](http://www.ncbi.nlm.nih.gov/Class/MLACourse/Modules/Genomes/map_cytogenetic_bands.html) 
by **Strachan, T. and Read, A.P. 1999. Human Molecular Genetics, 2nd ed. New York: John Wiley & Sons.**

>Each human chromosome has a short arm ("p" for "petit") and long arm ("q" for "queue"), separated by a centromere. The ends of the chromosome are called telomeres.

>Each chromosome arm is divided into regions, or cytogenetic bands, that can be seen using a microscope and special stains. The cytogenetic bands are labeled p1, p2, p3,   q1, q2, q3, etc., counting from the centromere out toward the telomeres. At higher resolutions, sub-bands can be seen within the bands. The sub-bands are also numbered from the centromere out toward the telomere.

>For example, the cytogenetic map location of the CFTR gene is 7q31.2, which indicates it is on chromosome 7, q arm, band 3, sub-band 1, and sub-sub-band 2.
The ends of the chromosomes are labeled ptel and qtel. For example, the notation 7qtel refers to the end of the long arm of chromosome 7.

![](https://cloud.githubusercontent.com/assets/4106146/10648688/7db14d06-7805-11e5-91c0-bbbc16fb1136.gif)

#### How to get the cooridnates of the cytobands?

You can find it in the [UCSC database](http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz):  
`wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz | gunzip `

```
head cytoBand.txt  
chr1	0	2300000	p36.33	gneg
chr1	2300000	5400000	p36.32	gpos25
chr1	5400000	7200000	p36.31	gneg
chr1	7200000	9200000	p36.23	gpos25
chr1	9200000	12700000	p36.22	gneg
chr1	12700000	16200000	p36.21	gpos50
chr1	16200000	20400000	p36.13	gneg
chr1	20400000	23900000	p36.12	gpos25
chr1	23900000	28000000	p36.11	gneg
chr1	28000000	30200000	p35.3	gpos25
```
If you have a list of genes with cooridnates and want to see which band each gene reside in, you can use bedtools or bioconductor GRanges package to find out.


