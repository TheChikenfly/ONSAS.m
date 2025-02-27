% function for testing ONSAS using moxunit
% ----------------------------------------

function test_suite=runTestProblems_moxunit_disp
  % initialize tests
  try
    test_functions=localfunctions()
  catch
  end
  initTestSuite;

function test_1
  onsasExample_staticVonMisesTruss
  assertEqual( verifBoolean, true );

function test_2
  onsasExample_uniformCurvatureCantilever
  assertEqual( verifBoolean, true );

function test_3
  onsasExample_linearPlaneStrain
  assertEqual( verifBoolean, true );
  
function test_4
  uniaxialExtension
  assertEqual( verifBoolean, true );


function test_5
  onsasExample_nonlinearPendulum
  assertEqual( verifBoolean, true );

function test_6
  springMass
  assertEqual( verifBoolean, true );

function test_7
  onsasExample_cantileverSelfWeight
  assertEqual( verifBoolean, true );

function test_8
  simpleWindTurbine
  assertEqual( verifBoolean, true );

function test_9
  frameLinearAnalysis
  assertEqual( verifBoolean, true );

function test_10
  linearAerodynamics
  assertEqual( verifBoolean, true );

function test_11
  consistentCantileverBeam
  assertEqual( verifBoolean, true );