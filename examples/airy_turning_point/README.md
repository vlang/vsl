# Airy turning-point example

The Airy equation `y'' = x y` has x = 0 as its turning point: solutions oscillate for
x < 0 and decay (Ai) or grow (Bi) for x > 0. This example checks the functions in
`vsl.fun` against an independent numerical solution of the equation.

## What it does

1. Integrates `y'' = x y` with classical RK4 (20 000 steps) from x = 3 back to x = -4,
   starting from the exact values of Ai and Bi at x = 3.
2. Compares the integrated Ai and Bi with `fun.airy` at every step.
3. Prints values at selected points and the Wronskian `Ai Bi' - Ai' Bi`, which is 1/pi.

## Run

From `~/.vmodules` (never from inside the vsl checkout):

```sh
v run vsl/examples/airy_turning_point/main.v
```

Expected output: maximum deviations near 1e-11 or better, and a Wronskian of 0.318309886184.
