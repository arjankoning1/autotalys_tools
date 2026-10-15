#!/usr/bin/env bash
#
# Install AUTOTALYS_TOOLS from its standalone source files.
# The utilities obtain external data paths at runtime through environment
# variables (TALYS_DIR, EXFORTABLES_DIR, LIBRARIES_DIR,
# RESONANCETABLES_DIR, and, where supported, AUTOTALYS_HOME).
# No DATA_ROOT setting, source rewriting, or libraries/ download is needed
# to compile these utilities.
#
set -euo pipefail

# Find the package root, independently of the current working directory.
tools_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$tools_dir/source"
bin_dir="$tools_dir/bin"

FC="${FC:-gfortran}"
FFLAGS="${FFLAGS:--w -O3}"

for arg in "$@"; do
    case "$arg" in
        FC=*)     FC="${arg#*=}" ;;
        FFLAGS=*) FFLAGS="${arg#*=}" ;;
        -h|--help)
            cat <<'HELP'
Usage: ./install_autotalys_tools.bash [FC=compiler] [FFLAGS="flags"]

Examples:
  ./install_autotalys_tools.bash
  ./install_autotalys_tools.bash FC=gfortran FFLAGS="-O3 -ffp-contract=off"
  ./install_autotalys_tools.bash FC=ifx FFLAGS="-O3"

The source files are compiled directly. Data directories are selected at
runtime by each utility's environment variables, not at build time.
HELP
            exit 0
            ;;
        *) echo "ERROR: Unknown option: $arg" >&2; exit 2 ;;
    esac
done

if [[ ! -d "$source_dir" ]]; then
    echo "ERROR: Source directory not found: $source_dir" >&2
    exit 1
fi
if ! command -v "$FC" >/dev/null 2>&1; then
    echo "ERROR: Fortran compiler not found: $FC" >&2
    exit 1
fi

codes_f90=(ZAres driplist extrema globalCE interCE psycheCE naturaltables)
codes_f=(njoycovx)

# Check all inputs before starting the build.
for code in "${codes_f90[@]}"; do
    [[ -f "$source_dir/$code.f90" ]] || {
        echo "ERROR: Missing source: $source_dir/$code.f90" >&2
        exit 1
    }
done
for code in "${codes_f[@]}"; do
    [[ -f "$source_dir/$code.f" ]] || {
        echo "ERROR: Missing source: $source_dir/$code.f" >&2
        exit 1
    }
done

# Ordinary compiler flags are whitespace-separated, as in the old installer.
read -r -a flags <<< "$FFLAGS"

build_dir="$(mktemp -d "${TMPDIR:-/tmp}/autotalys_tools.XXXXXX")"
trap 'rm -rf "$build_dir"' EXIT

echo "Installing AUTOTALYS_TOOLS"
echo "  Source:   $source_dir"
echo "  Target:   $bin_dir"
echo "  Compiler: $FC"
echo "  Flags:    $FFLAGS"
echo

# Compile all programs first. Do not replace installed programs on a failed build.
for code in "${codes_f90[@]}"; do
    echo "Compiling $code.f90"
    "$FC" "${flags[@]}" "$source_dir/$code.f90" -o "$build_dir/$code"
done
for code in "${codes_f[@]}"; do
    echo "Compiling $code.f"
    "$FC" "${flags[@]}" "$source_dir/$code.f" -o "$build_dir/$code"
done

# Install only compiled programs. Keep the existing shell scripts in bin/.
mkdir -p "$bin_dir"
for code in "${codes_f90[@]}" "${codes_f[@]}"; do
    install -m 755 "$build_dir/$code" "$bin_dir/$code"
done

echo
echo "AUTOTALYS_TOOLS installation completed: ${#codes_f90[@]} Fortran 90 + ${#codes_f[@]} fixed-form programs."
