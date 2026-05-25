# easings_motion_profiles

Representative easing analysis for motion design and simulation.

This example compares multiple easing curves in the same **0 → 100** movement
scenario across **121 frames**, then reports practical kinematic indicators.

## What this demonstrates

- how different easing families shape trajectory over time
- monotonic vs non-monotonic behavior (important for physical plausibility)
- where peak velocity and acceleration happen for each easing
- keyframe sampling for animation tuning (`0, 10, 25, 50, 75, 90, 100%`)

## Run

```sh
v run examples/easings_motion_profiles/main.v
```

## Why this is representative

Instead of only plotting points, this example maps easing outputs to
motion-profile metrics that appear in real tasks:

- UI animation timing decisions
- robotics/actuator interpolation sanity checks
- game movement polish and responsiveness tuning
