# VSL Geometry Module Examples 🔬📐

This directory contains comprehensive examples demonstrating the capabilities of the VSL Geometry Module (`vsl.gm`). The module provides fundamental geometric algorithms and data structures for 3D computational geometry.

## 🚀 Quick Start

```sh
# Run any example
v run basic_geometry.v
v run distance_analysis.v
v run spatial_binning.v
v run trajectory_simulation.v
v run advanced_analysis.v
v run geometry_playground.v
```

## 📚 Examples Overview

### 1. `basic_geometry.v` - Fundamentals
**🎯 Focus**: Basic 3D geometry operations

**Key Concepts**:
- Creating and manipulating 3D points
- Segment operations and measurements
- Vector mathematics (dot product, norms, addition)
- Point displacement and cloning
- Angle calculations between vectors

**What You'll Learn**:
- Core `Point` and `Segment` structures
- Distance calculations in 3D space
- Vector operations and transformations
- Basic geometric relationships

### 2. `distance_analysis.v` - Spatial Relationships
**🎯 Focus**: Distance calculations and geometric analysis

**Key Concepts**:
- Point-to-line distance calculations
- Triangle analysis and classification
- Circle/sphere containment testing
- Centroid calculations for point clouds
- Shape property analysis

**What You'll Learn**:
- Advanced distance measurement techniques
- Triangle type detection (right, equilateral, etc.)
- Spatial relationship testing
- Statistical analysis of point sets

### 3. `spatial_binning.v` - Efficient Spatial Indexing
**🎯 Focus**: Fast spatial search and organization

**Key Concepts**:
- 2D and 3D spatial binning systems
- Particle system organization
- Spatial query optimization
- Neighbor search algorithms
- Performance analysis

**What You'll Learn**:
- Spatial data structures for fast queries
- Bin-based particle simulation techniques
- Performance optimization for large datasets
- Spatial indexing best practices

**Use Cases**: Particle physics, collision detection, spatial databases

### 4. `trajectory_simulation.v` - Motion Analysis
**🎯 Focus**: 3D trajectory and motion simulation

**Key Concepts**:
- Projectile motion with gravity
- Circular and elliptical orbits
- 3D spiral trajectories (helixes)
- Path optimization and comparison
- Spherical coordinate conversions

**What You'll Learn**:
- Physics-based motion simulation
- Orbital mechanics calculations
- Path analysis and optimization
- 3D trajectory visualization concepts

**Use Cases**: Ballistics, satellite mechanics, robotics path planning

### 5. `advanced_analysis.v` - Complex Geometric Analysis
**🎯 Focus**: Advanced computational geometry

**Key Concepts**:
- Point cloud clustering analysis
- Bounding box calculations
- Line intersection and alignment detection
- Vector field analysis
- Geometric containment testing

**What You'll Learn**:
- Point cloud processing techniques
- Advanced line geometry
- Vector field mathematics
- Spatial analysis algorithms

**Use Cases**: Computer vision, GIS, scientific data analysis

### 6. `geometry_playground.v` - Interactive Demonstrations
**🎯 Focus**: Creative applications and interactive examples

**Key Concepts**:
- Geometric transformations (translation, scaling)
- Collision detection algorithms
- Pathfinding with obstacle avoidance
- Triangle puzzle solving
- Physics simulation (bouncing ball)
- Fractal geometry generation

**What You'll Learn**:
- Practical geometry applications
- Game development techniques
- Physics simulation basics
- Fractal mathematics
- Interactive algorithm design

**Use Cases**: Game development, interactive simulations, educational tools

## 🔧 Core VSL.GM Features Demonstrated

### Data Structures
- **`Point`**: 3D point with x, y, z coordinates
- **`Segment`**: Directed line segment between two points
- **`Bins`**: Spatial binning system for fast searches

