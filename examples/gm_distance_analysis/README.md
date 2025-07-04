# Geometry Module - Distance Analysis Example

This example demonstrates comprehensive distance analysis techniques using VSL's Geometry Module (gm).

## Overview

This example showcases various distance calculation methods and geometric analysis including:

- Point-to-line distance calculations
- Triangle analysis and classification
- Sphere/circle containment testing
- Centroid calculations for point clouds

## Features Demonstrated

### 🔹 Point-to-Line Distance Analysis

- Perpendicular distance from points to lines
- Analysis of points at various positions relative to line segments
- Edge cases: points beyond line endpoints
- Precision testing with known geometric configurations

### 🔹 Triangle Analysis

- Side length calculations
- Perimeter computation
- Triangle type classification (right triangle detection)
- Pythagorean theorem verification

### 🔹 Sphere/Circle Analysis

- Distance-based containment testing
- Point classification (inside, outside, on surface)
- Radius-based spatial relationships
- 3D geometric boundary detection

### 🔹 Centroid Calculation

- Point cloud centroid computation
- Distance analysis from centroid
- Statistical geometric properties
- Center of mass calculations

## Usage

```bash
v run main.v
```

## Mathematical Concepts

### Point-to-Line Distance
- Perpendicular distance formula in 3D space
- Vector projection mathematics
- Cross product applications for distance calculation

### Triangle Analysis
- Euclidean distance: d = √((x₂-x₁)² + (y₂-y₁)² + (z₂-z₁)²)
- Pythagorean theorem: a² + b² = c² (for right triangles)
- Perimeter: P = a + b + c

### Sphere Containment
- Radial distance comparison: |P - C| vs r
- Classification based on distance thresholds
- Tolerance-based boundary detection

### Centroid Calculation
- Arithmetic mean: C = (Σpᵢ)/n
- Center of mass for uniform point distribution
- Geometric center computation

## Expected Output

The example provides detailed analysis including:

- Precise distance measurements for various point-line configurations
- Complete triangle analysis with side lengths and classification
- Sphere containment results with distance measurements
- Centroid coordinates and point-to-centroid distances

## Educational Value

Perfect for learning:

- Fundamental distance calculation techniques
- Geometric shape analysis and classification
- Spatial relationship detection
- Statistical geometry concepts
- Computational geometry fundamentals

## Applications

These techniques are essential for:

- Computer graphics and rendering
- Collision detection in games and simulations
- CAD software development
- Robotics path planning and obstacle avoidance
- Geospatial analysis and mapping
- Scientific visualization and data analysis
