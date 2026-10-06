# Geometry Module - Basic Geometry Example

This example demonstrates fundamental geometric operations using VSL's Geometry Module (gm).

## Overview

The example showcases:
- Creating and working with 3D points
- Distance calculations between points
- Working with segments and vectors
- Vector mathematics (dot product, norms, angles)
- Vector arithmetic operations
- Point displacement and cloning
- Segment scaling operations

## Features Demonstrated

### 🔹 3D Points and Distances
- Creating points in 3D space
- Calculating Euclidean distances between points
- Working with special geometric configurations (unit cube, 3-4-5 triangle)

### 🔹 Segments and Vectors
- Creating line segments between points
- Converting segments to vectors
- Vector operations and calculations

### 🔹 Vector Mathematics
- Dot product calculations
- Vector norm computation
- Angle calculations between vectors using dot product formula

### 🔹 Vector Arithmetic
- Vector addition and scaling
- Linear combinations of vectors
- Vector scaling operations

### 🔹 Point Operations
- Point displacement in 3D space
- Point cloning and manipulation

### 🔹 Segment Operations
- Segment scaling (shortening/lengthening)
- Segment properties and transformations

## Usage

```bash
v run vsl/examples/gm_basic_geometry/main.v
```

## Expected Output

The example produces detailed output showing:
- Point coordinates and relationships
- Distance calculations with mathematical verification
- Vector components and properties
- Angle measurements in degrees
- Results of various geometric operations

## Educational Value

This example is perfect for:
- Learning basic 3D geometry concepts
- Understanding vector mathematics
- Exploring geometric relationships
- Getting familiar with VSL's geometry module API

## Mathematical Concepts

- Euclidean distance formula: √((x₂-x₁)² + (y₂-y₁)² + (z₂-z₁)²)
- Dot product: a·b = |a||b|cos(θ)
- Vector norm: |v| = √(x² + y² + z²)
- Angle between vectors: θ = arccos((a·b)/(|a||b|))
