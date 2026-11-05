#!/usr/bin/env bash

# October 9, 2026
# Arjan Koning

set -euo pipefail

autotalys="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin="$autotalys/bin"
cd "$autotalys"
mkdir -p "$bin"
echo "autotalys directory: " $autotalys
echo "bin directory: " $bin
echo

#
# Installing my codes
#
for code in talys tefal tasman endftables autonorm autoendf autotalys_tools; do
  echo "***** Installing for autotalys: " $code
  cd $code

  if [ -e ./install_${code}.bash ]; then
    ./install_${code}.bash
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
cat > install_ENDF-utility-codes.bash << EOI
mkdir -p bin
for code in checkr fizcon psyche inter ; do
  cd "\$code"
  make clean
  make
  mv "\$code" ../bin
  ln -sfn "../ENDF-utility-codes/bin/\$code" "$bin/\$code"
  cd ..
done
EOI
chmod +x ./install_ENDF-utility-codes.bash
./install_ENDF-utility-codes.bash
echo

cd $autotalys 

echo "***** Installing for autotalys: PREPRO" 
cd PREPRO

# Fix EVALPLOT's Legendre-array dimension.
sed '/^[[:space:]]*PARAMETER (MAXLEGE /s/120000/2400/' \
  source/EVALPLOT/evalplot.h > source/EVALPLOT/evalplot.h.tmp
mv source/EVALPLOT/evalplot.h.tmp source/EVALPLOT/evalplot.h

cat > install_PREPRO.bash << EOI
cd source
make clean
make
make install graphics=yes
make clean
cd ..
cd bin
for executable in *; do
  ln -sfn "../PREPRO/bin/\$executable" "$bin/\$executable"
done
cd ..
EOI
chmod +x ./install_PREPRO.bash
./install_PREPRO.bash
echo

cd $autotalys 

echo "***** Installing for autotalys: NJOY" 
cd NJOY2016
cat > install_NJOY.bash << EOI
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../
make -j8
ln -sfn "../NJOY2016/build/njoy" "$bin/njoy"
cd ../..
EOI
chmod +x ./install_NJOY.bash
./install_NJOY.bash
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
  if [[ "$(uname -s)" == "Darwin" ]]; then
    # Use Apple's native compilers unless explicitly configured otherwise.
    export CC="${CC:-/usr/bin/clang}"
    export CXX="${CXX:-/usr/bin/clang++}"
    # Merced assigns CXX in its Makefile, so pass compiler overrides through
    # MAKEFLAGS to pip's make subprocess and its recursive builds.
    export MAKEFLAGS="${MAKEFLAGS:+$MAKEFLAGS }CC=$CC CXX=$CXX"
  fi
  .venv/bin/python -m pip install . || return 1

  echo "FUDGE installed successfully."
)

if install_fudge; then
  echo "FUDGE installation completed."
else
  echo "WARNING: FUDGE installation failed."
  echo "WARNING: Continuing without FUDGE."
fi

install_openmc() (
  local conda_exe="${OPENMC_CONDA:-}"
  local env_name="${OPENMC_ENV:-openmc}"
  local candidate=""

  if [[ -n "$conda_exe" ]]; then
    # An override may be an absolute path or a command on PATH.
    conda_exe="$(command -v "$conda_exe" || true)"
  else
    conda_exe="$(command -v conda || true)"
    if [[ -z "$conda_exe" && -n "${CONDA_EXE:-}" && -x "$CONDA_EXE" ]]; then
      conda_exe="$CONDA_EXE"
    fi
    if [[ -z "$conda_exe" ]]; then
      for candidate in "$HOME/miniforge3/bin/conda" \
                       "$HOME/miniconda3/bin/conda" \
                       "$HOME/anaconda3/bin/conda"; do
        if [[ -x "$candidate" ]]; then
          conda_exe="$candidate"
          break
        fi
      done
    fi
  fi

  if [[ -z "$conda_exe" || ! -x "$conda_exe" ]]; then
    echo "WARNING: Conda not found; install Miniforge or set OPENMC_CONDA."
    return 1
  fi

  echo "Using Conda: $conda_exe"
  echo "OpenMC environment: $env_name"

  if ! "$conda_exe" run -n "$env_name" python -c \
    'import openmc, matplotlib, numpy, shutil; assert shutil.which("openmc")' \
    >/dev/null 2>&1; then
    if "$conda_exe" env list | awk -v name="$env_name" '$1 == name { found = 1 } END { exit !found }'; then
      "$conda_exe" install -y -n "$env_name" -c conda-forge \
        openmc matplotlib numpy || return 1
    else
      "$conda_exe" create -y -n "$env_name" -c conda-forge \
        openmc matplotlib numpy || return 1
    fi
  fi

  if ! "$conda_exe" run -n "$env_name" python -c \
    'import openmc, matplotlib, numpy, shutil; assert shutil.which("openmc")' \
    >/dev/null 2>&1; then
    echo "WARNING: OpenMC verification failed in Conda environment $env_name."
    return 1
  fi

  # Record the selected conda environment for autoopenmc.
  # This file can be read by the autoopenmc wrapper.
  mkdir -p "$autotalys/config"

  printf 'OPENMC_CONDA=%q\nOPENMC_ENV=%q\n' \
    "$conda_exe" "$env_name" \
    > "$autotalys/config/openmc.conf"

  echo "OpenMC configuration written to config/openmc.conf"
)

if install_openmc; then
  echo "OpenMC installation/check completed."
else
  echo "WARNING: Continuing without OpenMC."
fi

echo

cd $autotalys 
