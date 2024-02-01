[Mesh]
[./gmg]
  type = GeneratedMeshGenerator
  dim = 3
  nx = 4
  ny = 4
  nz = 4
  xmax = 0.1
  ymax = 0.1
  zmax = 0.1
  elem_type = HEX8 #TET4, HEX, HEX8
  #show_info = True
 [] 
 [./subdomains]
    type = ParsedSubdomainMeshGenerator
    input = gmg
    combinatorial_geometry = '(x) > (0.05001*1)'
    block_id = 1
  []
  [./left_bottom_node]
    type = BoundingBoxNodeSetGenerator
    input = subdomains
    bottom_left = '-0.0001 -0.0001 -0.0001'
    top_right = '0.0001 0.0001 1.0001'
    new_boundary = left_bottom_node
	show_info = True
  [../]
  [./back_bottom_node]
    type = BoundingBoxNodeSetGenerator
    input = left_bottom_node
    bottom_left = '-0.0001 -0.0001 -0.0001'
    top_right = '1.001 0.001 0.001'
    new_boundary = back_bottom_node
  [../]
  [./Partitioner]
    type = LibmeshPartitioner
    partitioner = linear
  [../]
  parallel_type = distributed
[]

[Outputs]
	file_base = method_ThermoCP
    csv = true
    exodus = true
    append_date = true
    append_date_format = '%Y-%m-%d-%H-%M-%S'
	execute_on = 'timestep_end'
  [./console]
    type = Console
	output_file = true
    max_rows = 0
  [../]
[]

[UserObjects]
  [./prop_read]
    type = PropertyReadFile
    prop_file_name = 'euler_ang_file.inp' #'EulerAngle_cylinder_n10_01.ori' , 'euler_ang_file.inp'
    # Enter file data as prop#1, prop#2, .., prop#nprop
    nprop = 3
    read_type = block
    nblock= 20
  [../]
[]

[AuxVariables]
  [temperature]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxKernels]
  [temperature]
    type = FunctionAux
    variable = temperature
    function = '0+900*t' # temperature increases at a constant rate
    execute_on = timestep_begin
  []
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
#inactive ='elasticity_tensor01 stress_01 '
inactive ='elasticity_tensor02 stress_02 trial_xtalpl thermal_eigenstrain_1 thermal_eigenstrain_2'
  [./elasticity_tensor01]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.684e5 1.214e5 1.214e5 1.684e5 1.214e5 1.684e5 0.754e5 0.754e5 0.754e5'
    fill_method = symmetric9
    read_prop_user_object = prop_read
  [../]
  [./stress_01]
    type = ComputeFiniteStrainElasticStress
  [../]
  
  [elasticity_tensor02]
    type = ComputeElasticityTensorConstantRotationCP
    C_ijkl = '1.684e5 1.214e5 1.214e5 1.684e5 1.214e5 1.684e5 0.754e5 0.754e5 0.754e5'
    fill_method = symmetric9
  []
  [stress_02]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = 'trial_xtalpl'
    eigenstrain_names = "thermal_eigenstrain_1 thermal_eigenstrain_2"
    tan_mod_type = exact
    maximum_substep_iteration = 5
  []
  [trial_xtalpl]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 12
    slip_sys_file_name = input_slip_sys.inp
  []
  [thermal_eigenstrain_1]
    type = ComputeCrystalPlasticityThermalEigenstrain
    eigenstrain_name = thermal_eigenstrain_1
    deformation_gradient_name = thermal_deformation_gradient_1
    temperature = temperature
    thermal_expansion_coefficients = '1e-05 2e-05 3e-05' # thermal expansion coefficients along three directions
  []
  [thermal_eigenstrain_2]
    type = ComputeCrystalPlasticityThermalEigenstrain
    eigenstrain_name = thermal_eigenstrain_2
    deformation_gradient_name = thermal_deformation_gradient_2
    temperature = temperature
    thermal_expansion_coefficients = '2e-05 3e-05 4e-05' # thermal expansion coefficients along three directions
  []
[]

