The svtools is under active development. now the command is executed as subcommands:

```bash
svtools -h
svtools vcftobedpe -h
svtools lmerge
svtools prune
```

I am testing the `svtools 0.2.0`, note that the behaviour of vcftobedpe has changed 
Now the output bedpe has a vcf style header and more columns are added.

```bash
##convert to bedpe
svtools vcftobedpe -i CESC-TCGA-EX-A1H5-01.sv.filtered.vcf -o CESC-TCGA-EX-A1H5-01.sv.filtered.2.bedpe

##convert to bed12 for IGV visualization
svtools bedpetobed12 -b CESC-TCGA-EX-A1H5-01.sv.filtered.2.bedpe -n CESC-TCGA-EX-A1H5-01 -d 100000 > CESC-TCGA-EX-A1H5-01.bed 
```
