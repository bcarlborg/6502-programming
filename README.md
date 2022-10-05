# 6502-programming

Programs written for the `65C02` 8 bit CPU running on a home built breadboard system.

## Overview
The system these programs are designed for is similar to the one implemented in Ben Eaters Design a 6502 from scratch [youtube series](https://www.youtube.com/playlist?list=PLowKtXNTBypFbtuVMUVXNR0z1mu7dp7eH). Differences between the two systems are described in [the architecture readme](ARCHITECTURE.md).

The repository has the following structure
```
6502-programming
├── README.md                : Project overview
│
├── ARCHITECTURE.md          : Information about the computer system and hardware
│
├── PROGRAMMERS_GUIDE.md     : Information needed to write, assemble, and link programs
│                            : for this system
│
├── todo.txt                 : A variably up-to-date mostly unoficial list of things to do
│                            : for this project
│
├── Makefile                 : Makefile with targets and recipes to build every project
│                            : see PROGRAMMERS_GUIDE.md for information on how to use it
│
├── link.config              : Linker script used by vlink
│
├── global_utilities         : A directory containing helper routines and header files that
│   ├── ...header files      : can be used in any project
│   └── ...assembly files
│
├── objs                     : Directory conaining all output and intermediary object files
│   ├── ...header files      : files from builds and output executables
│   └── ...object files
│
└── projects                 : Directories containing all project specific code. Each of
    ├── project_1            : these projcts can be built and uploaded to the cpu system on
    │   ├── DEMO.MD          : their own. Each project contains its own readme that contains
    │   ├── *.s              : info about that specific project along with demos.
    │   └── main.s           :
    ├── project_2            : Most projects rely in some way on a helper in global_utilities,
    │   ├── DEMO.MD          : and the objects for these projects are build into objs/
    │   ├── *.s
    │   └── main.s
    └── ... projects
```



## Additional Info
- [The architecture readme](ARCHITECTURE.md) : Describes design of the system hardware, semi-acurrate schematics, and annotated images of the system on breadboards.
- [The programmer's guide](PROGRAMMERS_GUIDE.md) : Provides an overview of the system from a programmers perspective. Provides an overview of some key details one needs to write code for this system.
  - Describes the toolchain used to assemble and link binaries along with where those tools can be found and built.
  - Provides an overview of some in code constructs that are used frequently throughout the project.
  - Describes basic style and conventions used in the programs.
- [Demos!](DEMOS.md) : Demos of the various projects contained in this repository


## Selected Images and Demos

| System on board  | Annotated system on board |
| ------------- | ------------- |
| <img width="728" alt="6502 on board as of 2022-10-04" src="https://user-images.githubusercontent.com/18710035/194104879-ade6bda7-72d2-4f17-b37f-e2d8d81312ca.png"> | <img width="728" alt="Annotated 6502 on board as of 2022-10-04" src="https://user-images.githubusercontent.com/18710035/194104595-60f03871-c6de-4e33-91be-af4ae55edb9f.png"> |

