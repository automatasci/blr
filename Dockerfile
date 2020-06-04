FROM debian:buster-slim

LABEL authors https://www.automata.science
ARG target
ENV USER ufonet
ENV HOME /home/${USER}
ENV APP https://github.com/epsylon/ufonet.git
ENV DEBIAN_FRONTEND noninteractive

RUN echo -e '\033[36;1m ******* INSTALL PACKAGES ******** \033[0m' && \
  apt-get update && apt-get install --no-install-recommends -y \
  sudo \
  git \
  tor \
  python \
  ca-certificates \
  python-pycurl \
  python-geoip \
  python-whois \
  python-crypto \
  python-requests \
  python-scapy \
  dnsutils && \
  rm -rf /var/lib/apt/lists/*
  
RUN echo -e '\033[36;1m ******* ADD USER ******** \033[0m' && \
  useradd -d ${HOME} -m ${USER} && \
  passwd -d ${USER} && \
  adduser ${USER} sudo

RUN echo -e '\033[36;1m ******* SELECT USER ******** \033[0m'
USER ${USER}

RUN echo -e '\033[36;1m ******* SELECT WORKING SPACE ******** \033[0m'
WORKDIR ${HOME}

RUN echo -e '\033[36;1m ******* INSTALL APP ******** \033[0m' && \
  git clone ${APP} && \
  sudo apt-get --purge autoremove -y git

RUN echo -e '\033[36;1m ******* SELECT WORKING SPACE ******** \033[0m'
WORKDIR ${HOME}/ufonet/

RUN echo -e '\033[36;1m ******* CONTAINER START COMMAND ******** \033[0m'
CMD sudo service tor start && sudo service privoxy start && \ 
    ./ufonet --check-tor --proxy="http://127.0.0.1:9050" && \ 
    ./ufonet --download-zombies --force-yes &&  \ 
    ./ufonet -i '$target' --force-yes && \ 
    ./ufonet -x '$target' --force-yes && \ 
    ./ufonet --download-github --force-yes && \ 
    ./ufonet  --threads 20  -a '$target' --force-yes -r 10000 --loris 500 --db "search.php?q=" --nuke 10000 --tachyon 1000 
