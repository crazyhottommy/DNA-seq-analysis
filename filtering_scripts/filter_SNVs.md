### collect all the VCF files for SNVs into a folder
We process the data using [speedseq](https://github.com/hall-lab/speedseq) by [flowr](https://github.com/sahilseth/flowr) pipeline.
thx @samir and @sahil

structural variant calls and SNV calls are in the same folder. put only SNV files together.

```bash
mkdir SNVs_final
find *speedseq  ! -name '*sv.vcf.gz' | grep "vcf.gz$" | parallel cp {} SNVs_final/
```
