# Introduction

The easiest way to do bisulfite mapping is [`bismark`](https://github.com/FelixKrueger/Bismark). This project is a wrapper of [`vg`](https://github.com/vgteam/vg) to apply bisulfite mapping instead of `bismark`. Compared with `bismark`, `vg` allows truely branching at `CpG` island. I suggest `bismark` to migrate from `bowtie2` and `hisat2` to `vg`.

In bisulfite, `C` other than `CpG` of genome becomes `T`. `C` in `CpG` either keep or become `T`. Thus, the ideal bisulfite mapper should map both `C` and `T` of forward reads to `C` in `CpG` of genome. `vg` achieve this by a graph genome.

`bismark` does four parallel alignments with combinations of `C->T` and `G->A` in reads and genomes, and select the best. This is different from the ideal strategy. For example, map `TGCGC` to `CGCGT` by `vg` has single error because `C` in read cannot map to `T` in genome. For `bismark`,
- If `C->T` is applied to both read and genome, then `bismark` mismatches `C` in read to `G` in genome.
- If `C->T` is applied only to genome, then `bismark` cannot match `C` in read to `C` in genome.
- If `C->T` is applied only to read, then `bismark` not only mismatches `C` in read to `G` in genome, but also cannot match `C` in read to `C` in genome.
- If `C->T` is neither applied to read nor to genome, then `bismark` cannot match `T` in read to `C` in genome.

# Download

- Install dependencies for `vg`.
    ```console
    $ sudo apt install jq rs
    ```
- Download vg executable from https://github.com/vgteam/vg/releases.
- Download seqkit executable from https://github.com/shenwei356/seqkit/releases.
- Install `samtools` and `bcftools`.

# Usage

See `run_chrom.sh`.

# TODO