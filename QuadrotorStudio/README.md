# Quadrotor Studio

MATLAB-based interactive quadrotor simulation environment with real-time 3D visualization, URDF-based drone rendering, and PID-assisted flight control.

![Quadrotor Studio Preview](quadrotor_studio_full.png)

## Overview

Quadrotor Studio is a compact robotics simulation project designed for interactive quadrotor experimentation without Simulink or Simscape. The project combines:

- real-time drone visualization in MATLAB
- URDF-based quadrotor model loading
- manual control through UI sliders and keyboard shortcuts
- PID-assisted altitude and position stabilization
- reusable controller and dynamics modules for future extension

## Features

- Live 3D flight viewport with trajectory trail
- Interactive target control for position and yaw
- URDF preview utility for standalone model inspection
- Modular MATLAB source files for dynamics, tuning, and control
- Lightweight setup suitable for coursework, demos, and prototyping

## Project Structure

```text
QuadrotorStudio/
|-- assets/
|   `-- quadrotor_drone.urdf
|-- src/
|   |-- QuadrotorStudioApp.m
|   |-- quadrotorControlStep.m
|   |-- quadrotorDefaultParams.m
|   |-- quadrotorDynamicsStep.m
|   |-- quadrotorInitialState.m
|   `-- quadrotorWrapToPi.m
|-- colored_quadrotor.urdf
|-- preview_quadrotor_urdf.m
|-- quadrotor_pid_live_script.m
`-- start_quadrotor_studio.m
```

## Requirements

- MATLAB R2023b or newer
- Robotics System Toolbox
- Control System Toolbox

## Quick Start

Open MATLAB and run:

```matlab
cd('path/to/quadrotor-studio/QuadrotorStudio')
start_quadrotor_studio
```

To run the PID altitude script directly:

```matlab
run('quadrotor_pid_live_script.m')
```

To preview the URDF model only:

```matlab
preview_quadrotor_urdf
```

## Controls

| Key | Action |
|-----|--------|
| `W` / `S` | Move target forward / backward |
| `A` / `D` | Move target left / right |
| `R` / `F` | Move target up / down |
| `Q` / `E` | Rotate target yaw |
| `Space` | Run / Pause the simulation |
| `H` | Return to hover position |

## Main Files

| File | Description |
|------|-------------|
| `start_quadrotor_studio.m` | Launches the full interactive simulator |
| `quadrotor_pid_live_script.m` | Runs the vertical PID-control demo |
| `preview_quadrotor_urdf.m` | Opens a URDF-only preview window |
| `src/QuadrotorStudioApp.m` | Main simulator UI and rendering logic |
| `src/quadrotorControlStep.m` | Implements the 6-DOF PID control law |
| `src/quadrotorDynamicsStep.m` | Updates the drone rigid-body state |
| `src/quadrotorDefaultParams.m` | Default physical parameters |
| `src/quadrotorInitialState.m` | Initial state vector |

## Notes

- The interactive simulator is intended for visualization and control prototyping.
- The vertical PID script is designed as a simple standalone example that can be shared easily.
- The repository includes preview images for documentation and presentation use.

## License

MIT License — see [LICENSE](../LICENSE) for details.
