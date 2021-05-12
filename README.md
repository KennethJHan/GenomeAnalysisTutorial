# Genome Analysis Tutorial

## 0. 소개
여러분 안녕하세요. 한주현 입니다.  
**바닥부터 Genome Analysis**에 오신것을 환영합니다.  
본 repository에는 강의에 필요한 파일들과 각종 커맨드 들을 소개하여 여러분들께서 직접 바닥부터 DNA Genome Analysis Variant Calling Pipeline을 만들어 볼 수 있는 tutorial을 제공합니다.  
특히 본 강의에서는 **BWA2**, **GATK4**와 같이 **최신의 툴**을 사용하여 pipeline을 만들어보는 강의를 진행합니다.  
다음 유튜브 링크에서 강의를 보면서 실습을 진행해보세요!
[바닥부터 Genome Analysis 강의 링크](#)

- 본 강의에서 배우고자 하는 내용
1. 리눅스 환경에서 DNA mutation (SNV, Indel)을 검출하는 파이프라인을 제작
1. 파이프라인을 구성하는 각 툴에서 들어가는 input과 output을 학습
1. 파이프라인을 구성하는 각 툴을 설치하는 방법을 학습
1. 파이프라인을 구성하는 각 툴들을 엮어서 파이프라인을 제작하는 방법을 학습


- 본 강의가 필요한 사람
    - DNA 유전체 분석의 파이프라인의 각 구성 요소를 배우고 싶은 사람
    - 바닥부터 툴을 하나씩 설치하며 유전체 분석 파이프라인을 만들어 보고 싶은 사람
    - 최신의 분석 툴인 BWA2, GATK4로 유전체 분석을 진행하고 싶은 사람

- 본 강의가 필요하지 않은 사람
    - 유전체 분석 전문가
    - 유전체 분석 파이프라인의 세부적인 알고리즘을 알고 싶은 사람


## 목차
```
0. 소개
1. 준비하기
  1.1 샘플 소개
  1.2 준비물
  1.3 파일 다운로드
  1.4 파일 준비
  1.5 툴 설치
      1.5.1 BWA2 설치
      1.5.2 Samtools 설치
      1.5.3 GATK4 설치
2. 전체 워크플로우
3. Reference에 서열 mapping
4. Duplication 리드 marking
5. Variant Calling
6. 마무리
```

## 1. 준비하기
### 1.1 샘플 소개
실습에 사용할 샘플은 public data인 NA12878 샘플입니다. 모든 염색체의 데이터를 사용하기에는 사용할 컴퓨터 자원이 많이 들고, 시간 또한 많이 들기에 금번 실습에서는 축소한 데이터를 사용하여 전체 파이프라인의 워크플로우를 익히는데 집중해보겠습니다. 데이터는 NA12878 chromosome 21번 데이터를 사용하겠습니다. 이에 맞춰 기준서열인 reference sequence 데이터도 chromosome 21번만 가지고 만든 데이터를 사용하겠습니다. 모든 자료는 github에서 받으신 자료의 data와 resource 디렉터리에 준비하였습니다.

### 1.2 준비물
본 강의를 진행하기 위한 준비물은 다음과 같습니다.  
1. 리눅스 커맨드를 진행할 수 있는 컴퓨터 (다음 중 하나면 됩니다)
    1. Ubuntu 또는 CentOS 등
    2. 맥
    3. 윈도우 WSL
2. 사양
- CPU: 1 thread 이상
- RAM: 4GB 이상
- HDD: 1GB 여유 공간

### 1.3 파일 다운로드
```bash
git clone https://github.com/KennethJHan/GenomeAnalysisTutorial.git
```

### 1.4 파일 준비
github에서 받은 파일 중 ```hg38.chr21.fa.bwt.2bit.64``` 파일의 크기가 github에 올리기에 커서 github repository에는 gzip으로 압축된 상태의 파일이 올라가 있습니다. 우리가 실습에 사용하기 위해 이 파일의 압축을 풀어야 합니다.  
파일은 ```resource/reference``` 에 위치해있습니다.  
다음 커맨드를 사용하여 압축을 풀어봅시다.

```bash
cd resource/reference
```
```
gunzip hg38.chr21.fa.bwt.2bit.64.gz
```

### 1.5 툴 설치
#### 1.5.1 BWA2 설치
"설치 방법 1" 과 "설치 방법 2"가 있습니다. 우선 "설치 방법 1"로 진행해보시고 실행이 되지 않는다면 "설치 방법 2"로 진행해주세요.
- 설치 방법 1 & 설치 확인
다음 커맨드를 실행해줍니다.
```
curl -L https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.0pre2/bwa-mem2-2.0pre2_x64-linux.tar.bz2  | tar jxf -
```
```
cd bwa-mem2-2.0pre2_x64-linux
```
```
./bwa-mem2
```
```
Usage: bwa-mem2 <command> <arguments>
Commands:
  index         create index
  mem           alignment
  version       print version number
```

혹시 bwa-mem2 를 실행하였는데 다음과 같은 오류가 나온다면 "설치 방법 2" 로 진행해주세요.
```bash
./bwa-mem2 
```
```
Please verify that both the operating system and the processor support Intel(R) X87, CMOV, MMX, FXSAVE, SSE, SSE2, SSE3, SSSE3, SSE4_1, SSE4_2, MOVBE, POPCNT, F16C, AVX, FMA, BMI, LZCNT and AVX2 instructions.
```

- 설치 방법 2 & 설치 확인
```bash
git clone --recursive https://github.com/bwa-mem2/bwa-mem2
```
```
cd bwa-mem2
```
```
make
```
```
./bwa-mem2
```

#### 1.5.2 Samtools 설치
- 설치 방법
다음 유튜브 링크를 참조하시면 수월하게 설치를 하실 수 있습니다.
https://www.youtube.com/watch?v=8bau7KESJTo

유튜브 링크에서는 samtools-1.10 버전으로 진행하는데,
2021년 5월 기준 samtools-1.12가 최신 버전입니다.
설치 방법에는 차이가 없으므로 유튜브 링크대로 진행하시면 됩니다!

- 설치 확인
samtools를 실행시켰을 때 다음과 같이 나오면 정상적으로 설치 된 것입니다.
```bash
samtools
```
```
Program: samtools (Tools for alignments in the SAM format)
Version: 1.12 (using htslib 1.12)

Usage:   samtools <command> [options]

Commands:
  -- Indexing
```

#### 1.5.3 GATK4 설치
- 설치 방법
GATK4의 경우 그냥 다운 받아 압축을 해제하면 됩니다.
```bash
wget https://github.com/broadinstitute/gatk/releases/download/4.2.0.0/gatk-4.2.0.0.zip
```
```
unzip gatk-4.2.0.0.zip
```
- 설치 확인
압축을 푼 디렉터리 내부에서 다음과 같이 실행시켰을 때,
```bash
java -jar gatk-package-4.2.0.0-local.jar
```
```
USAGE:  <program name> [-h]

Available Programs:
--------------------------------------------------------------------------------------
Base Calling:                                    Tools that process sequencing machine data, e.g. Illumina base calls, and detect sequencing level attributes, e.g. adapters
    CheckIlluminaDirectory (Picard)              Asserts the validity for specified Illumina basecalling data.  
    CollectIlluminaBasecallingMetrics (Picard)   Collects Illumina Basecalling metrics for a sequencing run. 
...
```
과 같이 나오면 정상적으로 설치 된 것입니다.

## 2. 전체 워크플로우
샘플에서 DNA를 추출하고 DNA를 무작위로 자른 후 sequencer가 읽을 수 있도록 library를 제작합니다. 이후 이를 sequencer에 넣고 DNA 서열을 읽어서 A, C, G, T의 서열이 나오게 됩니다. Sequencer가 library를 한 번 읽는 단위를 리드(read)라고 합니다. 한 샘플을 Sequencer에서 서열을 읽게 되면 수백만개의 리드가 나오게 되는데 이렇게 리드로 구성된 파일을 FASTQ 파일이라고 합니다.  
FASTQ는 네 줄이 하나의 리드로 구성됩니다. 첫 번째 줄은 헤더, 두 번째 줄은 서열, 세 번째 줄은 구분자, 네 번째 줄은 각 서열에 대한 퀄리티 줄입니다.  
이렇게 나온 FASTQ 파일을 reference sequence, 즉 기준이 되는 서열에 mapping을 합니다. 이렇게 mapping이 된 파일을 BAM 파일이라고 합니다.  
BAM 파일에서 기준 서열과 다른 서열을 찾아낼 수 있는데, 이를 변이를 찾아내는 과정, 즉 variant calling 이라고 합니다.  

다시 정리해서 말하자면 샘플 -> sequencer -> FASTQ -> (reference sequence에 mapping) -> BAM -> (variant calling) -> VCF

## 3. Reference 서열에 mapping
샘플을 Sequencer로 읽게 되면 수백만개의 리드들이 나오게 되는데, 이를 저장한 파일 포맷을 FASTQ 라고 합니다. FASTQ 파일을 살펴보겠습니다. data 디렉터리에 들어가서 fastq.gz 파일을 열어서 보겠습니다.

```bash
cd data
```
```
zless -S sample_1.fastq.gz
```

우리가 샘플로 사용하게 될 fastq 파일은 NA12878 이라고 불리는 public data에서 21번 염색체의 데이터만 있는 fastq 파일입니다.  
fastq 파일에 들어있는 전체 리드의 개수는 몇 개 일까요?  
fastq 파일의 전체 라인의 개수에 4를 나누게 되면 리드의 개수가 됩니다.
```bash
zcat sample_1.fastq.gz | wc -l
```
```
328476
```
```
zcat sample_2.fastq.gz | wc -l
```
```
328476
```

328476 / 4 = 82119
총 82,119개의 리드가 fastq 파일에 들어있습니다.  

이제 BWA2 툴을 사용하여 기준서열에 리드들을 mapping 해보겠습니다. 다음 커맨드를 실행해주세요.

```bash
$BWA2 mem -t 1 -R "@RG\tID:sample\tSM:sample\tPL:platform" ../resource/reference/hg38.chr21.fa sample_1.fastq.gz sample_2.fastq.gz > sample.mapped.sam
```

기본적으로 BWA2 mem 커맨드를 사용하여 나오게되는 파일은 sam 파일입니다. 실제 연구 또는 업무에서는 sam 파일은 크기가 너무 크므로 이를 binary 형태로 압축한 bam 파일을 많이 사용합니다.  
다음 커맨드를 사용하여 sam 파일을 bam 파일로 변환해 봅시다.

```bash
$SAMTOOLS view -Sb sample.mapped.sam > sample.mapped.bam
```

축하드립니다. 여러분들은 sequencer에서 나온 리드들을 기준서열에 mapping 하였습니다. 우리가 mapping한 리드를 눈으로 살펴 보겠습니다
```bash
$SAMTOOLS view -h sample.markdup.bam | less -S
```
@ 기호로 시작하는 헤더가 있고 그 아래부분들은 각각의 리드입니다.

## 4. Duplication 리드 marking
이번에는 리드에서 duplication, 즉 중복이 있는 리드를 표기하는 방법에 대해 알아보겠습니다.  
여기서 중복이라고 말하는 것은 무엇일까요? Sequencing을 진행하게 되면 필연적으로 PCR (Polymerase Chain Reaction) 과정에 의해 중복 리드가 발생하게 되는데요, 이러한 중복 리드들은 variant calling 과정에서 영향을 주게 됩니다. 그래서 duplication을 마킹하여 variant calling 때 영향을 주지 않도록 만들어야 하는데요, Picard와 같은 툴들이 있습니다만 우리는 samtools markdup 으로 진행해보겠습니다. 다음 커맨드들을 하나씩 실행해보겠습니다.
```bash
$SAMTOOLS sort -n -o sample.namesorted.bam sample.mapped.bam
```

```bash
$SAMTOOLS fixmate -m sample.namesorted.bam sample.fixmate.bam
```

```bash
$SAMTOOLS sort -o sample.fixmate.sorted.bam sample.fixmate.bam
```

```bash
$SAMTOOLS markdup sample.fixmate.sorted.bam sample.markdup.bam
```

```bash
$SAMTOOLS index sample.markdup.bam
```

축하드립니다. 우리는 samtools를 사용하여 duplication read들을 marking 하였습니다.  
BAM 파일에서는 flag라고 하는 정보로 각 리드의 특성을 나타내는데요 다음 사이트에서 각 flag에 해당하는 특성을 확인해 볼 수 있습니다.
https://broadinstitute.github.io/picard/explain-flags.html

지금 과정에서 우리가 진행한 것은 duplication에 대한 것인데 이는 1024의 번호를 가지고 이는 사이트에서 read is PCR or optical duplicate로 나타납니다.

우리가 만든 markdup bam에서 duplication으로 마킹된 bam만 꺼내본다면 samtools에서 다음 커맨드를 사용하여 볼 수 있습니다.

```bash
$SAMTOOLS view -f 1024 sample.markdup.bam
```
가장 먼저 나오는 리드의 flag가 1153인데 이를 explain-flags 사이트에 1153을 넣어보면, read is PCR or optical duplicate가 체크됨을 확인할 수 있습니다.  

여기서 리드들을 눈으로 볼 수 있는 또 다른 팁!  
```bash
$SAMTOOLS tview sample.markdup.bam
```

나오는 화면에서 / 키를 누르면 검색창이 나오는데 다음 포지션을 입력해줍니다. ```chr21:5012650```
여기서 각 한 줄, 한 줄이 각 리드입니다.

## 5. Variant calling
마지막으로 변이를 찾는 과정인 variant call 과정을 진행해보겠습니다. 다음 커맨드들을 실행해보겠습니다.
```bash
java -jar $GATK4 BaseRecalibrator -I sample.markdup.bam -R ../resource/reference/hg38.chr21.fa --known-sites ../resource/knownsites/hg38_v0_Homo_sapiens_assembly38.known_indels.chr21.vcf.gz -L chr21 -O sample.recal_data.table
```

```bash
java -jar $GATK4 ApplyBQSR -R ../resource/reference/hg38.chr21.fa -I sample.markdup.bam --bqsr-recal-file sample.recal_data.table -L chr21 -O sample.recal.bam
```

```bash
java -jar $GATK4 HaplotypeCaller -R ../resource/reference/hg38.chr21.fa -I sample.recal.bam -L chr21 -O sample.g.vcf -ERC GVCF
```

```bash
java -jar $GATK4 GenotypeGVCFs -R ../resource/reference/hg38.chr21.fa -V sample.g.vcf -L chr21 -O sample.vcf
```

축하드립니다! 여러분들은 FASTQ 파일에서 최종 변이 파일인 vcf 파일을 얻었습니다. 이 파일에서 어떠한 변이들이 있는지 살펴보겠습니다.

```bash
less -S sample.vcf
```
VCF 파일은 샵 문자(#)로 시작하는 헤더 줄과 각 변이의 위치와 정보가 담긴 데이터 줄로 구성되어있습니다.
조금더 자세히 살펴보면 첫 번째 열은 염색체 번호를 나타내는 CHROM, 두 번째 열은 위치를 나타내는 POS, 네 번째 열은 기준서열을 나타내는 REF, 다섯 번째 열은 변이의 정보인 ALT가 있습니다.

예를 들어 CHROM, POS, REF, ALT 기준으로 보았을 때, chr21 8550711 G C 의 경우, 21번 염색체 8550711 위치에서 기준 서열 G가 C로 바뀐 SNV(Single Nucleotide Variant) 었다는 것을 의미합니다. 또 다른 예로 chr21 13628293 ATGT A 의 경우, 21번 염색체 13628293 위치에서 기준서열 ATGT가 A로 바뀌었음을 나타내는데 이는 REF보다 ALT의 서열이 줄어들게 된 DELETION이라고 말할 수 있습니다. 마지막 예로는 chr21 13629790 T TGC 의 경우, 21번 염색체 13629790 위치에서 T가 TGC로 바뀌었음을 나타내고 이는 REF보다 ALT의 서열이 늘어나게 된 INSERTION을 말합니다.

## 6. 마무리 & 앞으로의 여정
여러분 정말로 고생 많으셨습니다. FASTQ 파일부터 툴을 필요한 툴을 설치해가며 변이가 정리된 VCF 파일까지 여러분들의 손으로 직접 만들어 보았습니다. 이로써 여러분들은 germline에서 나타난 SNV, InDel (Insertion, Deletion) 들을 찾아낼 수 있게 되었습니다. 사실 여기서 부터가 시작점입니다. 여러분들의 앞으로의 여정은 이 변이들이 어떠한 의미를 가지고 있는지 데이터베이스에서 정보를 붙여보는 annotation 과정, 생물학적으로 어떠한 의미를 가지고 있는지 해석하는 과정들이 남아있습니다. 여기까지 학습을 진행하신 여러분들은 실력과 끈기가 충분히 갖춰졌다고 생각합니다. 이제 앞으로 맞이하게 될 실제 세상에서 생물학적 문제들을 해결하시는데 본 강의가 많은 도움 되셨으면 좋겠습니다.

궁금한 점이 있으시다면 언제든 kenneth.jh.han@snu.ac.kr 로 문의 메일 주세요.
