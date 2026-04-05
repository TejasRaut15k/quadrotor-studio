function nextState = quadrotorDynamicsStep(state, command, params, dt)
%QUADROTORDYNAMICSSTEP Advance the rigid-body state by one explicit step.

if nargin < 4
    dt = params.sim.dt;
end

m = params.vehicle.mass;
g = params.vehicle.g;
J = params.vehicle.inertia;

rotation = eulerToRotationMatrix(state.euler);
thrustWorld = rotation * [0.0; 0.0; command.totalThrust];
gravity = [0.0; 0.0; g];

velocityDot = thrustWorld / m - gravity - params.vehicle.linearDrag .* state.velocity;
omegaDot = J \ (command.moments - cross(state.omega, J * state.omega) - params.vehicle.angularDrag .* state.omega);
eulerDot = eulerRateMatrix(state.euler) * state.omega;

nextState = state;
nextState.time = state.time + dt;
nextState.velocity = state.velocity + velocityDot * dt;
nextState.position = state.position + nextState.velocity * dt;
nextState.omega = state.omega + omegaDot * dt;
nextState.euler = state.euler + eulerDot * dt;
nextState.euler(3) = quadrotorWrapToPi(nextState.euler(3));
nextState.rotorThrusts = command.rotorThrusts;

if nextState.position(3) < 0.0
    nextState.position(3) = 0.0;
    if nextState.velocity(3) < 0.0
        nextState.velocity(3) = 0.0;
    end
    nextState.velocity(1:2) = 0.94 * nextState.velocity(1:2);
    nextState.omega(1:2) = 0.90 * nextState.omega(1:2);
    nextState.euler(1:2) = 0.95 * nextState.euler(1:2);
end

end

function rotation = eulerToRotationMatrix(euler)

phi = euler(1);
theta = euler(2);
psi = euler(3);

cphi = cos(phi);
sphi = sin(phi);
cth = cos(theta);
sth = sin(theta);
cpsi = cos(psi);
spsi = sin(psi);

rotation = [ ...
    cpsi * cth, cpsi * sth * sphi - spsi * cphi, cpsi * sth * cphi + spsi * sphi; ...
    spsi * cth, spsi * sth * sphi + cpsi * cphi, spsi * sth * cphi - cpsi * sphi; ...
    -sth,       cth * sphi,                          cth * cphi];

end

function mapping = eulerRateMatrix(euler)

phi = euler(1);
theta = max(min(euler(2), deg2rad(89.0)), deg2rad(-89.0));

mapping = [ ...
    1.0, sin(phi) * tan(theta), cos(phi) * tan(theta); ...
    0.0, cos(phi),             -sin(phi); ...
    0.0, sin(phi) / cos(theta), cos(phi) / cos(theta)];

end
