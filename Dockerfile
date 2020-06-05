FROM alexandreoda/ufonet

LABEL authors https://www.automata.science
ARG target

RUN apt-get update && apt-get install tor privoxy -y

RUN echo -e '\033[36;1m ******* CONTAINER START COMMAND ******** \033[0m'
CMD sudo service tor start && \ 
    sudo service privoxy start && \ 
    ./ufonet --check-tor --proxy="http://127.0.0.1:8118" && \ 
    ./ufonet --download-zombies --force-yes &&  \ 
    ./ufonet -i '$target' --force-yes && \ 
    ./ufonet -x '$target' --force-yes && \ 
    ./ufonet --download-github --force-yes && \ 
    ./ufonet  --threads 20  -a '$target' --force-yes -r 10000 --loris 500 --db "search.php?q=" --nuke 10000 --tachyon 1000 
