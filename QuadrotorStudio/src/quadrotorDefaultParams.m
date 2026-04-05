function params = quadrotorDefaultParams()
%QUADROTORDEFAULTPARAMS Default tuning and scene values.

params.sim.dt = 0.02;
params.sim.substeps = 2;
params.sim.maxHistory = 700;

params.vehicle.mass = 1.25;
params.vehicle.g = 9.81;
params.vehicle.armLength = 0.22;
params.vehicle.inertia = diag([0.020 0.020 0.036]);
params.vehicle.minRotorThrust = 0.0;
params.vehicle.maxRotorThrust = 9.5;
params.vehicle.yawMomentCoeff = 0.035;
params.vehicle.linearDrag = [0.18; 0.18; 0.28];
params.vehicle.angularDrag = [0.16; 0.16; 0.10];
params.vehicle.rotorPositions = [ ...
     params.vehicle.armLength,  0.0,                       -params.vehicle.armLength, 0.0; ...
     0.0,                       -params.vehicle.armLength,  0.0,                       params.vehicle.armLength; ...
     0.0,                        0.0,                      0.0,                       0.0];
params.vehicle.spinDirections = [-1 1 -1 1];

params.controller.posKp = [1.8; 1.8; 3.4];
params.controller.posKd = [1.3; 1.3; 2.6];
params.controller.attKp = [9.0; 9.0; 3.6];
params.controller.attKd = [0.45; 0.45; 0.30];
params.controller.maxTilt = deg2rad(18.0);
params.controller.maxAccelXY = 3.2;
params.controller.maxAccelZ = 4.0;
params.controller.homePosition = [0.0; 0.0; 2.0];
params.controller.homeYaw = 0.0;

params.scene.xLim = [-3.5 3.5];
params.scene.yLim = [-3.5 3.5];
params.scene.zLim = [0.0 8.0];
params.scene.padRadii = [0.25 0.55 0.95];
params.scene.keyStepXY = 0.15;
params.scene.keyStepZ = 0.20;
params.scene.keyStepYaw = deg2rad(8.0);

end
