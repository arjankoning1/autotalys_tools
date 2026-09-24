# AUTOTALYS tools

AUTOTALYS tools is a collection of Fortran utilities for nuclear-data processing, nuclide selection and comparisons with experimental data. These programs support AUTOTALYS and ENDF processing workflows.

The utilities are:

| Program | Purpose |
| --- | --- |
| `ZAres` | Determine the residual nucleus corresponding to an MT number. |
| `driplist` | Generate a nuclide list from dripline to dripline. |
| `extrema` | Determine energy and cross-section ranges for plotting. |
| `globalCE` | Collect cross-section comparison statistics for a whole library. |
| `interCE` | Compare INTER cross-section results with experimental data. |
| `psycheCE` | Compare PSYCHE average resonance parameters with experimental data. |
| `naturaltables` | Reconstruct natural-element cross sections from isotopic libraries. |

## Installation

### Prerequisites

- Bash and standard Unix command-line utilities
- a Fortran compiler, such as GNU Fortran (`gfortran`)

The installer compiles each program directly; GNU make is not required.

### Installation instructions

From the `autotalys_tools/` directory, run:

```bash
./installation_tools.sh
```

The script can also be invoked by its full path from another directory. 
All seven executables are installed in `autotalys_tools/bin/` after compilation succeeds. Existing executables are replaced.

The default compiler is `gfortran`, with flags `-w -O3`. Compiler and compilation options can be supplied as arguments or 
environment variables:

```bash
./installation_tools.sh FC=gfortran FFLAGS="-O3 -ffp-contract=off"
./installation_tools.sh FC=ifx FFLAGS="-O3"
```

`FC` must name a single compiler executable; `FFLAGS` is a whitespace-separated list of options.

To run the utilities from anywhere, add their `bin` directory to `PATH`:

```bash
export PATH="/path/to/autotalys_tools/bin:$PATH"
```

Add this line to `~/.zshrc` or `~/.bashrc` to retain it in new shells.

### Data configuration

Some utilities require external data that are not included in this package. 
By default, the installer uses the parent directory of `autotalys_tools/` as the data root, with the following layout:

```text
data-root/
├── autotalys_tools/
├── talys/
│   └── structure/
│       ├── abundance/
│       └── levels/exp/
├── libraries/
└── resonancetables/
    ├── thermal/
    ├── resonance/
    └── macs/
```

To use another location:

```bash
./installation_tools.sh DATA_ROOT=/path/to/data-root
```

`driplist` uses TALYS abundance and experimental level files, and checks for experimental data under `libraries/n/`. 
`naturaltables` uses TALYS abundances and isotopic tables under `libraries/`. 
`interCE` and `psycheCE` use selected experimental tables under `resonancetables/`.

The installer configures these paths in temporary source copies, leaving `source/` unchanged. 
Paths are embedded in the executables: rerun the installer after moving the data. 
The data root must already exist, but the external datasets are only needed when running the corresponding programs. 
Keep the root path short (at most 70 characters) because the programs use fixed-length filename variables.

## Running the utilities

The programs read formatted input from standard input. For example:

```bash
interCE < inter.out > inter.CE
psycheCE < psyche.out > psyche.CE
globalCE < combined.CE
naturaltables < input
```

For `naturaltables`, an example input is:

```text
n
Mn
jendl4.0
```

This selects neutron-induced natural manganese tables from the corresponding isotopic library. 
The library data must be installed before running this example. 
Run processing commands in a working directory where generated files may be written.

The comments and input-reading statements in `source/*.f90` describe the individual input formats. 
These utilities do not share a command-line help interface.

## Installation check

Full validation of most utilities requires suitable nuclear-data inputs and external datasets. 
No sample suite is included in this directory.

## The AUTOTALYS tools package

- `README.md`: this README file
- `installation_tools.sh`: installation script
- `source/`: the seven Fortran source files
- `bin/`: compiled executables
- `autotalys_build`: legacy build script, which edits source paths and also copies executables to `$HOME/bin`

Use `installation_tools.sh` for the installation procedure described above.
