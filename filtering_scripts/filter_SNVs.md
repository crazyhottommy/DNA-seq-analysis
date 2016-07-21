### collect all the VCF files for SNVs into a folder
We processed the data using [speedseq](https://github.com/hall-lab/speedseq) by [flowr](https://github.com/sahilseth/flowr) pipeline.
thx @Samir, @Floris and @Sahil

structural variant calls and SNV calls are in the same folder. put only SNV files together.

```bash
mkdir SNVs_final
find *speedseq*  ! -name '*sv.vcf.gz' | grep -v "sv.vcf" |  grep "vcf.gz$" | parallel -j 6 ./change_name_gz.sh {}
```

`change_name_gz.sh`: 

```bash
#! /bin/bash
set -e
set -u
set -o pipefail

newname=$(echo $1 | sed -E 's/.+\/(.+-TCGA-[0-9A-Z]{2}-[0-9A-Z]{4}-[0-9]{2})-.+/\1/')

#echo $newname
cp $1 /rsrch1/genomic_med/mtang1/TCGA-WGS-SV/SNVs_final/${newname}.vcf.gz
```

filter SNVs based on rules [here](https://github.com/crazyhottommy/DNA-seq-analysis/blob/master/speedseq_sv_filter.md#for-snvs): SSC >=40, alternative read in normal <=2.

```bash
find . -name "*vcf.gz" | parallel -k -j 5 ./filter_SNV.sh {}
```

#### put all the SV calls together

```bash
mkdir SVs_final
find *speedseq* -name '*sv.vcf.gz'| parallel -j 6 ./change_name_gz.sh {}
```
modify the `change_name_gz.sh` a bit, add `sv` suffix

```bash
#! /bin/bash
set -e
set -u
set -o pipefail

newname=$(echo $1 | sed -E 's/.+\/(.+-TCGA-[0-9A-Z]{2}-[0-9A-Z]{4}-[0-9]{2})-.+/\1/')

#echo $newname
cp $1 /rsrch1/genomic_med/mtang1/TCGA-WGS-SV/WGS/SVs_final/${newname}.sv.vcf.gz
```
** there are SV calls not genotyped and those are in unzipped form**

```bash
find *speedseq* -name '*sv.vcf'| parallel -j 6 ./change_name_vcf.sh {}
```
`change_name_vcf.sh`:

```bash
#! /bin/bash
set -e
set -u
set -o pipefail

newname=$(echo $1 | sed -E 's/.+\/(.+-TCGA-[0-9A-Z]{2}-[0-9A-Z]{4}-[0-9]{2})-.+/\1/')

#echo $newname
cp $1 /rsrch1/genomic_med/mtang1/TCGA-WGS-SV/WGS/SVs_final/vcfs_no_genotypes/${newname}.sv.vcf
```



### checking how many SNV vcf files and SV vcf files

comment out the `cp` and uncomment the `echo`

```bash
## for genotyped ones
find *speedseq -name "*sv.vcf.gz" | parallel ./change_name_gz.sh {} | sort | uniq | wc -l
944

## for not genotyped ones
find *speedseq -name "*sv.vcf" | parallel ./change_name_vcf.sh {} | sort | uniq | wc -l
27

find *speedseq*  ! -name '*sv.vcf.gz' | grep -v "sv.vcf" |  grep "vcf.gz$" | parallel -j 6 ./change_name_gz.sh {} | sort | uniq | wc -l
925

find . -type d  -name "*speedseq*" | parallel -k flowr status x={} 2> flowr_status_all.txt

```

Note:
UCEC-TCGA-BK-A139-01 has two SNV calls, 01A and 01C. but only one SV call in gz format and the other in unzip format.
one OV-TCGA-13-1411-01 SV call failed (no even ungenotyped vcf generated). Total 1046 samples processed.

Total 1037 samples processed.
