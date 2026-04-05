function app = start_quadrotor_studio(varargin)
%START_QUADROTOR_STUDIO Launch the interactive quadrotor simulator.

projectRoot = fileparts(mfilename('fullpath'));
srcDir = fullfile(projectRoot, 'src');
addpath(srcDir);

parser = inputParser;
parser.addParameter('Visible', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('AutoStart', true, @(x) islogical(x) || isnumeric(x));
parser.parse(varargin{:});

options.Visible = logical(parser.Results.Visible);
options.AutoStart = logical(parser.Results.AutoStart);

app = QuadrotorStudioApp(projectRoot, options);
assignin('base', 'quadrotorStudioApp', app);

end
