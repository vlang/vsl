# VSL Example Documentation Template

Use this template to create consistent, high-quality documentation for VSL examples.

## File Structure

Each example should contain:

- `main.v` - The main example code
- `README.md` - Comprehensive documentation (use template below)
- Additional files as needed (data files, configurations, etc.)

## README.md Template

````markdown
# [Example Name] 📊

[Brief description of what this example demonstrates and its learning objectives]

## 🎯 What You'll Learn

- [Learning objective 1]
- [Learning objective 2]
- [Learning objective 3]
- [Key VSL concepts covered]

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- [Any additional system dependencies]

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/[example_name]

# Run the example
v run main.v

# Alternative with flags (if needed)
v -cflags [flags] run main.v
```
````

## 📊 Expected Output

[Describe what users should expect to see when running the example]

- [Output type 1: e.g., generated plot]
- [Output type 2: e.g., console output]
- [Output type 3: e.g., created files]

## 🔍 Code Walkthrough

### [Section 1: e.g., Data Preparation]

[Explain this part of the code and its purpose]

### [Section 2: e.g., Algorithm Implementation]

[Explain this part of the code and its purpose]

### [Section 3: e.g., Visualization/Output]

[Explain this part of the code and its purpose]

## 🎨 Experiment Ideas

Try modifying the example to:

- [Suggestion 1]
- [Suggestion 2]
- [Suggestion 3]

## 📚 Related Examples

- `[example_name]` - [Brief description]
- `[example_name]` - [Brief description]
- `[example_name]` - [Brief description]

## 🔬 Technical Details

[Optional section for deeper technical information]

**Key VSL Components:**

- `[module.function()]` - [Description]
- `[module.struct]` - [Description]

**Performance Notes:**

- [Performance consideration 1]
- [Performance consideration 2]

## 🐛 Troubleshooting

**[Common issue]**: [Solution]

**[Common issue]**: [Solution]

**[Common issue]**: [Solution]

## 🔗 Additional Resources

- [Link to relevant documentation]
- [Link to scientific papers or algorithms]
- [Link to related external resources]

---

[Closing message] 🚀 Explore more [category] examples in the [examples directory](../).

````markdown
## Code Documentation Guidelines

### Comments in main.v

1. **File header comment**: Brief description of the example
2. **Section comments**: Mark major sections of the algorithm
3. **Inline comments**: Explain non-obvious code lines
4. **Variable comments**: Describe the purpose of key variables
5. **Algorithm comments**: Explain mathematical or scientific concepts

### Example Code Structure

```v
module main

// Brief description of what this example demonstrates
// Include any important notes about dependencies or requirements

import vsl.module1
import vsl.module2

fn main() {
    // === Section 1: Data Preparation ===
    // Explain what kind of data we're creating and why

    // === Section 2: Algorithm Configuration ===
    // Explain parameter choices and their significance

    // === Section 3: Computation/Processing ===
    // Break down the main algorithm steps

    // === Section 4: Results and Output ===
    // Explain what the output means and how to interpret it
}
```
````

## Quality Standards

- **Clarity**: Code should be understandable by VSL beginners
- **Completeness**: Cover all necessary steps without overwhelming detail
- **Accuracy**: Ensure technical explanations are correct
- **Consistency**: Follow the established patterns and style
- **Testing**: Verify examples work across different platforms

## Categories and Learning Paths

### Beginner Examples

- Simple plotting
- Basic mathematical operations
- Fundamental ML algorithms

### Intermediate Examples

- Complex visualizations
- Advanced mathematical methods
- Multi-step data analysis

### Advanced Examples

- High-performance computing
- Parallel processing
- Complex scientific simulations
