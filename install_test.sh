#!/bin/bash

if [[ $# != 1 ]]
then
  echo "The installation version is required."
  exit 1
fi
version=$1
echo "Installing ${version}"

set -eux
cd ../build
sudo rm -fr /opt/ovsrpro/ovsrpro-${version}-gcc921-64-Linux/
sudo ./ovsrpro-*.sh --prefix=/opt/ovsrpro --include-subdir --skip-license
cd /opt/ovsrpro
sudo mv ovsrpro-*-dirtyrepo* ovsrpro-${version}-gcc921-64-Linux/
sudo mv ovsrpro-${version}-gcc921-64-Linux/ovsrpro_*.txt ovsrpro-${version}-gcc921-64-Linux/ovsrpro_${version}-gcc921-64.txt
sudo sed --in-place 's/^.*gcc921.*$/${version}-gcc921-64/' ovsrpro-${version}-gcc921-64-Linux/ovsrpro_${version}-gcc921-64.txt
sudo sed --in-place 's/19\.01\.1/20.05.1/' ovsrpro-${version}-gcc921-64-Linux/share/cmake/Findovsrpro.cmake
# cp ovsrpro-${version}-gcc921-64-Linux/share/cmake/Findovsrpro.cmake ~/repositories/mdp/mdp/
