
[post](http://seqanswers.com/forums/showthread.php?t=28100) 
for bowtie1

```bash
Example:
--sam-RG ID:HWI-SN957Lane7 --sam-RG SM:ZEN456A1 --sam-RG LB:ZEN456A1LI5 --sam-RG PI:400 --sam-RG PL:ILLUMINA
```

for bowtie2

```bash
--rg-id HWI-SN957Lane7 --rg SM:ZEN456A1 --rg LB:ZEN456A1LI5 --rg PI:400 --rg PL:ILLUMINA
```

for BWA

```bash
bwa mem -aM -R "@RG\tID:Seq01p\tSM:Seq01\tPL:ILLUMINA\tPI:330" Refgen Seq01pair1.fastq Seq01pair2.fastq > Seq01pairs.sam
```

add @RG post-alignment

use picard or samtools merge

