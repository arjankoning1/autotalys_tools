#!/usr/bin/env bash

set -euo pipefail

# Determine the AUTOTALYS_TOOLS installation directory independently
# of where the script is called from.

autotalys_tools_dir=$(cd "$(dirname "$0")" && pwd)
source_dir="$autotalys_tools_dir/source"
bin_dir="$autotalys_tools_dir/bin"

#
# Default compiler and compiler options.
#
FC=${FC:-gfortran}
FFLAGS=${FFLAGS:-"-w -O3"}

#
# By default, AUTOTALYS_TOOLS is assumed to reside inside the main
# autotalys directory:
#
#   autotalys/
#     talys/
#     resonancetables/
#     libraries/
#     autotalys_tools/
#
DATA_ROOT=${DATA_ROOT:-$(dirname "$autotalys_tools_dir")}


###############################################################################
# Command-line options
###############################################################################

for arg in "$@"; do
  case "$arg" in
    FC=*)
      FC=${arg#*=}
      ;;
    FFLAGS=*)
      FFLAGS=${arg#*=}
      ;;
    DATA_ROOT=*)
      DATA_ROOT=${arg#*=}
      ;;
    -h|--help)
      echo "Usage:"
      echo
      echo "  ./install_autotalys_tools.bash [FC=compiler] [FFLAGS=\"flags\"] [DATA_ROOT=directory]"
      echo
      echo "Examples:"
      echo
      echo "  ./install_autotalys_tools.bash"
      echo "  ./install_autotalys_tools.bash FC=gfortran FFLAGS=\"-w -O3 -ffp-contract=off\""
      echo "  ./install_autotalys_tools.bash DATA_ROOT=/path/to/autotalys"
      echo
      exit 0
      ;;
    *)
      echo "AUTOTALYS_TOOLS installation error: unknown argument:" >&2
      echo "  $arg" >&2
      exit 1
      ;;
  esac
done


###############################################################################
# Check installation
###############################################################################

if [[ ! -d "$source_dir" ]]; then
  echo "AUTOTALYS_TOOLS installation error: source directory not found:" >&2
  echo "  $source_dir" >&2
  exit 1
fi

if ! command -v "$FC" >/dev/null 2>&1; then
  echo "AUTOTALYS_TOOLS installation error: Fortran compiler not found:" >&2
  echo "  $FC" >&2
  exit 1
fi

if [[ ! -d "$DATA_ROOT" ]]; then
  echo "AUTOTALYS_TOOLS installation error: AUTOTALYS data directory not found:" >&2
  echo "  $DATA_ROOT" >&2
  exit 1
fi

DATA_ROOT=$(cd "$DATA_ROOT" && pwd)
DATA_ROOT="${DATA_ROOT%/}/"

#
# Some utilities use character(len=132) variables for filenames.
#
if [[ ${#DATA_ROOT} -gt 70 ]]; then
  echo "AUTOTALYS_TOOLS installation error:" >&2
  echo "DATA_ROOT is too long (maximum 70 characters):" >&2
  echo "  $DATA_ROOT" >&2
  exit 1
fi


###############################################################################
# Source files
###############################################################################

codes_f90=(
  ZAres
  driplist
  extrema
  globalCE
  interCE
  psycheCE
  naturaltables
)

codes_f=(
  njoycovx
)

#
# Check that all expected source files are present.
#
for code in "${codes_f90[@]}"; do
  if [[ ! -f "$source_dir/$code.f90" ]]; then
    echo "AUTOTALYS_TOOLS installation error: source file not found:" >&2
    echo "  $source_dir/$code.f90" >&2
    exit 1
  fi
done

for code in "${codes_f[@]}"; do
  if [[ ! -f "$source_dir/$code.f" ]]; then
    echo "AUTOTALYS_TOOLS installation error: source file not found:" >&2
    echo "  $source_dir/$code.f" >&2
    exit 1
  fi
done


###############################################################################
# Installation
###############################################################################

echo
echo "Installing AUTOTALYS_TOOLS"
echo "Installation directory: $autotalys_tools_dir"
echo "Data directory:         $DATA_ROOT"
echo "Fortran compiler:       $FC"
echo "Compiler options:       $FFLAGS"
echo

mkdir -p "$bin_dir"

#
# Convert FFLAGS into a Bash array, so quoted groups of compiler options
# are passed correctly to the compiler.
#
read -r -a flags <<< "$FFLAGS"

#
# Use a temporary build directory. This is important because some of the
# AUTOTALYS utility sources contain installation-dependent paths. The
# distributed source files themselves should not be modified.
#
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/autotalys_tools.XXXXXX")

trap 'rm -rf "$build_dir"' EXIT


###############################################################################
# Compile free-form Fortran 90 programs
###############################################################################

#
# Escape characters that have a special meaning in sed replacement text.
#
escaped_root=$(printf '%s' "$DATA_ROOT" |
  sed "s/'/''/g; s/[\\&|]/\\\\&/g")

for code in "${codes_f90[@]}"; do

  echo "Compiling $code"

  #
  # Make a temporary configured version of the source.
  #
  # These substitutions allow the utilities to find TALYS,
  # resonancetables and libraries when installed as part of AUTOTALYS.
  #
  sed \
    -e "s|^  basedir = .*|  basedir = '${escaped_root}'|" \
    -e "s|^  valdir = .*|  valdir = '${escaped_root}resonancetables/'|" \
    -e "s|'../../talys/|'talys/|g" \
    -e "s|'../../libraries/|'libraries/|g" \
    "$source_dir/$code.f90" \
    > "$build_dir/$code.f90"

  "$FC" \
    "${flags[@]}" \
    "$build_dir/$code.f90" \
    -o "$build_dir/$code"

  if [[ ! -x "$build_dir/$code" ]]; then
    echo "AUTOTALYS_TOOLS installation error: executable not created:" >&2
    echo "  $code" >&2
    exit 1
  fi

done


###############################################################################
# Compile fixed-form Fortran programs
###############################################################################

for code in "${codes_f[@]}"; do

  echo "Compiling $code"

  "$FC" \
    "${flags[@]}" \
    "$source_dir/$code.f" \
    -o "$build_dir/$code"

  if [[ ! -x "$build_dir/$code" ]]; then
    echo "AUTOTALYS_TOOLS installation error: executable not created:" >&2
    echo "  $code" >&2
    exit 1
  fi

done


###############################################################################
# Install executables
###############################################################################

#
# Only replace the executables compiled above. Other scripts already present
# in bin/, such as autotalys, plot, plotall and run-errorj, are left untouched.
#

for code in "${codes_f90[@]}" "${codes_f[@]}"; do
  cp "$build_dir/$code" "$bin_dir/$code"
done


###############################################################################
# Finished
###############################################################################

echo
echo "AUTOTALYS_TOOLS executables:"
echo
