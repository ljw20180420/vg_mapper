#!/bin/bash

# Usage
# ./run_chrom.sh \
#     genome_in \
#     output_dir \
#     R1_in \
#     R2_in \
#     gam_out

# Example
# ./run_chrom.sh \
#     ~/mm9_with_bowtie2_index/mm9.fa \
#     ~/sdd1/vg/mm9/chrom \
#     test_data/A3-NPC_L3_Q0013W0073.R1.fastq \
#     test_data/A3-NPC_L3_Q0013W0073.R2.fastq \
#     test_data/A3-NPC_L3_Q0013W0073.gam

# 切换运行路径到脚本路径
cd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

genome_in=$1
output_dir=$2
R1_in=$3
R2_in=$4
gam_out=$5

# Get the genome name stem (filename without extention).
genome_stem=${genome_in##*/}
genome_stem=${genome_stem%.*}
# mkdir -p ${output_dir}
# # Replace C other than CpG to T. Unfortunately, seqkit does not support lookahead (?=) and (?!). The workaround is first to replace CpG by #pG. Then replace C by T. Finally, replace # by C.
# ./seqkit replace \
#     --by-seq --ignore-case \
#     --pattern 'CG' \
#     --replacement '#G' \
#     < ${genome_in} |
# ./seqkit replace \
#     --by-seq --ignore-case \
#     --pattern 'C' \
#     --replacement 'T' |
# ./seqkit replace \
#     --by-seq --ignore-case \
#     --pattern '#' \
#     --replacement 'C' \
#     > ${output_dir}/${genome_stem}.bisulfite.fa

# # Index bisulfite genome
# samtools faidx ${output_dir}/${genome_stem}.bisulfite.fa

# # Branch CpG to both CpG and TpG.
# # Since CpG does not overlap, --non-greedy can be used for speed up.
# ./seqkit locate \
#     --ignore-case --only-positive-strand --non-greedy --bed \
#     --pattern 'CG' \
#     < ${output_dir}/${genome_stem}.bisulfite.fa |
# ./get_vcf.awk -- ${output_dir}/${genome_stem}.bisulfite.fa |
# bcftools reheader --fai ${output_dir}/${genome_stem}.bisulfite.fa.fai |
# bcftools view --compression-level 1 \
#     > ${output_dir}/${genome_stem}.bisulfite.vcf.gz

# # Index vcf
# bcftools index --force --tbi ${output_dir}/${genome_stem}.bisulfite.vcf.gz

declare -a vg_graphs
while read line
do
    read chrom remain <<<${line}
    vg_graphs+=(${output_dir}/${genome_stem}.${chrom}.bisulfite.vg)

    # # Construct graph
    # systemd-run --scope --user \
    #     --property MemoryMax=50G \
    #     ./vg construct --progress --region-is-chrom \
    #         --region ${chrom} \
    #         --reference ${output_dir}/${genome_stem}.bisulfite.fa \
    #         --vcf ${output_dir}/${genome_stem}.bisulfite.vcf.gz \
    #         > ${output_dir}/${genome_stem}.${chrom}.bisulfite.vg
done < ${genome_in}.fai

# # Node ids
# systemd-run --scope --user \
#     --property MemoryMax=50G \
#     ./vg ids --join ${vg_graphs[@]}

# # XG building
# systemd-run --scope --user \
#     --property MemoryMax=50G \
#     ./vg index --progress \
#         --xg-name ${output_dir}/${genome_stem}.bisulfite.xg \
#         ${vg_graphs[@]}

# Prune vg graph
declare -a vg_pruned_graphs
for vg_graph in ${vg_graphs[@]}
do
    ./vg prune --progress \
        --restore-paths ${vg_graph} > ${vg_graph%.*}.pruned.vg
    vg_pruned_graphs+=(${vg_graph%.*}.pruned.vg)
done

# systemd-run --scope --user \
#     --property MemoryMax=50G \
#     ./vg index --progress \
#         --gcsa-out ${output_dir}/${genome_stem}.bisulfite.gcsa \
#         ${vg_pruned_graphs[@]}

# # Map
# ./vg map \
#     --xg-name ${output_dir}/${genome_stem}.bisulfite.xg \
#     --gcsa-name ${output_dir}/${genome_stem}.bisulfite.gcsa \
#     --fastq ${R1_in} \
#     --fastq ${R2_in} \
#     > ${gam_out}
