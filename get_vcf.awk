#!/usr/bin/env -S gawk -f

BEGIN{
    genome_out = ARGV[1]
    printf("##fileformat=VCFv4.1\n")
    printf("##reference=%s\n", genome_out)
    printf("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n")
}

{
	printf("%s\t%d\t.\tC\tT\t.\t.\t.\n", $1, $2+1)
}
