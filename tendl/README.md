# Creating TENDL

Arjan Koning

This directory contains nuclide lists and scripts for generating AUTOTALYS
commands and collecting results. The scripts can be run from a production
directory; their input lists are located relative to the scripts themselves.

## Installation paths

`loopnuc`, `loopsearch`, and `autorochman` use `$HOME/autotalys` as the default installation
root. Set `AUTOTALYS_ROOT` if the T6 installation is elsewhere. They expect
programs in `$AUTOTALYS_ROOT/bin` and Tasman input files in
`$AUTOTALYS_ROOT/tasman/misc`. `loopnuc` uses `tasman.tendl2025` there.
The `tares`, `tafis`, and `tanes` modes of `loopnuc` use the `autorochman`
script in this directory. The `libraries` mode uses `libmaker` from the
installation's `bin` directory. TARES, TAFIS, TANES, and `libmaker` must be
installed separately.

## Nuclide lists

`loopnuc` currently uses `nuclides.sec` for projectile and resonance modes.
The `libraries` mode combines `nuclides.light`, `nuclides.year`,
`nuclides.nat`, and `nuclides.shortyear`. To use a different list in the other
modes, change the `nuclist` setting in `loopnuc`. It copies the selected list
to `nuclides` in the working directory before generating commands.

The supplied `nuclides.*` lists contain:

| List | Entries |
| --- | ---: |
| `nuclides.year` | 407 |
| `nuclides.day` | 675 |
| `nuclides.hour` | 995 |
| `nuclides.sec` | 2854 |
| `nuclides.milli` | 4030 |

All five lists include H1, H2, H3, He3, and He4; `nuclides.milli` also
includes He6 and He8.
Standard `loopnuc` projectile runs skip masses below 5. The `nuc.*` files
contain the corresponding compact names, such as `Al027`, for report checks.

A `nuclides.*` entry looks like `Al_027_000_0_1_100_050_E`. Its fields give
the element, mass, target level, target isomer, stability, abundance or
lifetime, number of random runs, and EXFOR indicator.

## Generate and run nuclide scripts

From a projectile production directory, for example `tendl/n`, run:

```sh
/path/to/autotalys_tools/tendl/loopnuc n > n.all
```

This writes one executable script per selected nuclide, such as `n-Al027`,
and lists their names in `n.all`. It does not run them. Other projectile
arguments are `g`, `p`, `d`, `t`, `h`, and `a`. The additional modes are
`tares`, `tafis`, `tanes`, and `libraries`.

`autorochman` can also be run directly from a working directory:

```sh
/path/to/autotalys_tools/tendl/autorochman -element Nb -mass 93 -tares
```

It creates a nuclide directory such as `Nb093/`, writes input and output
files there, and runs TARES by default. Use `-tafis` or `-tanes` for the
other codes. It looks for these executables in the selected installation
root's `bin` directory. For TAFIS and TANES, it also reads available best
library selections from `talys/structure/best/<nuclide>/` under that root.
The optional `-scratch` mode uses `/scratch/tendl`.

For a TALYS parameter search, `loopsearch` prints commands rather than
creating one script per nuclide:

```sh
/path/to/autotalys_tools/tendl/loopsearch p iaea > search.all
```

It reads `<projectile>.<type>` beside the script, where `<type>` is `exp` or
`iaea`, and copies that list to `nuclides` in the working directory. Only
`p.iaea` is supplied here; other combinations need their own list files.
The generated commands use a Tasman file named
`tasman/misc/search.<projectile><type>` under the selected installation root.

Cluster job creation and submission scripts such as `makejob` and
`firejob.merlin` are not included in this directory.

## Check results

Run `nuclistcheck` from a projectile directory such as `tendl/n`:

```sh
/path/to/autotalys_tools/tendl/nuclistcheck n > n.out
```

It reads `nuclides` beside the script, checks for TENDL files and, for
neutrons, PENDF and ACE files. It writes `tendl.no`, `pendf.no`, `ace.no`, and
`Naninf` in the current directory as applicable.

Run `allnuccheck` from the TENDL production directory, a projectile
directory such as `tendl/n`, or `tendl/check`:

```sh
/path/to/autotalys_tools/tendl/allnuccheck n
```

Omit `n` to process all seven projectiles. The script creates `tendl/check`
and puts all aggregate reports there, using `nuc.sec` beside the script as
its nuclide list. It collects existing diagnostic and output files from the
nuclide directories; it does not run CHECKR, FIZCON, PSYCHE, NJOY, or other
diagnostic programs.
