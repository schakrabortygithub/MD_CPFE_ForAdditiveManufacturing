moose_lammps
=====
This is concurrent multiscale model developed by coupling Molecular Dynamics(LAMMPS) with Continuum Crystal Plasticity(MOOSE).

# Features

1. Couples Molecular Dynamics with Crystal Plasticity FE.
2. MOOSE is used for continum scale modelling and LAMMPS for atomic scale modelling.
3. MOOSE is the driver code. LAMMPS is used as library.
4. The interface betweem atomistic and continuum is updated periodicaly as material is deposited at the atomistic domain. This keeps computation cost almost constant.
5. Right now continuum scale model is only thermo-elasticity. 

# Simulation results
![Coupling Scheme](https://github.com/schakrabortygithub/moose-lammps-simulations/blob/master/test/tests/SimulationResults/MD-CP_ForAM_CouplingScheme.jpg?raw=true)
![Coupling Scheme](https://github.com/schakrabortygithub/oose-lammps-simulations/blob/master/test/tests/SimulationResults/MD-CP_ForAM_DefectStraucture.jpg?raw=true)
![Coupling Scheme](https://github.com/schakrabortygithub/oose-lammps-simulations/blob/master/test/tests/SimulationResults/MD-CP_ForAM_Defects.jpg?raw=true)
![Coupling Scheme](https://github.com/schakrabortygithub/oose-lammps-simulations/blob/master/test/tests/SimulationResults/MD-CP_ForAM_EnergyTotal.jpg?raw=true)


# Build Process
First in the main 'moose', checkout to branch "CP_CDT_LAMMPS".

Then make sure the environment variable "DIRECTORY_LAMMPS" is set to LAMMPS library. You can put that in .bash_profile.
Also make sure to include that in the Makefile inside moose_app,  include $(CURDIR)/lammps.mk

Inside lammps.mk add to the variable "ADDITIONAL_INCLUDES" and "ADDITIONAL_LIBS" the lammps src and library file. 
Link the static library, dynamics library might have some issue during run-time.

ADDITIONAL_INCLUDES	+= -I${DIRECTORY_LAMMPS}/src
ADDITIONAL_LIBS 	  += ${DIRECTORY_LAMMPS}src/liblammps_mpi.a


# Featured under development
1. Identification, characterization, quantificatrion and transfer of defects from atomistic to continuum as interface is moved.
2. crystal-plasticity for continuum. Transport-based CP model will be used as developed in (https://github.com/schakrabortygithub/DiscoFluxM)

# Known Issues and Remedy
1. Make sure there are no header file of same name conflicting with lammps from the libraries within that conda environment.
https://matsci.org/t/error-while-building-examples-couple-simple-simple-cpp/44500


