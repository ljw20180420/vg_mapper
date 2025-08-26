#!/bin/bash
genome=`echo ${1##*/}`;
path=`pwd`;
awk -v vcf=$genome.$2.vcf -v chr=$2 -v cpath=$path -v ref=$genome.$2.T2C '
BEGIN{
	printf("##fileformat=VCFv4.1\n") > vcf;
	printf("##reference=%s/%s\n", cpath, ref) > vcf;
	printf("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n") > vcf;
}
{
	if (flag > 0 && NR > 1 && faNR > 0)
	{
		for (i=1; i<n; ++i)
		{
			pos += length(array[i]);
			printf("%s\t%d\t.\tC\tT\t.\t.\t.\n", chr, pos+1) > vcf;
			gsub("[Cc]", "T", array[i]);
			printf("%sCG", array[i]);
			pos += 2;
		}
		pos = pos + length(array[n]);
		if ($0 !~ /^[Gg]/ || array[n] !~ /[Cc]$/)
			gsub("[Cc]", "T", array[n]);
		else
		{
			printf("%s\t%d\t.\tC\tT\t.\t.\t.\n", chr, pos) > vcf;
			gsub("[Cc]", "T", array[n]);
			sub(/T$/, "C", array[n]);
		}
		printf("%s\n", array[i]);
	}
	if ($0 ~ />/)
	{
		if (chr == substr($1, 2))
			flag = 1;
		else
			flag = 0;
		if (flag > 0)
		{
			faNR = 0;
			pos = 0;
			print;
		}
	}
	else if (flag > 0)
	{
		faNR += 1;
		n = split($0, array, "CG");
	}
}
END{
	if (flag > 0)
	{
		for (i=1; i<n; ++i)
		{
			pos += length(array[i]);
			printf("%s\t%d\t.\tC\tT\t.\t.\t.\n", chr, pos+1) > vcf;
			gsub("[Cc]", "T", array[i]);
			printf("%sCG", array[i]);
			pos += 2;
		}
		gsub("[Cc]", "T", array[n]);
		printf("%s\n", array[i]);
	}
}
' $1 > $genome.$2.T2C

/home/ljw/new_fold/old_desktop/tools/artificial_vcf/vg autoindex --workflow giraffe -r $genome.$2.T2C -v $genome.$2.vcf -p $genome.$2

