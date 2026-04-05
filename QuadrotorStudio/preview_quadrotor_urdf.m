function ax = preview_quadrotor_urdf()
%PREVIEW_QUADROTOR_URDF Show the quadrotor URDF model in a standalone figure.

projectRoot = fileparts(mfilename('fullpath'));
robotPath = fullfile(projectRoot, 'assets', 'quadrotor_drone.urdf');

drone = importrobot(robotPath);
cfg = homeConfiguration(drone);

for idx = 1:numel(cfg)
    switch cfg(idx).JointName
        case 'z_joint'
            cfg(idx).JointPosition = 0.12;
        otherwise
            cfg(idx).JointPosition = 0.0;
    end
end

fig = figure( ...
    'Name', 'Quadrotor URDF Preview', ...
    'Color', [0.08 0.09 0.11], ...
    'NumberTitle', 'off');

ax = axes('Parent', fig, 'Color', [0.08 0.09 0.11]);
show(drone, cfg, 'Parent', ax, 'Frames', 'off', 'Visuals', 'on');
axis(ax, 'equal');
grid(ax, 'on');
view(ax, 132, 20);
xlabel(ax, 'X');
ylabel(ax, 'Y');
zlabel(ax, 'Z');
title(ax, 'Imported Quadrotor Model');
camlight(ax, 'headlight');
lighting(ax, 'gouraud');

end
