FROM ubuntu:latest
RUN apt update
RUN apt install build-essential
RUN apt install liblua5.3-dev libcurl4-gnutls-dev
RUN apt install libmodbus-dev lua-socket
RUN apt install git

WORKDIR /app
RUN git clone https://github.com/SoftwareAG/cumulocity-sdk-c.git
RUN cd cumulocity-sdk-c
RUN git submodule init
RUN git submodule update
COPY sdk.mk /app/cumulocity-sdk-c/init.mk
RUN cp Makefile.template Makefile
RUN make

RUN cd /app
RUN git clone  https://github.com/SoftwareAG/cumulocity-agents-linux.git


RUN export C8Y_LIB_PATH=/app/cumulocity-sdk-c
RUN cd cumulocity-agents-linux
RUN cp -rP $C8Y_LIB_PATH/lib $C8Y_LIB_PATH/bin .

COPY agent.mk /app/cumulocity-agents-linux/Makefile
RUN make install

COPY cumulocity-agent.conf /usr/share/cumulocity-agent/cumulocity-agent.conf

