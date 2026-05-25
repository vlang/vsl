# quaternion_turret_tracking

Representative quaternion usage for **turret/camera tracking**.

## Scenario

The turret has a current orientation and a desired target orientation.
We interpolate with quaternions and inspect angular error reduction.

## Run

```sh
v run examples/quaternion_turret_tracking/main.v
```

## What this demonstrates

- smooth orientation transition with `slerp`
- error monitoring via `rotation_intrinsic_distance`
- practical comparison of `lerp`, `nlerp`, and `slerp` at mid-trajectory

## Why this is representative

- directly maps to lock-on / aim-tracking behavior in games
- uses metrics that gameplay/engine code can consume
- highlights interpolation tradeoffs relevant for performance vs fidelity
