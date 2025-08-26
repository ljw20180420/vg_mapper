#!/bin/bash

# Usage
# ./run.sh \
#     genome_in \
#     genome_out \
#     vcf_file_out \
#     prefix_out \
#     R1_in \
#     R2_in \
#     bam_out

# Example
# ./run.sh \
#     ~/mm9_with_bowtie2_index/mm9.fa \
#     test_data/mm9.bisulfite.fa \
#     test_data/mm9.bisulfite.vcf \
#     test_data/mm9.bisulfite \
#     test_data/A3-NPC_L3_Q0013W0073.R1.fastq \
#     test_data/A3-NPC_L3_Q0013W0073.R2.fastq \
#     test_data/A3-NPC_L3_Q0013W0073.bam

# 切换运行路径到脚本路径
cd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

genome_in=$1
geome_out=$2
vcf_file_out=$3
prefix_out=$4
R1_in=$5
R2_in=$6
bam_out=$7

# Replace C other than CpG to T. Unfortunately, seqkit does not support lookahead (?=) and (?!). The workaround is first to replace CpG by #pG. Then replace C by T. Finally, replace # by C.
./seqkit replace \
    --by-seq --ignore-case \
    --pattern 'CG' \
    --replacement '#G' \
	< ${genome_in} |
./seqkit replace \
    --by-seq --ignore-case \
    --pattern 'C' \
    --replacement 'T' |
./seqkit replace \
    --by-seq --ignore-case \
    --pattern '#' \
    --replacement 'C' \
	> ${genome_out}

# Branch CpG to both CpG and TpG
# Since CpG does not overlap, --non-greedy can be used for speed up.
./seqkit locate \
    --ignore-case --only-positive-strand --non-greedy --bed \
    --pattern 'CG' \
	< ${genome_out} |
./get_vcf.awk -- ${genome_out} \
    > ${vcf_file_out}

# Index genome
./vg autoindex \
    --workflow giraffe \
    --ref-fasta ${genome_out} \
    --vcf ${vcf_file_out} \
    --prefix ${prefix_out}

# Map
./vg giraffe \
    --gbz-name ${prefix_out}.giraffe.gbz \
    --fastq-in ${R1_in} \
    --fastq-in ${R2_in} \
    --output-format BAM \
    > ${bam_out}
