function state = quadrotorInitialState(params)
%QUADROTORINITIALSTATE Initial state used when the simulator starts.

hoverThrust = params.vehicle.mass * params.vehicle.g / 4.0;

state.time = 0.0;
state.position = [0.0; 0.0; 0.0];
state.velocity = [0.0; 0.0; 0.0];
state.euler = [0.0; 0.0; 0.0];
state.omega = [0.0; 0.0; 0.0];
state.rotorThrusts = hoverThrust * ones(4, 1);

end
