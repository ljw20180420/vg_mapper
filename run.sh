#!/bin/bash

# Usage
# ./run.sh 

# 切换运行路径到脚本路径
cd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

bash /home/ljw/new_fold/old_desktop/tools/artificial_vcf/art_vcf.sh /home/ljw/mm9_with_bowtie2_index/mm9.fa chr18
/home/ljw/new_fold/old_desktop/tools/artificial_vcf/vg giraffe -Z mm9.fa.chr18.giraffe.gbz -f A3-NPC_L3_Q0013W0073.R1.fastq -f A3-NPC_L3_Q0013W0073.R2.fastq -o BAM > A3-NPC_L3_Q0013W0073.bam
