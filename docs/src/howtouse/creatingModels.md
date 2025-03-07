# Creating structural models

The data and properties of each structural model are defined through a set of definitions in a .m script. These properties are stored in [struct](https://octave.org/doc/v5.2.0/Structures.html#Structures) data structures. The following structs must be defined and provided as input to the ONSAS function in this order:

 1. `materials`
 1. `elements`
 1. `boundaryConds`
 1. `initialConds`
 1. `mesh`
 1. `numericalMethod`
 1. `otherParams`

Each struct has its own _fields_ with specific names, used to store each corresponding property or information. Each field is obtained or assigned using _structName.fieldName_. A description of each struct and its fields follows at next.

## The `materials` struct

The materials struct contains the information of the material behavior considered for each element.

### `material.hyperElasModel`

This is a cell array with the string-names of the material models used, the options for these names are:
 * `'linearElastic'`: for linear behavior in small strains and displacements. The scalar parameters of this model are $p_1=E$ the Young modulus and $p_2=\nu$ the Poisson's ratio.
 * `'SVK'`: for a Saint-Venant-Kirchhoff material where the parameters $p_1$ and $p_2$ are the Lamé parameters and $\textbf{E}$ is the Green-Lagrange strain tensor, with the strain-energy density function given by
```math
\Psi( \textbf{E} ) = \frac{p_1}{2} tr(\textbf{E})^2 + p_2 tr(\textbf{E}^2)
\quad
p_1 = \frac{ E \nu }{ (1+\nu) (1-2\nu) }
\quad
p_2 = \frac{ E }{ 2 (1+\nu) }
```
 * `'NHC'`: for a Neo-Hookean compressible material. The model implemented is given by
```math
\Psi( \textbf{C} ) = \frac{p_1}{2} ( tr(\textbf{C})-3 -2 L( \sqrt{det(\textbf{C})} ) ) + \frac{p_2}{2} \left( \sqrt{det(\textbf{C})}-1 \right)^2
 \quad
 p_1 = \frac{ E }{ 2 (1+\nu) }
 \quad
 p_2 = \frac{ E }{ 3 (1-2 \nu) }
```

### `materials.hyperElasParams`
A cell structure with vectors with the material properties of each material used in the model. The $i$-th entry of the cell, contains a vector like this:
```math
[ p_1 \dots p_{n_P} ]
```
where $n_P$ is the number of parameters of the constitutive model and $\mathbf{p}$ is the vector of constitutive parameters.

### `material.density`

This is a cell with the scalar values of the densities of the materials used in the model.

### `material.nodalMass`

This fields sets a vector of nodal masses components $[m_x, m_y, m_z]$ that is assigned to nodes.

## The `elements` struct

The elements struct contains the information about the type of finite elements used and their corresponding parameters.

### `elements.elemType`
cell structure with the string-names of the elements used: `node`, `truss`, `frame`, `triangle` or `tetrahedron`. Other auxiliar types such as `edge` are also available

### `elements.elemTypeParams`
cell structure with auxiliar params information, required for some element types:

 * `triangle` vector with parameters, the first parameter is an integer indicating if plane stress (1) or plane strain (2) case is considered.
### `elements.massMatType`

 
 The `massMatType` field sets, for frame or truss elements, whether consistent or lumped mass matrix is used for the inertial term in dynamic analyses. The `massMatType` field should be set as a string variable: `'consistent'` or `'lumped'`,  and if it is not declared then by default the `'lumped'` mass matrix is set.

 ### `elements.elemTypeAero`
The `elementTypeAero` field is a vector that sets for frame aerodynamic co-rotational element the chord vector in total-deformed coordinates $t$ (which initially are equal to reference $e$), and the number of gauss points $numGauss$:
```math
\{ vch_{t1} \,\, vch_{t2} \,\, vch_{t3} \,\,numGauss\}
```
 ### `elements.aeroCoefs`

The `aeroCoefs`field is a column cell that sets the function names for the aerodynamic co-rotational frame element. The information is added into a cell of strings containing the drag, lift and torsional moment function names whose inputs are the relative angle of incidence and Reynolds number. If any of the coefficients is not considered then an empty `[]` should be added. 

### `elements.elemTypeGeometry`

This is a cell structure with the information of the geometry of the element.

#### 1D elements

For `truss` or `frame` elements, this cell contains the cross-section properties:
```math
\{ crossSectionTypeString, \,\, crossSectionParam_{1}, \,\,\dots,\,\, crossSectionParam_{n}\}
```
with $n$ being the number of parameters of the cross section type, and `crossSectionTypeString` the type of cross section. The possible cross-section and its properties are:

 - `generic`  :general sections, where areas and inertias are provided as parameters
 - `rectangle`: rectangular sections where thicknesses ``t_y`` and ``t_z`` are provided
 - `circle` : circular sections where diameter is provided.

See the `crossSectionProps.m` function for more details.

For `edge` elements the thickness is expected (for 2D load computations).

#### 2D elements

For 2D elements such as `triangle` the thickness is expected to be introduced. The elementtype  


## The `boundaryConds` struct

### `boundaryConds.loadsCoordSys`
cell containing the coordinates system for the loads applied in each BC, each entry should be a `'global'` string or a `'local'`, or an empty array if no load is applied in that BC setting `[]`.

### `boundaryConds.loadsTimeFact`
cell with the inline function definitions of load factors of the loads applied of an empty array.

### `boundaryConds.loadsBaseVals`
cell with the (row) vector of the components of the load case
```math
[ f_x,  \, m_x, \, f_y, \, m_y, \, f_z, \, m_z ]
```
where $f_i$ are the components of forces and $m_i$ are the moments. Both forces or moments are considered per unit of length in the case of `truss`/`frame`/`edge` elements, or per unit of area in the case of `triangle`.

### `boundaryConds.userLoadsFileName`
cell with filenames of `.m` function file provided by the user that can be used to apply other forces.

### `boundaryConds.imposDispDofs`
cell with vectors of the local degrees of freedom imposed (integers from 1 to 6)
### `boundaryConds.imposDispVals`
cell with vectors of the values of displacements imposed.
### `boundaryConds.springsDofs`
cell with vectors of the local degrees of freedom with springs (integers from 1 to 6)
### `boundaryConds.springsVals`
cell with vectors of the values of the springs stiffnesses.

## The `initialConds` struct

It initial conditions are homogeneous, then an empty struct should be defined `initialConds = struct() ;`.

### `initialConds.nonHomogeneousInitialCondU0`
matrix to set  the value of displacements at the time step $t$=0. [default: []]
### `initialConds.nonHomogeneousInitialCondUdot0`
matrix to prescribe the value of velocities at the time step $t$=0. [default: []]

## The `mesh` struct

The mesh struct contains the finite element mesh information.

### `mesh.nodesCoords`
matrix with the coordinates of all the nodes of the mesh. The $i$-th row contains the three coordinates of the node $i$: $[x_i , \, y_i ,\, z_i]$,

### `mesh.conecCell`
[cell array](https://octave.org/doc/v5.2.0/Cell-Arrays.html) with the elements and node-connectivity information. The $\{i,1\}$ entry contains the vector with the MEBI (Material, Element, boundaryConds and initialConds) indexes and the nodes of the $i$-th element. The structure of the vector at each entry of the cell is:
```math
 [ materialInd, \, elementInd, \, boundaryCondInd, \, initialCondInd, \, node_1 \dots node_{n} ]
```
where the five indexes are natural numbers and $n$ is the number of nodes required by the type of element. If no property is assigned the $0$ index can be used, for instance, nodes used to introduced loads should be defined with `materialIndex = 0`.

## The `analysisSettings` struct

This struct contains the parameters required to apply the numerical method for the resolution of the nonlinear equations:

 * `methodName`: string with the name of the method used: `'newtonRaphson'`,`'arcLength'`,`'newmark'`,`'alphaHHT'`.
 * `stopTolDeltau`: float with tolerance for convergence in relative norm of displacements increment
 * `stopTolForces`: float with tolerance for convergence in relative norm of residual loads
 * `stopTolIts`: integer with maximum number of iterations per time step
 * `deltaT`: time step
 * `finalTime`: final time of simulation
 * `incremArcLen`: with of cylinder for arcLength method
 * `deltaNM`: delta parameter of newmark method. If this parameter is not declared then the classic Trapezoidal Newmark delta = $1/2$ is set.
 * `alphaNM`: alpha parameter of newmark method. If this parameter is not declared then the classic  Trapezoidal Newmark alpha = $1/4$ is set.
 * `alphaHHT`: alpha parameter of alpha-HHT method. If this parameter is not declared then alpha=$-0.05$ is set.
 * `posVariableLoadBC`: (parameter used by the arcLength method) this parameter is an integer with the entry of the _boundaryConds_ cell corresponding with the loads vector affected by the load factor
 * `iniDeltaLamb`: (parameter used by the arcLength method) this parameter sets the initial increment for the load factor $\lambda$.

another additional optional parameters are:

 * `booleanSelfWeight`: a boolean indicating if self weight loads are considered or not. The loads are computed using the density of the material and in the $-z$ global direction.
 * `iniMatUs`: a matrix with initial solutions for each time step.

then the aerodynamic-frame element parameters set are
* `fluidProps`: is a row cell with the density $\rho_f$, viscosity $\nu_f$ and the function with the fluid velocity  

```math
\{ \rho_f; \,\, \rho_f; \,\, \rho_f; \,\,numGauss\}
```

## The `otherParams` struct

  * `problemName`: string with the name of the problem, to be used in outputs.
  * `plotsFormat`: strint indicating the format of the output. Use __'vtk'__ for vtk output.
  * `controlDofs`: matrix with information of the degrees of freedom to compute and control. Each row should contain this form: `[ node localdof ]`.
  * `storeBoolean`: boolean to store the results of the current iteration such as the displacements, tangent matrices, normal forces and stresses. [default: 1]
  * `nodalDispDamping`: scalar value of a linear viscous damping factor applied for all the displacement degrees of freedom [default: 0]
