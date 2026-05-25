# quaternion_camera_look

Representative quaternion usage for a **camera look pipeline**.

## Scenario

This example models a common game-camera workflow:

- apply yaw and pitch via axis-angle quaternions
- compose orientation while preserving numerical stability
- rotate forward basis vector into world-space look direction
- blend toward lock-on target orientation with `slerp`

## Run

```sh
v run examples/quaternion_camera_look/main.v
```

## Why this is representative

- mirrors real gameplay camera control and targeting flows
- demonstrates order-sensitive rotation composition
- includes runtime sanity checks (unit quaternion, unit direction)
