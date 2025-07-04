# Geometry Module - Spatial Binning Example

This example demonstrates spatial binning techniques using VSL's Geometry Module (gm).

## Overview

This example showcases spatial data organization and efficient spatial queries using:

- 2D and 3D spatial binning systems
- Point insertion and retrieval
- Neighbor finding algorithms
- Spatial indexing optimization

## Features Demonstrated

### 🔹 2D Spatial Binning

- Grid-based spatial partitioning
- Automatic bin size calculation
- Point-to-bin mapping
- Spatial organization for 2D data

### 🔹 3D Spatial Binning

- Volumetric space partitioning
- Multi-dimensional spatial indexing
- Point insertion with metadata
- 3D spatial queries

### 🔹 Neighbor Finding

- Efficient nearest neighbor search
- Range-based spatial queries
- Bin-to-bin traversal
- Spatial proximity analysis

### 🔹 Performance Optimization

- O(1) average case insertion
- O(log n) spatial queries
- Memory-efficient data structures
- Scalable spatial indexing

## Usage

```bash
v run main.v
```

## Mathematical Concepts

### Spatial Binning
- Grid discretization: bin = floor((point - min) / bin_size)
- Hash-based spatial indexing
- Uniform grid partitioning

### Neighbor Search
- Moore neighborhood (8-connected in 2D, 26-connected in 3D)
- Distance-based queries
- Spatial locality optimization

## Applications

- Collision detection in games
- Particle systems simulation
- Geographic information systems (GIS)
- Computer graphics optimization
- Scientific simulation acceleration
