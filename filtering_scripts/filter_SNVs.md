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

## for genotyped ones
find *speedseq -name "*sv.vcf" | parallel ./change_name_vcf.sh {} | sort | uniq | wc -l


## for SNVs
find *speedseq*  ! -name '*sv.vcf.gz' | grep -v "sv.vcf" |  grep "vcf.gz$" | parallel -j 6 ./change_name_gz.sh {} | sort | uniq | wc -l

find . -type d  -name "*speedseq*" | parallel -k flowr status x={} 2> flowr_status_all.txt

```

Note:
UCEC-TCGA-BK-A139-01 has two SNV calls, 01A and 01C. butone SV call in gz format and the other in unzip format.
one OV-TCGA-13-1411-01 SV call failed (no even ungenotyped vcf generated). Total 1047 samples processed.

11 samples processed twice:
```bash
find *speedseq*  -name "rln_cmd_1.sh" | sed -r 's/.+\/.+-(TCGA-[0-9A-Z]{2}-[0-9A-Z]{4}-[0-9]{2})-.+/\1/' | sort | uniq -c | sort -k2,2 -nr | head -20

2 TCGA-TM-A7CF-01
      2 TCGA-HT-A61B-01
      2 TCGA-FD-A3N5-01
      2 TCGA-DK-A1AG-01
      2 TCGA-DK-A1A7-01
      2 TCGA-DK-A1A6-01
      2 TCGA-DK-A1A5-01
      2 TCGA-CF-A27C-01
      2 TCGA-BL-A13J-01
      2 TCGA-BK-A139-01
      2 TCGA-44-2666-01
      1 TCGA-X2-A95T-01
      1 TCGA-WP-A9GB-01
      1 TCGA-V5-A7RC-06
      1 TCGA-V5-A7RC-01
      1 TCGA-TQ-A8XE-02
      1 TCGA-TQ-A8XE-01
      1 TCGA-TQ-A7RV-02
      1 TCGA-TQ-A7RV-01
      1 TCGA-TQ-A7RK-02

```
