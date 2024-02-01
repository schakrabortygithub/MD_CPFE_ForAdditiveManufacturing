[Mesh]
[./gmg]
  type = GeneratedMeshGenerator
  dim = 3
  nx = 10
  ny = 50
  nz = 1
  xmax = 0.0001056
  ymax = 0.0001760 # 500*3.52 for Nickel
  zmax = 0.000001
  elem_type = HEX8 #TET4, HEX, HEX8
  #show_info = True
 [] 
 [./subdomains]
    type = ParsedSubdomainMeshGenerator
    input = gmg
    combinatorial_geometry = 'y > 0.0001001'
    block_id = 1
  []
  [./Nodes_01]
    type = BoundingBoxNodeSetGenerator
    input = subdomains
    bottom_left = '-0.0000001 0.00010 -0.0000001'
    top_right = '0.0002 0.0002 0.000002'
    new_boundary = Nodes_01
	show_info = True
  [../]
  [./Nodes_02]
    type = BoundingBoxNodeSetGenerator
    input = Nodes_01
    bottom_left = '-0.0000001 0.00013 -0.0000001'
    top_right = '0.0002 0.0002 0.000002'
    new_boundary = Nodes_02
	show_info = True
  [../]
  [./Nodes_03]
    type = BoundingBoxNodeSetGenerator
    input = Nodes_02
    bottom_left = '-0.0000001 0.00015 -0.0000001'
    top_right = '0.0002 0.0002 0.000002'
    new_boundary = Nodes_03
	show_info = True
  [../]
  [./Partitioner]
    type = LibmeshPartitioner
    partitioner = linear
  [../]
  parallel_type = distributed
[]

[Outputs]
	file_base = method_Basic
    csv = true
    exodus = true
    #append_date = true
    append_date_format = '%Y-%m-%d-%H-%M-%S'
	execute_on = 'timestep_end'
  [./console]
    type = Console
	output_file = true
    max_rows = 0
  [../]
[]

[Variables]
  [./Temperature]
    order = FIRST
    family = LAGRANGE
  [../]
  [./DD_Mobile]
    order = FIRST
    family = LAGRANGE
  [../]
  [./DD_Immobile]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]  #AuxVariables
  [./Temperature_MD]
    order = FIRST
    family = LAGRANGE
  [../]
  [./DD_Mobile_MD]
    order = FIRST
    family = LAGRANGE
  [../]
  [./DD_Immobile_MD]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
#inactive = 'heat ie time'
  [./heat]
    type = HeatConduction
    variable = Temperature
  [../]
  [./ie]
    type = SpecificHeatConductionTimeDerivative
    variable = Temperature
  [../]
  
# Evolution of mobile dislocations
  [./dot_DD_Mobile]
    type = TimeDerivative  
    variable = DD_Mobile
  [../]
  [./Source_DD_Mobile]
    type = SourceDislocationVolumeThermal  
    variable = DD_Mobile
	Temperature = Temperature
  [../]
  
# Evolution of immmobile dislocations
  [./dot_DD_Immobile]
    type = TimeDerivative  
    variable = DD_Immobile
  [../]
[]

[ICs]
  [./IC_Temperature]
    type = FunctionIC
    variable = 'Temperature'
    function = '0'
  [../]
  [./IC_Temperature_MD]
    type = FunctionIC
    variable = 'Temperature_MD'
    function = '300 + 1000*(y/0.0001)'
  [../]
  
  [./IC_DD_Mobile]
    type = FunctionIC
    variable = 'DD_Mobile'
    function = '1.0e+08'
  [../]
  [./IC_DD_Immobile]
    type = FunctionIC
    variable = 'DD_Immobile'
    function = '1.0e+08'
  [../]
[]

