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
- [Recommended: Link to relevant tutorial if applicable]

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/[example_name]

# Run the example
v run main.v

# Alternative with flags (if needed)
v -cflags [flags] run main.v
# Or with backend flags
v -d vsl_blas_cblas run main.v
```

## 📊 Expected Output

[Describe what users should expect to see when running the example]

- [Output type 1: e.g., generated plot with description]
- [Output type 2: e.g., console output with sample]
- [Output type 3: e.g., created files]

## 🔍 Code Walkthrough

### [Section 1: e.g., Data Preparation]

[Explain this part of the code and its purpose with code snippets]

```v
// Example code snippet with explanation
code_here()
```

[Explanation of what the code does and why]

### [Section 2: e.g., Algorithm Implementation]

[Explain this part of the code and its purpose]

### [Section 3: e.g., Visualization/Output]

[Explain this part of the code and its purpose]

## 📐 Mathematical Background

[Optional but recommended section explaining the mathematical/theoretical concepts]

### [Concept 1]

[Mathematical explanation, formulas, or theory]

### [Concept 2]

[Additional mathematical details]

## 🎨 Experiment Ideas

Try modifying the example to:

- [Suggestion 1 with specific guidance]
- [Suggestion 2 with expected outcome]
- [Suggestion 3 with learning objective]

## 📚 Related Examples

- `[example_name]` - [Brief description and why it's related]
- `[example_name]` - [Brief description]
- `[example_name]` - [Brief description]

## 📖 Related Tutorials

- [Tutorial Name](../../docs/category/tutorial.md) - [Why it's relevant]
- [Another Tutorial](../../docs/category/tutorial.md) - [Relevance]

## 🔬 Technical Details

[Optional section for deeper technical information]

**Key VSL Components:**

- `[module.function()]` - [Description and usage]
- `[module.struct]` - [Description and when to use]

**Performance Notes:**

- [Any performance considerations]
- [Optimization tips if applicable]

## 🐛 Troubleshooting

**Common Issue 1**: [Description]
- Solution: [How to fix]

**Common Issue 2**: [Description]
- Solution: [How to fix]

**Module errors**: Verify VSL installation with `v list` command

**Build failures**: Check V compiler version compatibility

**Plot doesn't open**: Ensure web browser is installed and set as default

---

Happy coding! Explore more VSL examples in the [examples directory](../).
````

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
import vsl.plot
import vsl.util

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