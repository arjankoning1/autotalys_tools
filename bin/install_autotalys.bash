#!/usr/bin/env bash

# October 6, 2026
# Arjan Koning

set -euo pipefail

autotalys="$(pwd)"
bin="$autotalys/bin"
mkdir -p bin
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

ln -sfn ~/libraries .

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

# FUDGE is optional because it has too many dependencies. 
# Use Python 3.11 without requiring pyenv.
# Keep set -euo pipefail for all other installations.
install_fudge() (
  local python_exe=""

  if [[ ! -d "$autotalys/fudge" ]]; then
    echo "WARNING: FUDGE source directory not found."
    return 1
  fi

  if command -v python3.11 >/dev/null 2>&1; then
    python_exe="$(command -v python3.11)"
  elif command -v pyenv >/dev/null 2>&1; then
    local pyenv_prefix
    if pyenv_prefix="$(pyenv prefix 3.11.15 2>/dev/null)" &&
       [[ -x "$pyenv_prefix/bin/python3.11" ]]; then
      python_exe="$pyenv_prefix/bin/python3.11"
    fi
  fi

  if [[ -z "$python_exe" ]]; then
    echo "WARNING: Python 3.11 is not available; FUDGE cannot be installed."
    return 1
  fi

  cd "$autotalys/fudge" || return 1
  echo "Using Python: $python_exe"
  "$python_exe" -m venv .venv || return 1
  .venv/bin/python -m pip install --upgrade pip setuptools wheel || return 1

  # Preserve the compiler PATH preference from the original script.
  PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
    .venv/bin/python -m pip install . || return 1
)

if install_fudge; then
  echo "FUDGE installation completed."
else
  echo "WARNING: FUDGE installation was skipped or failed."
  echo "WARNING: Continuing AUTOTALYS installation without FUDGE."
fi
echo

cd $autotalys 

