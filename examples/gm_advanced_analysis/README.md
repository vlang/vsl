# Geometry Module - Advanced Analysis Example

This example demonstrates advanced geometric analysis techniques using VSL's Geometry Module (gm).

## Overview

This example showcases sophisticated geometric operations including:

- Point cloud analysis and clustering
- Bounding box calculations and containment testing
- Line geometry and distance analysis
- Point-line alignment detection
- Vector field analysis and visualization

## Features Demonstrated

### 🔹 Point Cloud Analysis

- Multi-cluster point generation
- Distance-based clustering analysis
- Cluster center calculations
- Statistical analysis of point distributions

### 🔹 Bounding Box Analysis

- Automatic bounding box calculation for point clouds
- Volume computation
- Point containment testing
- Spatial boundary detection

### 🔹 Line Geometry Analysis

- Multiple line definitions in 3D space
- Point-to-line distance calculations
- Geometric relationship analysis
- Line intersection properties

### 🔹 Point-Line Alignment Detection

- Precise point-on-line testing
- Tolerance-based alignment detection
- Distance thresholding
- Geometric validation

### 🔹 Vector Field Analysis

- Radial vector field generation
- Vector normalization and magnitude calculation
- Angular analysis from horizontal
- Field divergence calculations

## Usage

```bash
v run main.v
```

## Mathematical Concepts

### Point Cloud Analysis
- Euclidean clustering using distance thresholds
- Centroid-based cluster analysis
- Statistical measures (mean distances, point counts)

### Bounding Box
- Axis-aligned bounding box (AABB) computation
- Volume calculation: V = (xmax - xmin) × (ymax - ymin) × (zmax - zmin)
- Point-in-box testing with tolerance

### Vector Fields
- Radial field generation: r⃗ = (x - cx, y - cy, z - cz)
- Vector normalization: û = r⃗ / |r⃗|
- Angular calculations: θ = atan2(vy, vx)
- Divergence approximation: ∇ · F ≈ 1/r for radial fields

## Expected Output

The example produces comprehensive analysis including:

- Cluster membership and distances
- Bounding box dimensions and volume
- Point containment results
- Line-point distance measurements
- Vector field properties and statistics

## Educational Value

Perfect for learning:

- Advanced geometric analysis techniques
- Point cloud processing fundamentals
- Spatial data structures and algorithms
- Vector field theory applications
- Computational geometry concepts

## Applications

These techniques are useful for:

- CAD/CAM software development
- Computer graphics and game development
- Robotics path planning
- Scientific visualization
- Geospatial analysis
- Machine learning feature extraction