[BCs]
#inactive = 'BC_Bottom_X BC_Top_X BC_Bottom_Y BC_Top_Y'
  [./BC_Bottom_X]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = 'bottom' 
    function = '0.00'
  [../]
  [./BC_Bottom_Y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = 'bottom' 
    function = '0.00'
  [../]
  [./BC_Top_X]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = 'top'
    function = '0.0*y*t'
  [../] 
  [./BC_Top_Y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = 'top'
    function = '0.0*y*t'
  [../]
  
  [./BC_BottomLeft_X]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = 'left_bottom_node'
    function = 0.0
  [../]
   [./BC_BottomLeft_Y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = 'left_bottom_node'
    function = 0.0
  [../]
   [./BC_BottomBack_Y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = 'back_bottom_node'
    function = 0.0
  [../]
   [./BC_BottomBack_Z]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = 'back_bottom_node'
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
  type = Transient
  solve_type = 'NEWTON' #'NEWTON' , 'PJFNK'
  automatic_scaling = false # 'true' will throw segfault due to memory issue
  #scaling_group_variables = 'disp_x disp_y disp_z; Rho_EdgePositive_01'
  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  petsc_options_value = ' asm      2              lu            gmres     200'
  nl_abs_tol = 1e-5  #1e-10 for all *_tol
  nl_rel_tol = 1e-5
  nl_abs_step_tol = 1e-5  
  #nl_max_its = 10

  dt = 0.01
  dtmin = 0.00001
  dtmax = 0.05
  end_time = 0.1
[]


[AuxVariables]
  [f1_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [f1_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [f1_zz]
    order = CONSTANT
    family = MONOMIAL
  []
  [f2_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [f2_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [f2_zz]
    order = CONSTANT
    family = MONOMIAL
  []
  [feig_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [feig_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [feig_zz]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [f1_xx]
    type = RankTwoAux
    variable = f1_xx
    rank_two_tensor = thermal_deformation_gradient_1
    index_j = 0
    index_i = 0
    execute_on = timestep_end
  []
  [f1_yy]
    type = RankTwoAux
    variable = f1_yy
    rank_two_tensor = thermal_deformation_gradient_1
    index_j = 1
    index_i = 1
    execute_on = timestep_end
  []
  [f1_zz]
    type = RankTwoAux
    variable = f1_zz
    rank_two_tensor = thermal_deformation_gradient_1
    index_j = 2
    index_i = 2
    execute_on = timestep_end
  []
  [f2_xx]
    type = RankTwoAux
    variable = f2_xx
    rank_two_tensor = thermal_deformation_gradient_2
    index_j = 0
    index_i = 0
    execute_on = timestep_end
  []
  [f2_yy]
    type = RankTwoAux
    variable = f2_yy
    rank_two_tensor = thermal_deformation_gradient_2
    index_j = 1
    index_i = 1
    execute_on = timestep_end
  []
  [f2_zz]
    type = RankTwoAux
    variable = f2_zz
    rank_two_tensor = thermal_deformation_gradient_2
    index_j = 2
    index_i = 2
    execute_on = timestep_end
  []
  [feig_xx]
    type = RankTwoAux
    variable = feig_xx
    rank_two_tensor = eigenstrain_deformation_gradient
    index_j = 0
    index_i = 0
    execute_on = timestep_end
  []
  [feig_yy]
    type = RankTwoAux
    variable = feig_yy
    rank_two_tensor = eigenstrain_deformation_gradient
    index_j = 1
    index_i = 1
    execute_on = timestep_end
  []
  [feig_zz]
    type = RankTwoAux
    variable = feig_zz
    rank_two_tensor = eigenstrain_deformation_gradient
    index_j = 2
    index_i = 2
    execute_on = timestep_end
  []
[]

[Postprocessors]
  [temperature]
    type = ElementAverageValue
    variable = temperature
  []
  [stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  []
  [f1_xx]
    type = ElementAverageValue
    variable = f1_xx
  []
  [f1_yy]
    type = ElementAverageValue
    variable = f1_yy
  []
  [f1_zz]
    type = ElementAverageValue
    variable = f1_zz
  []
  [f2_xx]
    type = ElementAverageValue
    variable = f2_xx
  []
  [f2_yy]
    type = ElementAverageValue
    variable = f2_yy
  []
  [f2_zz]
    type = ElementAverageValue
    variable = f2_zz
  []
  [feig_xx]
    type = ElementAverageValue
    variable = feig_xx
  []
  [feig_yy]
    type = ElementAverageValue
    variable = feig_yy
  []
  [feig_zz]
    type = ElementAverageValue
    variable = feig_zz
  []
[]
  