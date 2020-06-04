FROM dockage/tor-privoxy

LABEL authors https://www.automata.science
ARG target
ENV USER ufonet
ENV HOME /home/${USER}
ENV APP https://github.com/epsylon/ufonet.git
ENV DEBIAN_FRONTEND noninteractive

RUN echo -e '\033[36;1m ******* INSTALL PACKAGES ******** \033[0m' && \
  apk update && apk add -y \
  sudo \
  git \
  supervisor \
  privoxy \
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

RUN echo -e '\033[36;1m ******* SETUP SUPERVISOR ******** \033[0m'
# Post configuration
ADD supervisord.conf /etc/supervisor/
ADD supervisor-privoxy.conf /etc/supervisor/conf.d/
ADD supervisor-tor.conf /etc/supervisor/conf.d/
ADD privoxy_config /etc/privoxy/config

RUN /usr/bin/supervisord

RUN echo -e '\033[36;1m ******* SELECT WORKING SPACE ******** \033[0m'
WORKDIR ${HOME}

RUN echo -e '\033[36;1m ******* INSTALL APP ******** \033[0m' && \
  git clone ${APP}

RUN echo -e '\033[36;1m ******* SELECT WORKING SPACE ******** \033[0m'
WORKDIR ${HOME}/ufonet/

RUN echo -e '\033[36;1m ******* CONTAINER START COMMAND ******** \033[0m'
CMD ./ufonet --check-tor --proxy="http://127.0.0.1:8118" && \ 
    ./ufonet --download-zombies --force-yes &&  \ 
    ./ufonet -i '$target' --force-yes && \ 
    ./ufonet -x '$target' --force-yes && \ 
    ./ufonet --download-github --force-yes && \ 
    ./ufonet  --threads 20  -a '$target' --force-yes -r 10000 --loris 500 --db "search.php?q=" --nuke 10000 --tachyon 1000 
