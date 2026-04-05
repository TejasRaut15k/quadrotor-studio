%% Initialization
clc;

m = 1.25;
g = 9.81;
k = 0.12;
dt = 0.03;

targetHeight = 2.0;
maxIntegral = 8.0;
maxThrust = 25.0;
minThrust = 0.0;

Kp = 14.0;
Ki = 2.8;
Kd = 8.0;

height_closed = 0.0;
vel_closed = 0.0;

height_open = 0.0;
vel_open = 0.0;

eInt = 0.0;
ePrev = 0.0;

t = 0.0;
time_log = [];
height_closed_log = [];
height_open_log = [];
throttle_log = [];

%% Load URDF Model
drone = importrobot("colored_quadrotor.urdf");
drone.DataFormat = "row";
config = homeConfiguration(drone);

show(drone);

%% UI Setup (Throttle Slider)
ui = uifigure( ...
    'Name', 'Quadrotor PID Altitude Control', ...
    'Position', [100 100 1100 650], ...
    'Color', [0.08 0.09 0.11]);

uilabel(ui, ...
    'Text', 'Base Throttle', ...
    'Position', [760 560 160 22], ...
    'FontSize', 16, ...
    'FontWeight', 'bold', ...
    'FontColor', [1 1 1]);

throttleLabel = uilabel(ui, ...
    'Text', '50.0', ...
    'Position', [930 560 120 22], ...
    'FontSize', 16, ...
    'FontWeight', 'bold', ...
    'FontColor', [0.2 0.8 1.0]);

sld = uislider(ui, ...
    'Position', [760 535 280 3], ...
    'Limits', [0 100], ...
    'Value', 50);

sld.ValueChangedFcn = @(src,evt) set(throttleLabel,'Text',sprintf('%.1f',src.Value));
sld.ValueChangingFcn = @(src,evt) set(throttleLabel,'Text',sprintf('%.1f',evt.Value));

targetLabel = uilabel(ui, ...
    'Text', sprintf('Target Height: %.2f m', targetHeight), ...
    'Position', [760 495 220 22], ...
    'FontSize', 14, ...
    'FontColor', [1 0.8 0.2]);

heightLabel = uilabel(ui, ...
    'Text', 'Current Height: 0.00 m', ...
    'Position', [760 460 260 22], ...
    'FontSize', 14, ...
    'FontColor', [0.6 1.0 0.7]);

thrustLabel = uilabel(ui, ...
    'Text', 'Closed-Loop Thrust: 0.00 N', ...
    'Position', [760 425 260 22], ...
    'FontSize', 14, ...
    'FontColor', [1.0 0.6 0.2]);

%% Visualization Setup
ax = axes( ...
    'Parent', ui, ...
    'Units', 'pixels', ...
    'Position', [30 40 680 570], ...
    'Color', [0.10 0.10 0.12], ...
    'XColor', [1 1 1], ...
    'YColor', [1 1 1], ...
    'ZColor', [1 1 1]);

grid(ax, 'on');
axis(ax, [-1 1 -1 1 0 5]);
view(ax, 135, 20);
xlabel(ax, 'X');
ylabel(ax, 'Y');
zlabel(ax, 'Z');
title(ax, 'PID-Controlled Quadrotor', 'Color', [1 1 1]);

hold(ax, 'on');
plot3(ax, [-0.8 0.8], [0 0], [targetHeight targetHeight], '--', 'Color', [1 0.8 0.2], 'LineWidth', 1.5);
plot3(ax, [0 0], [0 0], [0 5], ':', 'Color', [0.3 0.7 1.0], 'LineWidth', 1.0);

T = trvec2tform([0 0 height_closed]);
config(3) = height_closed;
show(drone, config, ...
    'Parent', ax, ...
    'PreservePlot', false, ...
    'Frames', 'off');

drawnow;

%% Simulation Loop
while true
    if ~isvalid(sld)
        break
    end

    try
        throttle = sld.Value;
    catch
        break
    end

    e = targetHeight - height_closed;
    eInt = eInt + e * dt;
    eInt = min(max(eInt, -maxIntegral), maxIntegral);
    eDer = (e - ePrev) / dt;

    pidOutput = Kp * e + Ki * eInt + Kd * eDer;

    thrust_open = k * throttle;
    thrust_closed = k * throttle + pidOutput;
    thrust_closed = min(max(thrust_closed, minThrust), maxThrust);

    zdd_open = (thrust_open - m * g) / m;
    zdd_closed = (thrust_closed - m * g) / m;

    vel_open = vel_open + zdd_open * dt;
    height_open = height_open + vel_open * dt;

    vel_closed = vel_closed + zdd_closed * dt;
    height_closed = height_closed + vel_closed * dt;

    if height_open < 0
        height_open = 0;
        vel_open = 0;
    end

    if height_closed < 0
        height_closed = 0;
        vel_closed = 0;
    end

    time_log(end+1,1) = t; %#ok<SAGROW>
    height_open_log(end+1,1) = height_open; %#ok<SAGROW>
    height_closed_log(end+1,1) = height_closed; %#ok<SAGROW>
    throttle_log(end+1,1) = throttle; %#ok<SAGROW>

    if isvalid(heightLabel)
        heightLabel.Text = sprintf('Current Height: %.2f m', height_closed);
    end
    if isvalid(thrustLabel)
        thrustLabel.Text = sprintf('Closed-Loop Thrust: %.2f N', thrust_closed);
    end
    if isvalid(throttleLabel)
        throttleLabel.Text = sprintf('%.1f', throttle);
    end
    if isvalid(targetLabel)
        targetLabel.Text = sprintf('Target Height: %.2f m', targetHeight);
    end

    if isvalid(ax)
        T = trvec2tform([0 0 height_closed]); %#ok<NASGU>
        config(:) = 0;
        config(3) = height_closed;
        show(drone, config, ...
            'Parent', ax, ...
            'PreservePlot', false, ...
            'Frames', 'off');
    else
        break
    end

    drawnow;
    pause(dt);

    ePrev = e;
    t = t + dt;
end

%% Results Plot
figure('Color', 'w');
h1 = plot(time_log, height_open_log, 'r', 'LineWidth', 1.8); hold on;
h2 = plot(time_log, height_closed_log, 'b', 'LineWidth', 2.0);
h3 = plot(time_log, targetHeight * ones(size(time_log)), 'k--', 'LineWidth', 1.5);
grid on;
xlabel('Time (s)');
ylabel('Height (m)');
legend([h1 h2 h3], 'Open-Loop', 'PID-Controlled', 'Target Height', 'Location', 'best');
title('Quadrotor Altitude Response');
