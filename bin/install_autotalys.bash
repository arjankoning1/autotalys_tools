#!/usr/bin/env bash

# October 6, 2026
# Arjan Koning

set -euo pipefail

autotalys=`pwd`
mkdir -p bin
bin=$autotalys'/bin'
echo "autotalys directory: " $autotalys
echo "bin directory: " $bin
echo

#
# Installing my codes
#
for code in talys tefal tasman endftables autonorm autoendf autotalys_tools; do
  echo "***** Installing for autotalys: " $code
  cd $code
  if [ -e ./install_$code.bash ] ; then
    ./install_$code.bash
  fi
  cd bin
  for executable in *; do
    ln -sfn "../$code/bin/$executable" "$bin/$executable"
  done
  cd ../..
  echo
done

#
# Installing other codes
#
cd $autotalys 

echo "***** Installing for autotalys: BNL ENDF-utility-codes" 
cd ENDF-utility-codes
mkdir -p bin
for code in checkr fizcon psyche inter ; do
  cd $code
  sed 's/-std=legacy//g' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
  make clean
  make
  mv $code ../bin
  ln -sfn "../ENDF-utility-codes/bin/$code" "$bin/$code"
  cd ..
done
echo

cd $autotalys 

echo "***** Installing for autotalys: PREPRO" 
cd PREPRO/source

# Fix EVALPLOT's Legendre-array dimension.
sed '/^[[:space:]]*PARAMETER (MAXLEGE /s/120000/2400/' \
  EVALPLOT/evalplot.h > EVALPLOT/evalplot.h.tmp
mv EVALPLOT/evalplot.h.tmp EVALPLOT/evalplot.h

make clean
make
make install graphics=yes
make clean
cd ..
cd bin
for executable in *; do
  ln -sfn "../PREPRO/bin/$executable" "$bin/$executable"
done
cd ..
echo

cd $autotalys 

echo "***** Installing for autotalys: NJOY" 
cd NJOY2016
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../
make -j8
ln -sfn "../NJOY2016/build/njoy" "$bin/njoy"
cd ../..
echo

cd $autotalys 

echo "***** Installing for autotalys: FUDGE"
cd "$autotalys/fudge"

pyenv local 3.11.15

python3 -m venv .venv
source .venv/bin/activate

python3 -m pip install --upgrade pip setuptools wheel

PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
    python3 -m pip install .

cd ..
echo

cd $autotalys 

ln -s ~/libraries .