### Key Functions
- **Distance**: `dist_point_point()`, `dist_point_line()`
- **Vectors**: `vector_dot()`, `vector_norm()`, `vector_add()`
- **Spatial**: `points_lims()`, `is_point_in()`, `is_point_in_line()`
- **Binning**: `Bins.new()`, `append()`, `calc_index()`

## 🎓 Learning Path

### Beginner: Start Here
1. **`basic_geometry.v`** - Learn fundamental concepts
2. **`distance_analysis.v`** - Understand spatial relationships

### Intermediate: Expand Knowledge
3. **`spatial_binning.v`** - Efficient data organization
4. **`trajectory_simulation.v`** - Motion and physics

### Advanced: Master the Module
5. **`advanced_analysis.v`** - Complex geometric algorithms
6. **`geometry_playground.v`** - Creative applications

## 🎯 Real-World Applications

### Scientific Computing
- **Molecular Dynamics**: Particle simulation and spatial binning
- **Astronomy**: Orbital mechanics and trajectory calculation
- **Physics**: Projectile motion and collision detection

### Engineering
- **Robotics**: Path planning and obstacle avoidance
- **CAD Systems**: Geometric transformations and measurements
- **Finite Element**: Mesh analysis and point cloud processing

### Game Development
- **Physics Engines**: Collision detection and spatial indexing
- **AI Pathfinding**: Obstacle avoidance and route optimization
- **Procedural Generation**: Fractal geometry and algorithmic content

### Data Science
- **GIS Systems**: Spatial analysis and geographic calculations
- **Computer Vision**: Point cloud analysis and feature detection
- **Machine Learning**: Spatial clustering and geometric features

## 📊 Performance Characteristics

### Spatial Binning Benefits
- **Neighbor Search**: O(1) average case vs O(n) brute force
- **Collision Detection**: Dramatic speedup for dense particle systems
- **Memory Efficiency**: Organizes data spatially for cache efficiency

### Optimization Tips
- Use appropriate bin sizes (not too small, not too large)
- Consider spatial distribution of your data
- Leverage geometric properties for specific algorithms

## 🛠️ Usage Patterns

### Basic Pattern
```v
import vsl.gm

// Create points
p1 := gm.Point.new(1.0, 2.0, 3.0)
p2 := gm.Point.new(4.0, 5.0, 6.0)

// Calculate distance
distance := gm.dist_point_point(p1, p2)

// Create segment
seg := gm.Segment.new(p1, p2)
length := seg.len()
```

### Spatial Binning Pattern
```v
import vsl.gm

// Setup binning system
xmin := [0.0, 0.0, 0.0]
xmax := [10.0, 10.0, 10.0]
ndiv := [5, 5, 5]
mut bins := gm.Bins.new(xmin, xmax, ndiv)

// Add points
bins.append([x, y, z], id, extra_data)

// Query spatial organization
bin_index := bins.calc_index([x, y, z])
```

### Vector Mathematics Pattern
```v
import vsl.gm

// Vector operations
v1 := [1.0, 2.0, 3.0]
v2 := [4.0, 5.0, 6.0]

dot_product := gm.vector_dot(v1, v2)
norm := gm.vector_norm(v1)
result := gm.vector_add(2.0, v1, -1.0, v2)  // 2*v1 - v2
```

## 🔗 Related VSL Modules

- **`vsl.la`**: Linear algebra operations
- **`vsl.plot`**: Visualization of geometric data
- **`vsl.util`**: Utility functions for data generation
- **`vsl.ml`**: Machine learning with geometric features

## 📖 Further Reading

- [VSL Documentation](https://vlang.github.io/vsl)
- [Computational Geometry: Algorithms and Applications](https://www.springer.com/gp/book/9783540779735)
- [3D Math Primer for Graphics and Game Development](https://gamemath.com/)

---

🎯 **Master 3D geometry with VSL!** These examples provide a comprehensive foundation for computational geometry applications in scientific computing, engineering, and game development.
