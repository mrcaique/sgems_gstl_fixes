#!/bin/bash

# Based on original script by:
#   The Inverse Modeling and Geostatistics Project
#   from University of Denmark (http://imgp.nbi.dk/)

# This script compiles SGeMS (Stanford Geostatistical Modeling Software)
# on Ubuntu 14.04 LTS (Trusty Tahr) Ubuntu 16.04 LTS (Xenial Xerus), 
# Debian 9 (Stretch) and Debian derivatives.
#
# For Ubuntu 14.04 LTS, use 'libcoin80' package instead of 'libcoin80v5'.
#
# This script was tested with following versions of GCC:
# 4.8.2 (in the Ubuntu 14.04 LTS);
# 4.8.4 (in the Ubuntu 14.04 LTS);
# 5.4.0 (in the Ubuntu 16.04 LTS).
#
# See "http://sgems.sourceforge.net/" for more information about SGeMS.

# Creates an isolated environment to compile the project
fixes='sgems_gstl_fixes'
source=$HOME/.sgems_source
mkdir ${source} && cd .. && cp -r ${fixes} ${source} && cd ${source}

# INSTALL DEPENDENCIES
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install libqt4-dev libsoqt4-dev libboost-dev\
    python2.7-dev libcoin80v5 build-essential subversion mercurial

### COMPILE AND INSTALL SIMVOLEON ###
# Download simvoleon
hg clone https://bitbucket.org/Coin3D/simvoleon
cd simvoleon 

# Compile simvoleon:
echo "Compiling SIMvoleon"
cd simvoleon
./configure --prefix=/usr

set -e

make
sudo make install
cd ..

set +e

##############################

#### SGEMS INSTALLATION  ######
sgemsdir='sgemsdir'

mkdir -p ${sgemsdir}
cd ${sgemsdir}

# DOWNLOAD AND FIX GsTL
tgzpack='GsTL-*.tgz'
gstl_version='GsTL-*'

echo "Downloading GsTL..."
curl -# -O -J -L https://sourceforge.net/projects/gstl/files/latest/download
tar -xvzf ${tgzpack}
echo "Removing tgz pack..."
rm ${tgzpack}
mv ${gstl_version} GsTL

#Remove the boost directory in the GsTL folder, and make a few adjustments:
echo "Removing GsTL/boost"
rm -fr GsTL/boost
sed -i 's/Common\/ExceptionStandard.h/GsTL\/utils\/Common\/ExceptionStandard.h/'\
    GsTL/GsTL/utils/Common/CommonDefs.h 
sed -i 's/Common\/CommonDefs.h/GsTL\/utils\/Common\/CommonDefs.h/'\
    GsTL/GsTL/utils/Common/CGLA.h

# DOWNLOAD AND COMPILE SGEMS
PY_VERSION=$(python -c 'from sys import version; print(version[0:3])')
INSTALL_DIR=$(pwd)
safe_INSTALL_DIR=$(printf "%s\n" "$INSTALL_DIR" | sed 's/[][\.*^$/]/\\&/g')
echo "Downloading SGeMS..."
svn co -q https://svn.code.sf.net/p/sgems/svn/trunk sgems

##### APPLYING FIXES IN THE SOURCE CODE
## Both SGeMS and GsTL are legacy projects, so their source codes does not
## compile successfully in the recent versions of GCC. In this section,
## some fixes for the specific files enable the compilation.
gstl_path='GsTL/GsTL'
sgems_path='sgems/GsTLAppli/geostat'

### Fixes for GsTL files
cp ../${fixes}/gstl_files/soft_indicator_cdf_estimator.h\
	${gstl_path}/cdf_estimator/soft_indicator_cdf_estimator.h

cp ../${fixes}/gstl_files/gstl_gauss_solver.h\
	${gstl_path}/matrix_library/gstl_tnt/gstl_gauss_solver.h

cp ../${fixes}/gstl_files/smartptr.cc ${gstl_path}/utils/smartptr.cc
cp ../${fixes}/gstl_files/build_cdf.h ${gstl_path}/univariate_stats/build_cdf.h

### Fixes for SGeMS files
cp ../${fixes}/sgems_files/kriging_mean.cpp ${sgems_path}/kriging_mean.cpp
cp ../${fixes}/sgems_files/utilities.h ${sgems_path}/utilities.h

rm -rvf ../${fixes}

cd sgems
## edit .qmake.cache
sed -i "s/GSTLHOME.*$/GSTLHOME = ${safe_INSTALL_DIR}\/GsTL/" .qmake.cache
sed -i "s/GSTLAPPLI_HOME.*$/GSTLAPPLI_HOME = ${safe_INSTALL_DIR}\/sgems/"\
    .qmake.cache
sed -i 's/INVENTOR_LIB.*$/INVENTOR_LIB = \/usr\/lib/' .qmake.cache
sed -i 's/INVENTOR_INCLUDE.*$/INVENTOR_INCLUDE = \/usr\/include/' .qmake.cache
sed -i 's/BOOST_INCLUDE.*$/BOOST_INCLUDE = \/usr\/include\/boost/' .qmake.cache
sed -i 's/PYTHON_LIB.*$/PYTHON_LIB = \/usr\/lib/' .qmake.cache
sed -i "s/PYTHON_INCLUDE.*$/PYTHON_INCLUDE = \/usr\/include\/python${PY_VERSION}/"\
    .qmake.cache
sed -i "s/PYTHON_SO.*$/PYTHON_SO = python${PY_VERSION}/" .qmake.cache

set -e
qmake -recursive
make
set +e

cd ..
######################

# UPDATE LDCONFIG
echo "$INSTALL_DIR/sgems/lib/linux" >> sgems.conf
echo "$INSTALL_DIR/sgems/plugins/designer" >> sgems.conf
sudo cp sgems.conf /etc/ld.so.conf.d/.
sudo ldconfig

# EXPORT GSTLAPPLIHOME
echo "######################################################"
SETCMD="export GSTLAPPLIHOME=$INSTALL_DIR/sgems";
touch env.sh
echo ${SETCMD} > env.sh
echo "SET THE GSTLAPPLIHOME VARIABLE AS : $SETCMD"
$SETCMD

# RUN SGEMS
CMD=$INSTALL_DIR/sgems/bin/linux/sgems 
echo "TYPE : $CMD, TO RUN SGeMS"
echo "######################################################"