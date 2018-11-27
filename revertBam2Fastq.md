### Why we want to revert bam files back to fastq file?

Sometimes, you get a processed bam file from other resources, but you want to map it with another aligner. For example, the old
BWA aln does not keep the information for soft-cliped reads which are useful for structural variant detection, the new BWA mem is 
more suitable for this. So, I want to dump bam to fastq first and then realign it with BWA MEM.

After googleling around, I found:  
* [bedtools](http://bedtools.readthedocs.org/en/latest/content/tools/bamtofastq.html) `bedtools bamtofastq [OPTIONS] -i <BAM> -fq <FASTQ>`
* [picard](https://broadinstitute.github.io/picard/command-line-overview.html) `samtofastq`
* [samtools](http://www.htslib.org/doc/samtools-1.1.html) `samtools bam2fq`

It turns out that it is not that straightforward.

###Use samtools 
Read this [(howto) Revert a BAM file to FastQ format](http://gatkforums.broadinstitute.org/discussion/2908/howto-revert-a-bam-file-to-fastq-format) in the GATK forum back to 2013.

>Note for advanced users
>If you’re feeling adventurous, you can do all of the above with this beautiful one-liner, which will save you a heap of time that the program would otherwise spend performing I/O (loading in and writing out data to/from disk):

>`htscmd bamshuf -uOn 128 aln_reads.bam tmp | htscmd bam2fq -a - | gzip > interleaved_reads.fq.gz` 

**The `htscmd bamshuf` and `htscmd bam2fq` are legacy code, now they are under `samtools`.**  

But the point is that **you need to shuffle the reads in the bam file**.  
from [Hengli](https://github.com/samtools/htslib/issues/26), the author of samtools and bwa:  
>The right way to create paired fastq for bwa is:  
`htscmd bamshuf -uO in.bam tmp-prefix | htscmd bam2fq -as se.fq.gz - | bwa mem -p ref.fa -`
**If your bam is coordinate sorted, it is important to use "bamshuf" to change the ordering; otherwise bwa will fail to infer insert size for a batch of reads coming from centromeres.**

BWA `-p` flag
>"If mates.fq file is absent and option -p is not set, this command regards input reads are single-end. If mates.fq is present, this command assumes the i-th read in reads.fq and the i-th read in mates.fq constitute a read pair. If -p is used, the command assumes the 2i-th and the (2i+1)-th read in reads.fq constitute a read pair (such input file is said to be interleaved). In this case, mates.fq is ignored. In the paired-end mode, the mem command will infer the read orientation and >the insert size distribution from a batch of reads.

**Updated version**   
>Bam2fq -s only helps when your bam contains singletons. If your bam contains both ends, that option has no effect

`samtools bamshuf -uon 128 in.bam tmp-prefix | samtools bam2fq -s se.fq.gz - | bwa mem -p ref.fa -`

### Use bedtools

From the [bcbio source code](https://github.com/chapmanb/bcbio-nextgen/blob/01a6d99c7a8bb7a73ee35313c8af4c6b4d8c66fe/bcbio/ngsalign/bwa.py#L41-L43):

```python
cmd = ("{samtools} sort -n -o -l 1 -@ {num_cores} -m {max_mem} {in_bam} {prefix1} "
                       "| {bedtools} bamtofastq -i /dev/stdin -fq /dev/stdout -fq2 /dev/stdout "
                       "| {bwa} mem -p -M -t {num_cores} -R '{rg_info}' -v 1 {ref_file} - | ")
```
from the bedtools mannual page:  
> BAM should be sorted by query name (samtools sort -n aln.bam aln.qsort) if creating paired FASTQ with this option.

That's why the command above uses `samtools sort -n` to sort by name. My bam files are huge (300Gb). This might be very time consuming.  

### Speedseq realign

In the [speedseq pipeline](https://github.com/hall-lab/speedseq), there is a script called `bamtofastq.py` 
```
bamtofastq.py
author: Ira Hall (ihall@genome.wustl.edu) and Colby Chiang (cc2qe@virginia.edu)
version: $Revision: 0.0.1 $
description: Convert a coordinate sorted BAM file to FASTQ
             (ignores unpaired reads)

positional arguments:
  BAM                   Input BAM file(s). If absent then defaults to stdin.

optional arguments:
  -h, --help            show this help message and exit
  -r STR, --readgroup STR
                        Read group(s) to extract (comma separated)
  -n, --rename          Rename reads
  -S, --is_sam          Input is SAM format
  -H FILE, --header FILE
                        Write BAM header to file
```

Further reading:  
[questions about bam files](http://gatkforums.broadinstitute.org/discussion/1317/collected-faqs-about-bam-files)  
[http://gatkforums.broadinstitute.org/discussion/1317/collected-faqs-about-bam-files](http://gatkforums.broadinstitute.org/discussion/4805/how-to-use-bwa-mem-for-paired-end-illumina-reads)  

Check read group in the bam file
```bash
$ samtools view /path/to/my.bam | grep '^@RG'
EAS139_44:2:61:681:18781    35  1   1   0   51M =   9   59  TAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAA B<>;==?=?<==?=?=>>?>><=<?=?8<=?>?<:=?>?<==?=>:;<?:= RG:Z:4  MF:i:18 Aq:i:0  NM:i:0  UQ:i:0  H0:i:85 H1:i:31
EAS139_44:7:84:1300:7601    35  1   1   0   51M =   12  62  TAACCCTAAGCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAA G<>;==?=?&=>?=?<==?>?<>>?=?<==?>?<==?>?1==@>?;<=><; RG:Z:3  MF:i:18 Aq:i:0  NM:i:1  UQ:i:5  H0:i:0  H1:i:85
EAS139_44:8:59:118:13881    35  1   1   0   51M =   2   52  TAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAA @<>;<=?=?==>?>?<==?=><=>?-?;=>?:><==?7?;<>?5?<<=>:; RG:Z:1  MF:i:18 Aq:i:0  NM:i:0  UQ:i:0  H0:i:85 H1:i:31
EAS139_46:3:75:1326:2391    35  1   1   0   51M =   12  62  TAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAA @<>==>?>@???B>A>?>A?A>??A?@>?@A?@;??A>@7>?>>@:>=@;@ RG:Z:0  MF:i:18 Aq:i:0  NM:i:0  UQ:i:0  H0:i:85 H1:i:31
...

```

**when align using bwa mem, one can add the read group info by**:  

`bwa mem -R "@RG\tID:foo\tSM:bar"`

#### some bam files contain reads from different read groups. one needs to convert the bam to different fastqs for each read group respectively and then realign each with bwa mem. Lastly, merge all the sorted bam together to get a realigned bam.

#### Check out HengLi's [bwakit](https://github.com/lh3/bwa/tree/master/bwakit)

read this post http://www.nxn.se/valent/2017/12/6/low-mapping-rate-6-converting-sorted-bam-to-fastq

>samtools fastq requires the bam files sort by name   

>samtools collate is your friend

What I am using for my snakemake pipeline https://gitlab.com/tangming2005/snakemake_DNAseq_pipeline/blob/multiRG/Snakefile

```python
if not config["from_fastq"]:
    if config["realign"]:
        rule realign:
            input: get_input_files
            output: temp(["01aln_temp/{sample}.RG{id}.bam", "01aln_temp/{sample}.RG{id}.bam.bai"]), "00log/{sample}.RG{id}.align"
            log:
                bwa = "00log/{sample}.RG{id}.align"
            params:
                jobname = "{sample}_RG{id}",
                ## add read group for bwa mem mapping, change accordingly if you know PL:ILLUMINA, LB:library1 PI:200 etc...
                ## http://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#non-file-parameters-for-rules
                rg = identify_read_groups,
                ID = identify_read_groups_ID
            message: "converting {input} file with read group {params.ID} to fastqs by bedtools and remapping with bwa mem"
            threads: 8
            shell:
                """
                samtools view -br {params.ID} {input} \
                | samtools sort -n -l 1 -@ 8 -m 2G -T 01aln_temp/{wildcards.sample}_{wildcards.id}.tmp \
                | bedtools bamtofastq -i /dev/stdin -fq /dev/stdout -fq2 /dev/stdout \
                | bwa mem -t 8 -p  -M -v 1 -R '{params.rg}' {config[ref_fa]} - 2> {log.bwa} \
                | samtools sort -m 2G -@ 8 -T {output[0]}.tmp -o {output[0]}
                samtools index {output[0]}
                """

```
A new tool [bazam](https://github.com/ssadedin/bazam) A read extraction and realignment tool for next generation sequencing data. Take a look!
