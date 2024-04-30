# MD_CPFE_ForAdditiveManufacturing

Concurrent multiscale model developed by coupling Molecular Dynamics(LAMMPS) with Continuum Crystal Plasticity(MOOSE) is used to study the effect of process parameter in defect generation during Additive Manufactirung process.

# Features

1. Couples Molecular Dynamics with Crystal Plasticity FE.
2. MOOSE is used for continum scale modelling and LAMMPS for atomic scale modelling.
3. MOOSE is the driver code. LAMMPS is used as library.
4. The interface betweem atomistic and continuum is updated periodicaly as material is deposited at the atomistic domain. This keeps computation cost almost constant.
5. Right now continuum scale model is only thermo-elasticity. 

# Simulation results
![Coupling Scheme](https://github.com/schakrabortygithub/MD_CPFE_ForAdditiveManufacturing/blob/master/SimulationResults/MD-CP_ForAM_CouplingScheme.jpg?raw=true)
![Coupling Scheme](https://github.com/schakrabortygithub/MD_CPFE_ForAdditiveManufacturing/blob/master/SimulationResults/MD-CP_ForAM_DefectStraucture.jpg?raw=true)
![Coupling Scheme](https://github.com/schakrabortygithub/MD_CPFE_ForAdditiveManufacturing/blob/master/SimulationResults/MD-CP_ForAM_Defects.jpg?raw=true)
![Coupling Scheme](https://github.com/schakrabortygithub/MD_CPFE_ForAdditiveManufacturing/blob/master/SimulationResults/MD-CP_ForAM_EnergyTotal.jpg?raw=true)

# Featured under development
1. Identification, characterization, quantificatrion and transfer of defects from atomistic to continuum as interface is moved.
2. crystal-plasticity for continuum. Transport-based CP model will be used as developed in (https://github.com/schakrabortygithub/DiscoFluxM)



