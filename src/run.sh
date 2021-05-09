#!/bin/bash

if [ $# -ne 3 ];then
  echo "#usage: sh $0 [sample] [fq1] [fq2]"
  exit
fi

SAMPLE=$1
FQ1=$2
FQ2=$3
BWA="/location/bwa-mem2"
SAMTOOLS="/location/samtools"
GATK="/location/gatk-package-4.2.0.0-local.jar"
JAVA="/location/java"
REFERENCE="/location/GenomeAnalysis/resource/reference/hg38.chr21.fa"
KNOWN_INDEL="/location/GenomeAnalysis/resource/knownsites/hg38_v0_Homo_sapiens_assembly38.known_indels.chr21.vcf.gz"
READGROUP="@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:platform"
THREAD=1

## ALIGN
echo "## START: ALIGN - `date`"
${BWA} mem -t ${THREAD} -R ${READGROUP} ${REFERENCE} ${FQ1} ${FQ2} > ${SAMPLE}.mapped.sam
${SAMTOOLS} view -Sb ${SAMPLE}.mapped.sam > ${SAMPLE}.mapped.bam
### sort by read name
${SAMTOOLS} sort -n -o ${SAMPLE}.namesorted.bam ${SAMPLE}.mapped.bam
echo "## END: ALIGN - `date`"

echo "## START: FIXMATE - `date`"
### fixmate
${SAMTOOLS} fixmate -m ${SAMPLE}.namesorted.bam ${SAMPLE}.fixmate.bam
${SAMTOOLS} sort -o ${SAMPLE}.fixmate.sorted.bam ${SAMPLE}.fixmate.bam
echo "## END: FIXMATE - `date`"

echo "## START: MARKDUP - `date`"
## MARKDUP
${SAMTOOLS} markdup ${SAMPLE}.fixmate.sorted.bam ${SAMPLE}.markdup.bam
${SAMTOOLS} index ${SAMPLE}.markdup.bam
echo "## END: MARKDUP - `date`"

echo "## START: VARIANT CALL - `date`"
## VARIANT CALL
### GATK BaseRecalibrator
${JAVA} -jar ${GATK} BaseRecalibrator -I ${SAMPLE}.markdup.bam -R ${REFERENCE} --known-sites ${KNOWN_INDEL} -L chr21 -O ${SAMPLE}.recal_data.table
${JAVA} -jar ${GATK} ApplyBQSR -R ${REFERENCE} -I ${SAMPLE}.markdup.bam --bqsr-recal-file ${SAMPLE}.recal_data.table -L chr21 -O ${SAMPLE}.recal.bam

### GATK HaplotypeCaller
${JAVA} -jar ${GATK} HaplotypeCaller -R ${REFERENCE} -I ${SAMPLE}.recal.bam -L chr21 -O ${SAMPLE}.g.vcf -ERC GVCF
${JAVA} -jar ${GATK} GenotypeGVCFs -R ${REFERENCE} -V ${SAMPLE}.g.vcf -L chr21 -O ${SAMPLE}.vcf

echo "## END: VARIANT CALL - `date`"

