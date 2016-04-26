
>The [GATK](http://gatkforums.broadinstitute.org/gatk/discussion/1601/how-can-i-prepare-a-fasta-file-to-use-as-reference) uses two files to access and safety check access to the reference files:  
a .dict dictionary of the contig names and sizes and a .fai fasta index file to allow  
efficient random access to the reference bases. You have to generate these files in  
order to be able to use a Fasta file as reference.

```bash
java -jar CreateSequenceDictionary.jar R= Homo_sapiens_assembly18.fasta O= Homo_sapiens_assembly18.dict
samtools faidx Homo_sapiens_assembly18.fasta 
```