[BCs]
#inactive = 'top02 top03'
  [./bottom]
    type = DirichletBC
    variable = Temperature
    boundary = 'bottom'
    value = 270.0
  [../]

  [./top01]
    type = DirichletBCfromMD  #DirichletBC
    variable = Temperature
	variable_MD = Temperature_MD
    boundary = Nodes_01
    value = 1700.0
  [../]
  [./top02]
    type = DirichletBCfromMD
    variable = Temperature
	variable_MD = Temperature_MD
    boundary = Nodes_02
    value = 1700.0
  [../]
  [./top03]
    type = DirichletBCfromMD
    variable = Temperature
	variable_MD = Temperature_MD
    boundary = Nodes_03
    value = 1700.0
  [../]
  
  [./Periodic]
    [./LRx]
      variable = Temperature
	  primary = 'left'
      secondary = 'right'
      auto_direction = 'x'
    [../]
   []
[]

[Controls] # turns off inertial terms for the first time step
#inactive = 'release0'
  [./release01]
    type = TimePeriod
	#enable_objects = '*::top02'
    disable_objects = '*::top01'
    start_time = 10.0e-11
    #end_time = 30.0e-11 # dt used in the simulation
  [../]
  [./release02]
    type = TimePeriod
	#enable_objects = '*::top03'
    disable_objects = '*::top02'
    start_time = 20.0e-11
    #end_time = 30.0e-11 # dt used in the simulation
  [../]
[../]


[Materials]
  [./MatConstant]
    type = GenericConstantMaterial
    #block = 1
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '97.5e-03 0.5 9.0e-03'  #thermal_conductivity(W/(mm K)) specific_heat(J/(g K)) density(g/mm^3)
  [../]
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Modules/TensorMechanics/Master/all]
  strain = FINITE
  add_variables = true
  #volumetric_locking_correction=true
  generate_output = 'stress_xx stress_yy stress_xy strain_xx strain_yy strain_xy'
[]

[Materials]
inactive = 'elasticity_tensor_02'
  [./elasticity_tensor_01]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e6
    poissons_ratio = 0.25
  [../]
  [./elasticity_tensor_02]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.684e5 1.214e5 1.214e5 1.684e5 1.214e5 1.684e5 0.754e5 0.754e5 0.754e5'
    fill_method = symmetric9
    read_prop_user_object = prop_read
  [../]
  [./stress]
    type = ComputeFiniteStrainElasticStress
  [../]
[]

[BCs]
  [./BC_Bottom_X]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = 'bottom'
    function = 0.0
  [../]
  [./BC_Bottom_Y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = 'bottom'
    function = 0.0
  [../]
  [./BC_Bottom_Z]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = 'bottom'
    function = 0.0
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient  #Transient, TransientCoupledMD
  FlagRunMD = true #false
  solve_type = 'NEWTON' #'NEWTON' , 'PJFNK'
  automatic_scaling = false # 'true' will throw segfault due to memory issue
  #scaling_group_variables = 'disp_x disp_y disp_z; Rho_EdgePositive_01'
  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  petsc_options_value = ' asm      2              lu            gmres     200'
  nl_abs_tol = 1e-8  #1e-10 for all *_tol
  nl_rel_tol = 1e-5
  nl_abs_step_tol = 1e-8 
  #nl_max_its = 10

  start_time = 0.0
  num_steps = 50
  dt = 1.0e-11
[]

[AuxVariables]
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [stress_xx]
    type = RankTwoAux
    variable = stress_xx
    rank_two_tensor = stress
    index_j = 0
    index_i = 0
    execute_on = timestep_end
  []
  [stress_yy]
    type = RankTwoAux
    variable = stress_yy
    rank_two_tensor = stress
    index_j = 1
    index_i = 1
    execute_on = timestep_end
  []
  [stress_zz]
    type = RankTwoAux
    variable = stress_zz
    rank_two_tensor = stress
    index_j = 2
    index_i = 2
    execute_on = timestep_end
  []
[]

[Postprocessors]
  [stress_xx]
    type = ElementAverageValue
    variable = stress_xx
  []
  [stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  []
  [stress_zz]
    type = ElementAverageValue
    variable = stress_zz
  []
  [PP_T]
    type = ElementAverageValue
    variable = Temperature
  []
[]
  