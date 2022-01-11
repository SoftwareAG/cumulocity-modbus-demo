from ubuntu:latest
RUN apt update
RUN apt install build-essential
RUN apt install liblua5.3-dev libcurl4-gnutls-dev
RUN apt install libmodbus-dev lua-socket
RUN apt install git

RUN git clone https://github.com/SoftwareAG/cumulocity-sdk-c.git
RUN cd cumulocity-sdk-c
RUN git submodule init
RUN git submodule update
RUN cp common.mk init.mk //change lua to 5.3
RUN cp Makefile.template Makefile

cd basic tedge_agent_0
RUN git clone  https://github.com/SoftwareAG/cumulocity-agents-linux.git


export C8Y_LIB_PATH=/cumulocity-sdk-c
cd cumulocity-agents-linux
cp -rP $C8Y_LIB_PATH/lib $C8Y_LIB_PATH/bin .

//change makefile to lua53
//Makefile Plugin Modbus=1

//configure agent file
make install