FROM ubuntu:18.04
MAINTAINER Ian Rambo ian.rambo@utexas.edu
#Dockerfile for gene expression analysis using Bowtie, TopHat, and Cufflinks

USER root

RUN apt-get update && apt-get install -y apt-utils \
    default-jdk \
    zlib1g-dev \
    default-jre \
    software-properties-common \
    libbz2-dev \
    libncurses5-dev \
    libncursesw5-dev \
    liblzma-dev \
    sudo \
    make \
    wget \
    git \
    unzip \
    && apt-get-clean
#------------------------------------------------------------------------------
RUN mkdir /build
#RUN mkdir ~/bin
ENV PATH "$PATH:~/bin"

#Download and install Samtools
RUN cd /build \
    && wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 \
    && bzip2 -d samtools-1.9.tar.bz2 \
    && cd samtools-1.9 \
    && ./configure \
    && make \
    && make install
ENV PATH "$PATH:/build/samtools-1.9/bin"

#Download and install Bowtie
RUN cd /build \
    && wget https://github.com/BenLangmead/bowtie2/releases/download/v2.3.5.1/bowtie2-2.3.5.1-sra-linux-x86_64.zip \
    && unzip bowtie2-2.3.5.1-sra-linux-x86_64.zip \
    && rm bowtie2-2.3.5.1-sra-linux-x86_64.zip
    #&& cd /usr/local/bin \
    #&& ln -s /build/tophat-2.1.1.Linux_x86_64/bowtie2
ENV PATH "$PATH:/build/bowtie2-2.3.5.1-sra-linux-x86_64"

#Download TopHat binary
RUN cd /build \
    && wget http://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.1.Linux_x86_64.tar.gz \
    && tar -xzf tophat-2.1.1.Linux_x86_64.tar.gz \
    && rm tophat-2.1.1.Linux_x86_64.tar.gz
    #&& cd ~/bin \
    #&& ln -s /build/tophat-2.1.1.Linux_x86_64/tophat2
ENV PATH "$PATH:/build/tophat-2.1.1.Linux_x86_64"

#Download Cufflinks binaries
RUN cd /build \
    && wget http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz \
    && tar -zxf cufflinks-2.2.1.Linux_x86_64.tar.gz \
    && rm cufflinks-2.2.1.Linux_x86_64.tar.gz
ENV PATH "$PATH:/build/cufflinks-2.2.1.Linux_x86_64"
#------------------------------------------------------------------------------
#Build Boost, TopHat, and Cufflinks from source
#RUN cd /build \
#    && wget https://dl.bintray.com/boostorg/release/1.71.0/source/boost_1_71_0.tar.gz \
#    && tar -zxf boost_1_71_0.tar.gz \
#    && cd boost_1_71_0 \
#    && ./bootstrap.sh \
#    && ./bjam --prefix=/usr/local link=static runtime-link=static stage install \
#    && cd /build \
#    && git clone https://github.com/infphilo/tophat.git
