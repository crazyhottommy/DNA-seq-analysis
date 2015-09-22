### Why we want to revert bam files back to fastq file?

Sometimes, you get a processed bam file from other resources, but you want to map it with another aligner. For example, the old
BWA aln does not keep the information for soft-cliped reads which are useful for structural variant detection, the new BWA mem is 
more suitable for this. So, I want to dump bam to fastq first and then realign it with BWA MEM.

After googleling around, I found:  
* [bedtools](http://bedtools.readthedocs.org/en/latest/content/tools/bamtofastq.html) `bedtools bamtofastq [OPTIONS] -i <BAM> -fq <FASTQ>`
* 

It turns out that it is not that straightforward.
