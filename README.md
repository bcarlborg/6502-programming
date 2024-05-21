# 6502-programming

Programs written for the `6502` 8 bit CPU running on a home built breadboard system. 

## Demo
A video explaining the hardware and software for this system along with demos of the programs in this repository can be found on youtube [here](https://youtu.be/JMgLx2TyrVw).

<p align="center">
  <a href="https://youtu.be/JMgLx2TyrVw">
    <img alt="6502 programming demo thumbnail" width="70%" src="https://user-images.githubusercontent.com/18710035/196743711-850ec1b8-618a-4a03-ade2-dd102c83d693.png" />
  </a>
</p>


## Repository Overview
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
├── global_utilities/        : A directory containing helper routines and header files that
│   ├── ...header files      : can be used in any project
│   └── ...assembly files
│
├── objs/                    : Directory conaining all output and intermediary object files
│   ├── ...header files      : files from builds and output executables
│   └── ...object files
│
└── projects/                : Directories containing all project specific code. Each of
    ├── project_1/           : these projcts can be built and uploaded to the cpu system on
    │   ├── README.md        : their own. Each project contains its own readme that contains
    │   ├── *.s              : info about that specific project along with demos.
    │   └── main.s           :
    │                        :
    ├── project_2/           : Most projects rely in some way on a helper in global_utilities,
    │   ├── README.md        : and the objects for these projects are build into objs/
    │   ├── *.s
    │   └── main.s
    │
    └── project_n/
        ├── *.s
        └── main.s
```

## System Hardware
| System on board  | Annotated system on board |
| ------------- | ------------- |
| <img width="728" alt="6502 on board as of 2022-10-13" src="https://user-images.githubusercontent.com/18710035/195679940-550de15b-9784-4a2c-92d3-41a7b6d89935.png"> | <img width="728" alt="Annotated 6502 on board as of 2022-10-13" src="https://user-images.githubusercontent.com/18710035/195679791-31c1bf20-cd9c-4a23-963b-74515c1b16d2.png"> |



## Additional Info
- [The architecture readme](ARCHITECTURE.md) : Has designs and links for the system hardware, semi-accurate schematics along with annotated images of the system on breadboards.
- [The programmer's guide](PROGRAMMERS_GUIDE.md) : Provides an overview of the system from a programmers perspective and some key details one would need to write code for this system.
  - Describes the toolchain used to assemble and link binaries along with where those tools can be found and built.
  - Provides an overview of some in code constructs that are used frequently throughout the project.
  - Describes basic style and conventions used in the programs.
- Project specific info : This repository contains many sub projects that can be built and uploaded to the 6502 system build. Each has their own readme
  - Base Print Test project [readme](projects/base_print_test/README.md) (Currently a work in progress)
  - Blinking Light Timer project [readme](projects/blinking_light_timer/README.md) (Currently a work in progress)
  - Simple Text Editor project [readme](projects/simple_text_editor/README.md) (Currently a work in progress)



