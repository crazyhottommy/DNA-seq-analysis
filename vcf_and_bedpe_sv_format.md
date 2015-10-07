### VCF format structural variants

The standard format for variants is the vcf. Read the vcf4.2 [specification](https://samtools.github.io/hts-specs/VCFv4.2.pdf).


### BEDPE format

Sometimes, BEDPE format is easier to use for processing.

[BEDPE](http://bedtools.readthedocs.org/en/latest/content/general-usage.html#bedpe-format) is defined in the bedtools documentation.  

See also [here](http://software.10xgenomics.com/docs/pipelines/output/bedpe)  
The BEDPE contains one SV per line with the following tab-delimited columns:

1. chrom1 - chromosome of the first breakpoint

2. start1 - start position of the first breakpoint

3. end1 - end position of the first breakpoint

4. chrom2 - chromosome of the second breakpoint

5. start2 - start position of the second breakpoint

6. end2 - end position of the second breakpoint

7. name - a unique string identifying the SV

8. quality - Phred-like quality score

9. strand1 - strand of the first breakpoint (not currently used; always '+')

10. strand2 - strand of the second breakpoint (not currently used; always '+')

11. filter - a semicolon-delimited list of filters that were applied to the SV, or single period (.) if the SV was not filtered out

12. info - extra information about the SV or a single period (.)
