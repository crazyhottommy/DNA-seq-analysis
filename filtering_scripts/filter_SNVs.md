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
### filtering WGS SNV calls

Filtering SNVs takes long time, I used HPC to do it. For this simple one command task, I generated 1050 command files,
and then 1050 pbs files, and submit using a for loop. Sometimes, jobs fails, and it is a bit hard to follow which one failed.
That's why a pipeline is important when dealing with thousands of files. `snakemake` is a good potential candidates for this task.

```bash
find *gz | parallel 'echo ./filter_SNVs.sh {} > {}.command'

find *command | parallel './generate_pbs.sh -a {} -j {} -t 00:20:00 -m 4gb -c 4 -o a > {.}.pbs'

for pbs in *pbs
do
      msub $pbs
      sleep 5
done
```
`generate_pbs.sh`:

```bash
#!/bin/bash

# Wrapper to make MSUB job format on HPC running Moab/Torque job scheduler.
# @sbamin | nautilus
## getopts schema is modified from from script by @r_sabarinathan

set -e
set -u
set -o pipefail

# usage
show_help() {
cat << EOF

Wrapper to make BSUB job format on HPC running Moab/Torque job scheduler. 

Only required parameter is path to file containing commands to be run on cluster. 
This file will be copied verbatim following MSUB arguments.

Default MSUB options are: medium queue with 2 hours walltime, arpprox 16GB RAM and 4 CPU cores with present work directory as current work directory.

Usage: ${0##*/} -a <path to files containing commands> > <job.msub>"
    -h  display this help and exit
        -j  job name (default: j<random id>_username)
        -w  work directory (default: present work directory)
        -t  walltime in HH:MM:SS (default: 02:00:00)  
        -m  memory in gb (default: 16gb)
        -n  number of nodes (default: 1)
        -c  cpu cores per node (default: 4)
        -o email notifications (default: ae)
        -a  REQUIRED: path to file containing commands to be run on cluster. This file will be copied verbatim following MSUB arguments.
Example: ${0##*/} -j "sample_job" -w "/home/foo/myworkdir" -t 26:00:00 -m 64gb -n 1 -c 24 -o e -a "/home/foo/mycommands.txt" > /home/foo/sample.msub
Quotes are important for variable names containig spaces and special characters.
EOF
}
if [[ $# == 0 ]];then show_help;exit 1;fi
# read input
expression=0
while getopts "j:w:q:t:m:n:c:o:a:h" opt; do
    case "$opt" in
        h) show_help;exit 0;;
        j) JOBNAME=$OPTARG;;
        w) CWD=$OPTARG;;
        t) WALLTIME=$OPTARG;;
        m) MEMORY=$OPTARG;;
        n) NODES=$OPTARG;;
        c) CPU=$OPTARG;;
        o) EMAILOPTS=$OPTARG;; 
        a) MYARGS=$OPTARG;;
       '?')show_help >&2; exit 1 ;;
    esac
done
DJOBID=$(printf "j%s_%s" "$RANDOM" "$(whoami)")
JOBNAME=${JOBNAME:-$DJOBID}
CWD=${CWD:-$(pwd)}
STDOUT=$(printf "%s/log_%s.out" ${CWD} $JOBNAME)
STDERR=$(printf "%s/log_%s.err" ${CWD} $JOBNAME)
WALLTIME=${WALLTIME:-"02:00:00"}
MEMORY=${MEMORY:-"16gb"}
NODES=${NODES:-"1"}
CPU=${CPU:-"4"}
EMAILOPTS=${EMAILOPTS:-"ae"}
if [[ ! -s ${MYARGS} ]];then
    echo -e "\nERROR: Command file either does not exist at ${MYARGS} location or empty.\n"
    show_help
    exit 1
fi
##### Following lsf block will be parsed based on arguments supplied #####
cat <<EOF
#PBS -N ${JOBNAME}                                # name of the job
#PBS -d ${CWD}                                    # the workding dir for each job, this is <flow_run_path>/uniqueid/tmp
#PBS -o ${STDOUT}                                 # output is sent to logfile, stdout + stderr by default
#PBS -e ${STDERR}                                 # output is sent to logfile, stdout + stderr by default
#PBS -l walltime=${WALLTIME}                      # Walltime in minutes
#PBS -l mem=${MEMORY}                             # Memory requirements in Kbytes
#PBS -l nodes=${NODES}:ppn=${CPU}                 # CPU reserved
#PBS -M mtang1@mdanderson.org                           # for notifications
#PBS -m ${EMAILOPTS}                              # send email when job ends 
#PBS -V

## args come here
## --- DO NOT EDIT from below here---- ##
## following will always overwrite previous output file, if any.
set +o noclobber
$(printf "echo \"BEGIN at \$(date)\" >> %s" ${STDOUT})
## File containing commands will be copied here verbatim ##
###################### START USER SUPPLIED COMMANDS ######################
$(cat ${MYARGS})
###################### END USER SUPPLIED COMMANDS ######################
exitstat=\$?
$(printf "echo \"END at \$(date)\" >> %s" ${STDOUT})
$(printf "echo \"exit status was \${exitstat} >> %s\"" ${STDOUT})
$(printf "exit \${exitstat}")
## END ##
EOF
```
As mentioned, some of the jobs failed. 
check which one failed:
```bash
ls *filtered_SNV.vcf | sed 's/.filtered_SNV.vcf//' | sort | uniq > finished_samples.txt
ls *vcf.gz | sed 's/.vcf.gz//' | sort | uniq > total_samples.txt

##failed samples
comm -23 total_samples.txt finished_samples.txt
ESCA-TCGA-JY-A93C-01
GBM-TCGA-06-0145-01
GBM-TCGA-06-0152-01
GBM-TCGA-06-0185-01
GBM-TCGA-06-0648-01
KIRP-TCGA-IA-A40X-01
OV-TCGA-04-1371-01
OV-TCGA-13-0725-01
OV-TCGA-13-0751-01
OV-TCGA-25-1319-01
STAD-TCGA-D7-6518-01

```
re-generate pbs files for these 11 samples increasing walltime and memory for jobs.

```bash
##remove previous generated pbs file first

rm *pbs

comm -23 total_samples.txt finished_samples.txt | parallel find . -name {}.vcf.command | parallel './generate_pbs.sh -a {} -j {} -t 01:30:00 -m 16gb -c 6 -o a > {.}.pbs'

for pbs in *pbs
do
      msub $pbs
      sleep 2
done

```

### checking Low pass data

```bash
cat LPS_speedseq_index.csv | csvcut -c1 | sed '1d' | sort | uniq > all.samples.txt
find *speedseq*  -name "rln_cmd_1.sh" | sed -r 's/.+\/.+-(TCGA-[0-9A-Z]{2}-[0-9A-Z]{4}-[0-9]{2})-.+/\1/' | sort | uniq > run.txt
```
