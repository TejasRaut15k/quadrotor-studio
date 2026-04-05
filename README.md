# Quadrotor Studio

Interactive MATLAB quadrotor simulator with URDF visualization, PID control, and a real-time 3D flight interface.

![Quadrotor Studio Preview](QuadrotorStudio/quadrotor_studio_full.png)

## Overview

This repository contains a MATLAB-based quadrotor simulation project built for interactive control and visualization without Simulink or Simscape.

## Main Project

The full project lives in:

[`QuadrotorStudio/`](C:/Users/TEJAS/OneDrive/Documents/New%20project/QuadrotorStudio)

Key files:

- `QuadrotorStudio/start_quadrotor_studio.m`
- `QuadrotorStudio/quadrotor_pid_live_script.m`
- `QuadrotorStudio/colored_quadrotor.urdf`
- `QuadrotorStudio/README.md`

## Run

Open MATLAB and run:

```matlab
cd('C:\Users\TEJAS\OneDrive\Documents\New project\QuadrotorStudio')
start_quadrotor_studio
```

## Features

- URDF-based quadrotor model
- Real-time 3D visualization
- PID-controlled altitude demo
- Interactive slider-based throttle control
- Modular MATLAB source files for extension
