### collect all the VCF files for SNVs into a folder
We process the data using [speedseq](https://github.com/hall-lab/speedseq) by [flowr](https://github.com/sahilseth/flowr) pipeline.
thx @samir and @sahil

structural variant calls and SNV calls are in the same folder. put only SNV files together.

```bash
mkdir SNVs_final
find *speedseq  ! -name '*sv.vcf.gz' | grep "vcf.gz$" | parallel -j 6 ./change_name_gz.sh {}
```

`change_name_gz.sh`: 

```bash
#! /bin/bash
set -e
set -u
set -o pipefail

newname=$(echo $1 | sed -E 's/.+\/(.+-TCGA-[0-9A-Z]{2}-[0-9A-Z]{4}-[0-9]{2})-.+/\1/')

#echo $newname
cp $1 /rsrch1/genomic_med/mtang1/TCGA-WGS-SV/SVs_final1/${newname}.sv.vcf.gz
```
