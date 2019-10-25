#NOTE: developer tested the commands by folloing actions:
#      docker pull ubuntu:latest
#      docker images
#      docker run --memory=2g -i -t ubuntu:latest /bin/bash
#      docker run --memory=2g -i -t id /bin/bash
#      docker-machine scp Dockerfile main:~/zoomx
#      docker build --memory=2g ~/zoomx
#      docker start --memory=2g 301176b69086
#      docker exec -it 301176b69086 /bin/bash
#NOTE: merging RUN as file become stable as every RUN creates a commit which has a limit

#### Following Replaced By from charade/xlibbox:basic
FROM ubuntu:xenial

MAINTAINER Charlie Xia <xia.stanford@gmail.com>

WORKDIR /opt/
RUN ulimit -s unlimited
RUN mkdir /opt/setup && mkdir /opt/bin

### install git and dev files ###
#NOTE: RUN echo "PATH=$PATH:$HOME/bin" >>/etc/enviroment #not working, why?
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
RUN gpg -a --export E084DAB9 >/opt/rstudio.key
RUN apt-key add /opt/rstudio.key
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >>/etc/apt/sources.list
RUN echo "PATH=$PATH:/opt/bin" >>/etc/enviroment
RUN apt-get update
RUN apt-get install -y build-essential software-properties-common
RUN apt-get install -y bzip2 libbz2-dev liblzma-dev openssl libssl-dev
RUN apt-get install -y zlib1g-dev libncurses5-dev wget git unzip libcurl4-openssl-dev libxml2-dev

### python, has to precede bedtools ###
RUN apt-get install -y python3 libpython3-dev python3-pip
RUN apt-get install -y python3-numpy python3-scipy
### install python packages ###
RUN pip3 install -U numpy scipy tables six pandas pysam pybedtools dendropy

### install bedtools ###
RUN cd /opt/setup && git clone https://github.com/arq5x/bedtools.git
RUN cd /opt/setup/bedtools && make && cp bin/* /opt/bin

### install samtools ###
RUN cd /opt/setup && git clone https://github.com/samtools/samtools.git
RUN cd /opt/setup && git clone https://github.com/samtools/htslib.git
RUN cd /opt/setup/samtools && make && cp samtools /opt/bin
#### Above Replaced By from charade/xlibbox:basic

# FROM charade/xlibbox:basic
# RUN apt-get update

### avoid RPC error with https ###
RUN git config --global http.sslVerify false
RUN git config --global http.postBuffer 1048576000

### install svengine ###
RUN cd /opt/setup && git lfs clone --verbose https://bitbucket.org/charade/svengine.git
RUN cd /opt/setup/svengine/test && ./clean.sh && ./test_dep.sh
RUN cd /opt/setup/svengine && python setup.py install

### run test scripts ###
RUN export "PATH=$PATH:/opt/bin" && cd /opt/setup/svengine/test && ./test_mf.sh
RUN export "PATH=$PATH:/opt/bin" && cd /opt/setup/svengine/test && ./test_tv.sh

ENV PATH="${PATH}:/opt/bin"

### git clone tests ###
#dockerize OK
#RUN cd $HOME/setup && git clone --verbose https://charade@bitbucket.org/charade/dockerize.git
#correlations OK
#RUN cd $HOME/setup && git clone --verbose https://github.com/chaelir/correlations.git
