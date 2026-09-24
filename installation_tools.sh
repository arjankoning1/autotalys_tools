#!/usr/bin/env bash
# Build the AUTOTALYS utilities on Linux and macOS.
set -euo pipefail

tools_dir=$(cd "$(dirname "$0")" && pwd)
FC=${FC:-gfortran}
FFLAGS=${FFLAGS-"-w -O3"}
DATA_ROOT=${DATA_ROOT:-$(dirname "$tools_dir")}

usage() {
  echo 'Usage: installation_tools.sh [FC=compiler] [FFLAGS="flags"] [DATA_ROOT=/path/to/data]'
  echo 'DATA_ROOT contains talys/, libraries/ and resonancetables/.'
}
for arg in "$@"; do
  case "$arg" in
    FC=*) FC=${arg#*=} ;;
    FFLAGS=*) FFLAGS=${arg#*=} ;;
    DATA_ROOT=*) DATA_ROOT=${arg#*=} ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done
command -v "$FC" >/dev/null || { echo "Compiler not found: $FC" >&2; exit 1; }
[[ -d "$DATA_ROOT" ]] || { echo "Data root not found: $DATA_ROOT" >&2; exit 1; }
DATA_ROOT=$(cd "$DATA_ROOT" && pwd)
DATA_ROOT=${DATA_ROOT%/}/
# The programs store filenames in character(len=132) variables.
[[ ${#DATA_ROOT} -le 70 ]] || { echo 'DATA_ROOT is too long (maximum 70 characters).' >&2; exit 1; }
# Escape Fortran quotes, followed by sed replacement metacharacters.
escaped_root=$(printf '%s' "$DATA_ROOT" | sed "s/'/''/g; s/[\\&|]/\\\\&/g")
flags=()
if [[ -n "$FFLAGS" ]]; then read -r -a flags <<< "$FFLAGS"; fi
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/autotalys_tools.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT
codes=(ZAres driplist extrema globalCE interCE psycheCE naturaltables)
echo "Installing AUTOTALYS tools in $tools_dir/bin"
echo "Data root: $DATA_ROOT"
for code in "${codes[@]}"; do
  # Configure temporary source copies; preserve the distributed sources.
  sed -e "s|^  basedir = .*|  basedir = '${escaped_root}'|" \
      -e "s|^  valdir = .*|  valdir = '${escaped_root}resonancetables/'|" \
      -e "s|'../../talys/|'talys/|g" \
      -e "s|'../../libraries/|'libraries/|g" \
      "$tools_dir/source/$code.f90" > "$build_dir/$code.f90"
  "$FC" "${flags[@]}" "$build_dir/$code.f90" -o "$build_dir/$code"
  [[ -x "$build_dir/$code" ]] || { echo "Executable not created: $code" >&2; exit 1; }
  echo "$code compiled"
done
# Install only after every program has compiled successfully.
mkdir -p "$tools_dir/bin"
for code in "${codes[@]}"; do
  cp "$build_dir/$code" "$tools_dir/bin/$code"
done
printf '\nAdd this directory to PATH in ~/.zshrc or ~/.bashrc:\n\n'
printf '  export PATH="%s/bin:$PATH"\n' "$tools_dir"
