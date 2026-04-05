function app = QuadrotorStudioApp(projectRoot, options)
%QUADROTORSTUDIOAPP Interactive quadrotor simulator UI.

params = quadrotorDefaultParams();
state = quadrotorInitialState(params);
target.position = params.controller.homePosition;
target.yaw = params.controller.homeYaw;
trail = state.position.';
isRunning = false;
isClosing = false;

if options.Visible
    figVisible = 'on';
else
    figVisible = 'off';
end

fig = figure( ...
    'Name', 'Quadrotor Studio | Flight Lab', ...
    'Color', [0.06 0.07 0.10], ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'Renderer', 'opengl', ...
    'Visible', figVisible, ...
    'Units', 'normalized', ...
    'Position', [0.05 0.06 0.90 0.86], ...
    'WindowKeyPressFcn', @onKeyPress, ...
    'CloseRequestFcn', @onCloseRequested);

uicontrol('Parent', fig, 'Style', 'text', ...
    'String', 'QUADROTOR STUDIO  |  INTERACTIVE FLIGHT LAB', ...
    'Units', 'normalized', 'Position', [0.03 0.93 0.62 0.05], ...
    'BackgroundColor', [0.06 0.07 0.10], 'ForegroundColor', [1.00 0.72 0.18], ...
    'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');

ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.04 0.08 0.64 0.82], ...
    'Color', [0.08 0.09 0.11], 'XColor', [0.60 0.84 0.62], 'YColor', [0.60 0.84 0.62], ...
    'ZColor', [0.60 0.84 0.62], 'GridColor', [0.16 0.38 0.18], 'MinorGridColor', [0.10 0.26 0.12], ...
    'LineWidth', 1.0);
panel = uipanel('Parent', fig, 'Title', 'Mission Control', 'Units', 'normalized', ...
    'Position', [0.72 0.06 0.25 0.88], 'BackgroundColor', [0.10 0.11 0.15], ...
    'ForegroundColor', [0.95 0.82 0.45], 'FontWeight', 'bold');

runButton = uicontrol('Parent', panel, 'Style', 'togglebutton', 'String', 'Run', ...
    'Units', 'normalized', 'Position', [0.06 0.92 0.26 0.05], 'FontWeight', 'bold', ...
    'BackgroundColor', [0.20 0.44 0.22], 'ForegroundColor', [1.0 1.0 1.0], 'Callback', @onRunToggle);
uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Reset Drone', ...
    'Units', 'normalized', 'Position', [0.36 0.92 0.26 0.05], 'FontWeight', 'bold', ...
    'BackgroundColor', [0.22 0.24 0.32], 'ForegroundColor', [1.0 1.0 1.0], 'Callback', @onReset);
uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Preview URDF', ...
    'Units', 'normalized', 'Position', [0.66 0.92 0.28 0.05], 'FontWeight', 'bold', ...
    'BackgroundColor', [0.46 0.25 0.10], 'ForegroundColor', [1.0 1.0 1.0], 'Callback', @onPreview);

statusText = uicontrol('Parent', panel, 'Style', 'text', 'String', 'Status: Ready', ...
    'Units', 'normalized', 'Position', [0.06 0.87 0.88 0.03], 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.10 0.11 0.15], 'ForegroundColor', [0.70 0.90 0.72], 'FontWeight', 'bold');

sliders.x = makeSlider('Target X (m)', -3.0, 3.0, target.position(1), 0.76, 'x');
sliders.y = makeSlider('Target Y (m)', -3.0, 3.0, target.position(2), 0.66, 'y');
sliders.z = makeSlider('Target Z (m)',  0.2, 7.5, target.position(3), 0.56, 'z');
sliders.yaw = makeSlider('Target Yaw (deg)', -180.0, 180.0, rad2deg(target.yaw), 0.46, 'yaw');

telemetry.position = makeTelemetry(0.34);
telemetry.velocity = makeTelemetry(0.29);
telemetry.attitude = makeTelemetry(0.24);
telemetry.rotors = makeTelemetry(0.19);
telemetry.mode = makeTelemetry(0.14);

uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Return Home', ...
    'Units', 'normalized', 'Position', [0.06 0.08 0.40 0.05], 'FontWeight', 'bold', ...
    'BackgroundColor', [0.24 0.22 0.36], 'ForegroundColor', [1.0 1.0 1.0], 'Callback', @onHome);
uicontrol('Parent', panel, 'Style', 'text', ...
    'String', sprintf(['Keyboard\n', 'W/S  forward/back\n', 'A/D  left/right\n', 'R/F  up/down\n', ...
    'Q/E  yaw\n', 'Space  run/pause\n', 'H  home']), ...
    'Units', 'normalized', 'Position', [0.52 0.04 0.42 0.11], 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.10 0.11 0.15], 'ForegroundColor', [0.86 0.88 0.92], 'FontSize', 9);

hold(ax, 'on'); axis(ax, 'equal');
xlim(ax, params.scene.xLim); ylim(ax, params.scene.yLim); zlim(ax, params.scene.zLim);
xlabel(ax, 'X (m)'); ylabel(ax, 'Y (m)'); zlabel(ax, 'Z (m)');
title(ax, '3D Flight Viewport', 'Color', [1.0 0.72 0.18], 'FontWeight', 'bold');
view(ax, 38, 24); grid(ax, 'on'); ax.XMinorGrid = 'on'; ax.YMinorGrid = 'on'; ax.ZMinorGrid = 'on';
[gridX, gridY] = meshgrid(-3.5:0.2:3.5, -3.5:0.2:3.5);
surf(ax, gridX, gridY, zeros(size(gridX)), 'FaceColor', [0.10 0.48 0.12], ...
    'EdgeColor', [0.18 0.54 0.18], 'FaceAlpha', 0.92, 'EdgeAlpha', 0.35);
theta = linspace(0, 2 * pi, 160);
for radius = params.scene.padRadii
    plot3(ax, radius * cos(theta), radius * sin(theta), zeros(size(theta)), '--', ...
        'Color', [1.0 0.74 0.12], 'LineWidth', 1.1);
end

targetMarker = plot3(ax, 0, 0, 0, 'o', 'MarkerSize', 8, ...
    'MarkerFaceColor', [0.24 0.76 1.0], 'MarkerEdgeColor', [0.95 0.98 1.0]);
verticalGuide = plot3(ax, [0 0], [0 0], [0 0], '--', 'Color', [0.18 0.70 1.0], 'LineWidth', 1.2);
targetRings = gobjects(5, 1);
for i = 1:5
    targetRings(i) = plot3(ax, 0, 0, 0, '--', 'Color', [0.18 0.52 1.0], 'LineWidth', 0.9);
end
trailLine = plot3(ax, state.position(1), state.position(2), state.position(3), '-', ...
    'Color', [0.18 0.66 1.0], 'LineWidth', 1.7);

droneGroup = hgtransform('Parent', ax);
[rotorRings, rotorDiscs] = buildDroneModel(ax, droneGroup, params);
camlight(ax, 'headlight'); camlight(ax, 'right'); lighting(ax, 'gouraud');

timerObj = timer('ExecutionMode', 'fixedSpacing', 'Period', params.sim.dt, ...
    'BusyMode', 'drop', 'TimerFcn', @onTick);

syncControlsFromTarget();
updateTargetGraphics();
renderScene();
if options.AutoStart
    startSimulation();
end

