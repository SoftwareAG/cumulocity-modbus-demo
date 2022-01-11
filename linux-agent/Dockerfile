FROM ubuntu:latest
RUN apt update
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt install -y build-essential
RUN apt install -y liblua5.3-dev libcurl4-gnutls-dev
RUN apt install -y libmodbus-dev lua-socket
RUN apt install -y git
RUN apt update -y
RUN apt upgrade -y

WORKDIR /app
RUN git clone https://github.com/SoftwareAG/cumulocity-sdk-c.git
WORKDIR /app/cumulocity-sdk-c
RUN pwd
RUN git submodule init
RUN git submodule update
COPY sdk.mk /app/cumulocity-sdk-c/init.mk
RUN cp Makefile.template Makefile
RUN make release

WORKDIR /app
RUN git clone https://github.com/SoftwareAG/cumulocity-agents-linux.git


ENV C8Y_LIB_PATH=/app/cumulocity-sdk-c
WORKDIR /app/cumulocity-agents-linux
RUN cp -rP $C8Y_LIB_PATH/lib $C8Y_LIB_PATH/bin .

COPY agent.mk /app/cumulocity-agents-linux/Makefile
RUN make
RUN make release
RUN make install

COPY cumulocity-agent.conf /var/lib/cumulocity-agent/cumulocity-agent.conf
CMD ["cumulocity-agent"]