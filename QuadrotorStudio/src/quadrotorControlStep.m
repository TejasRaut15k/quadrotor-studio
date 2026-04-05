function command = quadrotorControlStep(state, target, params)
%QUADROTORCONTROLSTEP Cascade position/attitude controller.

g = params.vehicle.g;
m = params.vehicle.mass;

posError = target.position - state.position;
velError = -state.velocity;

accelCmd = params.controller.posKp .* posError + params.controller.posKd .* velError;
accelCmd(1:2) = clampVector(accelCmd(1:2), params.controller.maxAccelXY);
accelCmd(3) = clampScalar(accelCmd(3), -params.controller.maxAccelZ, params.controller.maxAccelZ);

psiCmd = target.yaw;
phiCmd = (accelCmd(1) * sin(psiCmd) - accelCmd(2) * cos(psiCmd)) / g;
thetaCmd = (accelCmd(1) * cos(psiCmd) + accelCmd(2) * sin(psiCmd)) / g;
phiCmd = clampScalar(phiCmd, -params.controller.maxTilt, params.controller.maxTilt);
thetaCmd = clampScalar(thetaCmd, -params.controller.maxTilt, params.controller.maxTilt);

desiredEuler = [phiCmd; thetaCmd; psiCmd];
attError = desiredEuler - state.euler;
attError(3) = quadrotorWrapToPi(attError(3));

desiredMoments = params.controller.attKp .* attError - params.controller.attKd .* state.omega;

collectiveThrust = m * (g + accelCmd(3));
collectiveThrust = clampScalar( ...
    collectiveThrust, ...
    4.0 * params.vehicle.minRotorThrust, ...
    4.0 * params.vehicle.maxRotorThrust);

rotorForces = mixRotorForces(collectiveThrust, desiredMoments, params);

command.accelCmd = accelCmd;
command.desiredEuler = desiredEuler;
command.totalThrust = sum(rotorForces);
command.rotorThrusts = rotorForces;
command.moments = rotorMoments(rotorForces, params);

end

function rotorForces = mixRotorForces(collectiveThrust, moments, params)

rotorXY = params.vehicle.rotorPositions(1:2, :);
mixingMatrix = [ ...
    ones(1, 4); ...
    rotorXY(2, :); ...
    -rotorXY(1, :); ...
    params.vehicle.spinDirections * params.vehicle.yawMomentCoeff];

desiredVector = [collectiveThrust; moments(:)];
rotorForces = mixingMatrix \ desiredVector;
rotorForces = min(max(rotorForces, params.vehicle.minRotorThrust), params.vehicle.maxRotorThrust);

end

function moments = rotorMoments(rotorForces, params)

moments = zeros(3, 1);
for idx = 1:4
    arm = params.vehicle.rotorPositions(:, idx);
    thrustVec = [0.0; 0.0; rotorForces(idx)];
    moments = moments + cross(arm, thrustVec);
end

moments(3) = moments(3) + params.vehicle.yawMomentCoeff * ...
    dot(params.vehicle.spinDirections, rotorForces);

end

function value = clampScalar(value, lowerBound, upperBound)

value = min(max(value, lowerBound), upperBound);

end

function vec = clampVector(vec, maxMagnitude)

magnitude = norm(vec);
if magnitude > maxMagnitude
    vec = vec * (maxMagnitude / magnitude);
end

end