app = struct('Figure', fig, 'Timer', timerObj, 'ProjectRoot', projectRoot, 'close', @closeApp);

    function slider = makeSlider(labelText, minVal, maxVal, initVal, yPos, tag)
        uicontrol('Parent', panel, 'Style', 'text', 'String', labelText, 'Units', 'normalized', ...
            'Position', [0.06 yPos + 0.045 0.55 0.03], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.10 0.11 0.15], 'ForegroundColor', [0.95 0.96 0.98], 'FontWeight', 'bold');
        slider.ValueLabel = uicontrol('Parent', panel, 'Style', 'text', 'String', '', ...
            'Units', 'normalized', 'Position', [0.64 yPos + 0.045 0.28 0.03], ...
            'HorizontalAlignment', 'right', 'BackgroundColor', [0.10 0.11 0.15], ...
            'ForegroundColor', [0.70 0.88 1.00], 'FontName', 'Consolas');
        slider.Control = uicontrol('Parent', panel, 'Style', 'slider', 'Min', minVal, 'Max', maxVal, ...
            'Value', initVal, 'Units', 'normalized', 'Position', [0.06 yPos 0.86 0.04], ...
            'BackgroundColor', [0.12 0.13 0.18], 'Callback', @(src, ~) onSlider(tag, src.Value));
    end

    function label = makeTelemetry(yPos)
        label = uicontrol('Parent', panel, 'Style', 'text', 'String', '', 'Units', 'normalized', ...
            'Position', [0.06 yPos 0.88 0.035], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.10 0.11 0.15], 'ForegroundColor', [0.86 0.88 0.92], ...
            'FontName', 'Consolas', 'FontSize', 10);
    end

    function onRunToggle(src, ~)
        if logical(src.Value), startSimulation(); else, pauseSimulation(); end
    end

    function startSimulation()
        if ~isRunning
            start(timerObj);
            isRunning = true;
            runButton.Value = 1; runButton.String = 'Pause';
            statusText.String = 'Status: Simulation live';
        end
    end

    function pauseSimulation()
        if isRunning
            stop(timerObj);
            isRunning = false;
            runButton.Value = 0; runButton.String = 'Run';
            statusText.String = 'Status: Paused';
        end
    end

    function onTick(~, ~)
        dt = params.sim.dt / params.sim.substeps;
        for k = 1:params.sim.substeps
            command = quadrotorControlStep(state, target, params);
            state = quadrotorDynamicsStep(state, command, params, dt);
        end
        trail(end + 1, :) = state.position.'; %#ok<AGROW>
        if size(trail, 1) > params.sim.maxHistory, trail(1, :) = []; end
        renderScene();
    end

    function renderScene()
        T = eye(4);
        T(1:3, 1:3) = eulerToRotation(state.euler);
        T(1:3, 4) = state.position;
        droneGroup.Matrix = T;
        trailLine.XData = trail(:, 1); trailLine.YData = trail(:, 2); trailLine.ZData = trail(:, 3);
        updateTargetGraphics();
        updateRotorGlow();
        updateTelemetry();
        drawnow limitrate nocallbacks;
    end

    function updateTargetGraphics()
        ringHeights = linspace(0.35, max(target.position(3), 0.35), numel(targetRings));
        ringRadii = linspace(0.18, 0.80, numel(targetRings));
        targetMarker.XData = target.position(1); targetMarker.YData = target.position(2); targetMarker.ZData = target.position(3);
        verticalGuide.XData = [target.position(1) target.position(1)];
        verticalGuide.YData = [target.position(2) target.position(2)];
        verticalGuide.ZData = [0.0 target.position(3)];
        for j = 1:numel(targetRings)
            targetRings(j).XData = target.position(1) + ringRadii(j) * cos(theta);
            targetRings(j).YData = target.position(2) + ringRadii(j) * sin(theta);
            targetRings(j).ZData = ringHeights(j) * ones(size(theta));
        end
    end

    function updateRotorGlow()
        thrustNorm = state.rotorThrusts / params.vehicle.maxRotorThrust;
        for j = 1:numel(rotorRings)
            cold = [0.72 0.72 0.75]; hot = [1.00 0.58 0.12];
            c = (1 - thrustNorm(j)) * cold + thrustNorm(j) * hot;
            rotorRings(j).Color = c;
            rotorRings(j).LineWidth = 1.2 + 1.8 * thrustNorm(j);
            rotorDiscs(j).FaceAlpha = 0.05 + 0.18 * thrustNorm(j);
        end
    end

    function updateTelemetry()
        telemetry.position.String = sprintf('Position:  [%.2f  %.2f  %.2f] m', state.position);
        telemetry.velocity.String = sprintf('Velocity:  [%.2f  %.2f  %.2f] m/s', state.velocity);
        telemetry.attitude.String = sprintf('Attitude:  roll %.1f  pitch %.1f  yaw %.1f deg', rad2deg(state.euler));
        telemetry.rotors.String = sprintf('Rotors:  [%.2f  %.2f  %.2f  %.2f] N', state.rotorThrusts);
        if isRunning, modeString = 'Mode: Assisted position hold'; else, modeString = 'Mode: Paused hold'; end
        telemetry.mode.String = modeString;
    end

    function onSlider(tag, value)
        switch tag
            case 'x', target.position(1) = value;
            case 'y', target.position(2) = value;
            case 'z', target.position(3) = value;
            case 'yaw', target.yaw = deg2rad(value);
        end
        updateSliderText(tag);
        updateTargetGraphics();
    end

    function syncControlsFromTarget()
        sliders.x.Control.Value = target.position(1);
        sliders.y.Control.Value = target.position(2);
        sliders.z.Control.Value = target.position(3);
        sliders.yaw.Control.Value = rad2deg(target.yaw);
        updateSliderText('x'); updateSliderText('y'); updateSliderText('z'); updateSliderText('yaw');
    end

    function updateSliderText(tag)
        value = sliders.(tag).Control.Value;
        if strcmp(tag, 'yaw')
            sliders.(tag).ValueLabel.String = sprintf('%6.1f deg', value);
        else
            sliders.(tag).ValueLabel.String = sprintf('%6.2f m', value);
        end
    end

    function onReset(~, ~)
        state = quadrotorInitialState(params);
        trail = state.position.';
        statusText.String = 'Status: Drone reset';
        renderScene();
    end

    function onHome(~, ~)
        target.position = params.controller.homePosition;
        target.yaw = params.controller.homeYaw;
        clampTarget();
        syncControlsFromTarget();
        statusText.String = 'Status: Returning to home target';
        updateTargetGraphics();
    end

    function onPreview(~, ~)
        preview_quadrotor_urdf();
        statusText.String = 'Status: URDF preview opened';
    end

    function onKeyPress(~, evt)
        switch lower(evt.Key)
            case 'w', target.position(1) = target.position(1) + params.scene.keyStepXY;
            case 's', target.position(1) = target.position(1) - params.scene.keyStepXY;
            case 'a', target.position(2) = target.position(2) + params.scene.keyStepXY;
            case 'd', target.position(2) = target.position(2) - params.scene.keyStepXY;
            case 'r', target.position(3) = target.position(3) + params.scene.keyStepZ;
            case 'f', target.position(3) = target.position(3) - params.scene.keyStepZ;
            case 'q', target.yaw = target.yaw + params.scene.keyStepYaw;
            case 'e', target.yaw = target.yaw - params.scene.keyStepYaw;
            case 'space', if isRunning, pauseSimulation(); else, startSimulation(); end
            case 'h', onHome();
            otherwise, return;
        end
        clampTarget();
        syncControlsFromTarget();
        updateTargetGraphics();
    end

    function clampTarget()
        target.position(1) = min(max(target.position(1), params.scene.xLim(1) + 0.2), params.scene.xLim(2) - 0.2);
        target.position(2) = min(max(target.position(2), params.scene.yLim(1) + 0.2), params.scene.yLim(2) - 0.2);
        target.position(3) = min(max(target.position(3), 0.2), params.scene.zLim(2) - 0.2);
        target.yaw = quadrotorWrapToPi(target.yaw);
    end

    function onCloseRequested(~, ~)
        closeApp();
        if isgraphics(fig), delete(fig); end
    end

    function closeApp(varargin) %#ok<INUSD>
        if isClosing, return; end
        isClosing = true;
        if ~isempty(timerObj) && isvalid(timerObj)
            stop(timerObj);
            delete(timerObj);
        end
        isRunning = false;
    end
