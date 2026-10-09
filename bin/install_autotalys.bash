#!/usr/bin/env bash

# October 9, 2026
# Arjan Koning

set -euo pipefail

autotalys="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

  installer="./install_${code}.bash"
  if [[ ! -f "$installer" ]]; then
    echo "ERROR: Missing installer: $code/$installer" >&2
    exit 1
  fi
  bash "$installer"

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

#
# Installing FUDGE
#
echo "***** Installing for autotalys: FUDGE"

install_fudge() (
  local python_exe=""
  local pyenv_prefix=""

  if [[ ! -d "$autotalys/fudge" ]]; then
    echo "WARNING: FUDGE source directory not found."
    return 1
  fi

  # Prefer Python 3.11.15 from pyenv, even if it is not the active version.
  # Resolve the real executable rather than accepting an inactive pyenv shim.
  if command -v pyenv >/dev/null 2>&1; then
    if pyenv_prefix="$(PYENV_VERSION=3.11.15 pyenv prefix 2>/dev/null)" &&
       [[ -x "$pyenv_prefix/bin/python3.11" ]]; then
      python_exe="$pyenv_prefix/bin/python3.11"
    fi
  fi

  # Otherwise use an available, working Python 3.11 interpreter.
  if [[ -z "$python_exe" ]]; then
    local candidate=""
    candidate="$(command -v python3.11 || true)"
    if [[ -n "$candidate" ]] &&
       "$candidate" --version >/dev/null 2>&1; then
      python_exe="$candidate"
    fi
  fi

  if [[ -z "$python_exe" ]]; then
    echo "WARNING: Python 3.11 is not available."
    return 1
  fi

  cd "$autotalys/fudge" || return 1

  echo "Using Python: $python_exe"
  "$python_exe" --version

  # Create an isolated Python environment.
  "$python_exe" -m venv .venv || return 1

  .venv/bin/python -m pip install \
    --upgrade pip setuptools wheel || return 1

  # Install FUDGE without overriding PATH.
  .venv/bin/python -m pip install . || return 1

  echo "FUDGE installed successfully."
)

if install_fudge; then
  echo "FUDGE installation completed."
else
  echo "WARNING: FUDGE installation failed."
  echo "WARNING: Continuing without FUDGE."
fi

echo

cd $autotalys 
