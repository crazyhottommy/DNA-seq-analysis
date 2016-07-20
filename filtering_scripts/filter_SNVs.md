### collect all the VCF files for SNVs into a folder
We processed the data using [speedseq](https://github.com/hall-lab/speedseq) by [flowr](https://github.com/sahilseth/flowr) pipeline.
thx @Samir, @Floris and @Sahil

structural variant calls and SNV calls are in the same folder. put only SNV files together.

```bash
mkdir SNVs_final
find *speedseq  ! -name '*sv.vcf.gz' | grep -v "sv.vcf" |  grep "vcf.gz$" | parallel -j 6 ./change_name_gz.sh {}
```

`change_name_gz.sh`: 

```bash
#! /bin/bash
set -e
set -u
set -o pipefail

newname=$(echo $1 | sed -E 's/.+\/(.+-TCGA-[0-9A-Z]{2}-[0-9A-Z]{4}-[0-9]{2})-.+/\1/')

#echo $newname
cp $1 /rsrch1/genomic_med/mtang1/TCGA-WGS-SV/SVs_final1/${newname}.vcf.gz
```

filter SNVs based on rules [here](https://github.com/crazyhottommy/DNA-seq-analysis/blob/master/speedseq_sv_filter.md#for-snvs): SSC >=40, alternative read in normal <=2.

```bash
find . -name "*vcf.gz" | parallel -k -j 5 ./filter_SNV.sh {}
```

### checking how many SNV vcf files and SV vcf files

```bash
## for genotyped ones
find *speedseq -name "*sv.vcf.gz" | parallel ./change_name_gz.sh {} | sort | uniq | wc -l
944

## for not genotyped ones
find *speedseq -name "*sv.vcf" | parallel ./change_name_vcf.sh {} | sort | uniq | wc -l
27

find *speedseq  ! -name '*sv.vcf.gz' | grep -v "sv.vcf" |  grep "vcf.gz$" | parallel -j 6 ./change_name_gz.sh {} | sort | uniq | wc -l
925

find . -type d  -name "*speedseq*" | parallel -k flowr status x={} 2> flowr_status_all.txt

```
