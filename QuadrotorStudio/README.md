# Quadrotor Studio

Interactive MATLAB quadrotor project with:

- live 3D flight visualization
- manual target control from sliders and keyboard
- hover/position/yaw stabilization
- URDF drone model preview

## Run

Open MATLAB in this folder and run:

```matlab
cd('C:\Users\TEJAS\OneDrive\Documents\New project\QuadrotorStudio')
start_quadrotor_studio
```

To preview the imported drone model only:

```matlab
preview_quadrotor_urdf
```

## Controls

- `W / S`: move target forward/back
- `A / D`: move target left/right
- `R / F`: move target up/down
- `Q / E`: yaw target left/right
- `Space`: run/pause
- `H`: return to hover point

## Files

- `start_quadrotor_studio.m`: project entry point
- `preview_quadrotor_urdf.m`: URDF preview window
- `assets/quadrotor_drone.urdf`: drone model asset
- `src/QuadrotorStudioApp.m`: interactive simulator UI
- `src/quadrotorDefaultParams.m`: vehicle and scene tuning
- `src/quadrotorInitialState.m`: startup state
- `src/quadrotorControlStep.m`: control law
- `src/quadrotorDynamicsStep.m`: rigid-body dynamics update