end

function [rotorRings, rotorDiscs] = buildDroneModel(ax, parentGroup, params)
bodyVerts = [-0.09 -0.06 -0.02; 0.09 -0.06 -0.02; 0.09 0.06 -0.02; -0.09 0.06 -0.02; ...
             -0.09 -0.06 0.02;  0.09 -0.06 0.02;  0.09 0.06 0.02;  -0.09 0.06 0.02];
bodyFaces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
patch('Parent', parentGroup, 'Vertices', bodyVerts, 'Faces', bodyFaces, ...
    'FaceColor', [0.80 0.12 0.12], 'EdgeColor', [0.14 0.14 0.18], 'FaceLighting', 'gouraud');
drawTube(parentGroup, [0 0 0], [ params.vehicle.armLength 0 0], 0.012, [0.22 0.22 0.24]);
drawTube(parentGroup, [0 0 0], [-params.vehicle.armLength 0 0], 0.012, [0.22 0.22 0.24]);
drawTube(parentGroup, [0 0 0], [0 -params.vehicle.armLength 0], 0.012, [0.22 0.22 0.24]);
drawTube(parentGroup, [0 0 0], [0  params.vehicle.armLength 0], 0.012, [0.22 0.22 0.24]);
drawTube(parentGroup, [0 0 -0.02], [0 0 0.08], 0.018, [0.20 0.20 0.22]);

