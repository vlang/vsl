# easings_signal_shaping

Representative easing usage in signal processing.

This example builds an ADSR-like amplitude envelope and applies it to a
sinusoidal carrier. It compares several easing functions and reports
signal-quality metrics.

## What this demonstrates

- using easing curves as envelope generators
- impact of envelope shape on RMS and crest factor
- practical checkpoints to inspect transients (attack/decay/release)

## Run

```sh
v run examples/easings_signal_shaping/main.v
```

## Why this is representative

Easing functions are not just for UI movement. They are useful for:

- DSP envelope design
- synthetic data generation with controlled transitions
- simulation of smooth/nonlinear ramps in scientific pipelines
