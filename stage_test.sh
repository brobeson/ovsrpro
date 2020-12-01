#!/bin/bash

sudo cp Findovsrpro.cmake /opt/ovsrpro/ovsrpro-20.04.1-gcc921-64-Linux/
cp Findovsrpro.cmake ~/repositories/mdp/mdp/

destination=/opt/ovsrpro/ovsrpro-20.04.1-gcc921-64-Linux/share/cmake/
sudo cp \
    cmake/Findcppzmq.cmake \
    cmake/FindHDF5.cmake \
    cmake/Findlibrdkafka.cmake \
    cmake/Findlibzmq.cmake \
    cmake/FindNOVAS.cmake \
    cmake/Findpsql.cmake \
    cmake/FindQwt.cmake \
    cmake/Findzookeeper.cmake \
    ${destination}