theta = linspace(0, 2 * pi, 120);
rotorRings = gobjects(4, 1);
rotorDiscs = gobjects(4, 1);
rotorColors = [0.88 0.88 0.92; 0.88 0.88 0.92; 0.88 0.26 0.74; 0.88 0.26 0.74];
for i = 1:4
    center = params.vehicle.rotorPositions(:, i);
    drawTube(parentGroup, center + [0; 0; -0.02], center + [0; 0; 0.035], 0.010, [0.35 0.35 0.40]);
    rotorDiscs(i) = patch('Parent', parentGroup, 'XData', center(1) + 0.085 * cos(theta), ...
        'YData', center(2) + 0.085 * sin(theta), 'ZData', center(3) + 0.015 * ones(size(theta)), ...
        'FaceColor', rotorColors(i, :), 'EdgeColor', 'none', 'FaceAlpha', 0.10);
    rotorRings(i) = line('Parent', parentGroup, 'XData', center(1) + 0.085 * cos(theta), ...
        'YData', center(2) + 0.085 * sin(theta), 'ZData', center(3) + 0.015 * ones(size(theta)), ...
        'Color', rotorColors(i, :), 'LineWidth', 1.4);
end
camlight(ax, 'headlight');
end

function drawTube(parentGroup, p1, p2, radius, colorValue)
[xc, yc, zc] = cylinder(radius, 24);
zc = zc * norm(p2 - p1);
pts = [xc(:)'; yc(:)'; zc(:)'];
R = alignZAxisToVector(p2 - p1);
pts = R * pts + p1(:);
surf('Parent', parentGroup, 'XData', reshape(pts(1, :), size(xc)), ...
    'YData', reshape(pts(2, :), size(yc)), 'ZData', reshape(pts(3, :), size(zc)), ...
    'FaceColor', colorValue, 'EdgeColor', 'none', 'FaceLighting', 'gouraud');
end

function R = alignZAxisToVector(v)
dir = v(:) / norm(v);
zAxis = [0; 0; 1];
if all(abs(dir - zAxis) < 1e-10), R = eye(3); return; end
if all(abs(dir + zAxis) < 1e-10), R = diag([1 -1 -1]); return; end
axisValue = cross(zAxis, dir);
axisValue = axisValue / norm(axisValue);
angleValue = acos(dot(zAxis, dir));
R = axisAngleToMatrix(axisValue, angleValue);
end

function R = axisAngleToMatrix(axisValue, angleValue)
x = axisValue(1); y = axisValue(2); z = axisValue(3);
c = cos(angleValue); s = sin(angleValue); oneMinusC = 1 - c;
R = [c + x * x * oneMinusC, x * y * oneMinusC - z * s, x * z * oneMinusC + y * s; ...
     y * x * oneMinusC + z * s, c + y * y * oneMinusC, y * z * oneMinusC - x * s; ...
     z * x * oneMinusC - y * s, z * y * oneMinusC + x * s, c + z * z * oneMinusC];
end

function R = eulerToRotation(euler)
phi = euler(1); theta = euler(2); psi = euler(3);
cphi = cos(phi); sphi = sin(phi); cth = cos(theta); sth = sin(theta); cpsi = cos(psi); spsi = sin(psi);
R = [cpsi * cth, cpsi * sth * sphi - spsi * cphi, cpsi * sth * cphi + spsi * sphi; ...
     spsi * cth, spsi * sth * sphi + cpsi * cphi, spsi * sth * cphi - cpsi * sphi; ...
     -sth,       cth * sphi,                          cth * cphi];
end
