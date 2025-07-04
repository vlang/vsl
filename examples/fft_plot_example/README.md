# Fast Fourier Transform (FFT) Example 🌊

This example demonstrates signal processing using VSL's FFT impleme---

Dve into signal processing with VSL! 🚀 Explore more examples in the  
[examples directory](../).ive into signal processing with VSL! 🚀 Explore more examples in the  
[examples directory](../).ve into signal processing with VSL! 🚀 Explore more examples in the  
[examples directory](../).ation combined with data
visualization. Learn how to analyze frequency components of signals and visualize the results.

## 🎯 What You'll Learn

- Fast Fourier Transform fundamentals
- Signal generation and processing
- Frequency domain analysis
- Scientific plotting of time and frequency data
- VSL FFT module integration

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Optional: FFTW3 library for enhanced performance

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/fft_plot_example

# Run with basic FFT
v run main.v

# Run with FFTW3 backend (if available)
v -cflags -lfftw3 run main.v
```

## 📊 Expected Output

The example generates an interactive HTML plot showing:

- **Original Signal**: Time-domain representation of the input waveform
- **FFT Spectrum**: Frequency-domain analysis showing spectral components
- **Interactive Interface**: Zoom, pan, and hover capabilities

## 🔍 Algorithm Walkthrough

### 1. Signal Generation

Creates a composite signal with:

- Primary frequency component: `sin(0.1 * t)`
- Secondary frequency component: `0.5 * sin(0.01 * t)`
- 100 sample points for demonstration

### 2. FFT Processing

1. **Create FFT Plan**: Optimizes computation for the given signal length
2. **Forward Transform**: Converts time-domain signal to frequency domain
3. **Spectrum Analysis**: Extracts magnitude and phase information

### 3. Visualization

- Plots both original signal and transformed spectrum
- Uses different colors and markers for clarity
- Includes proper labeling and legends

## 🎨 Experiment Ideas

Try modifying the example:

- **Change signal parameters**: Frequency, amplitude, phase
- **Add noise**: Gaussian or uniform random noise
- **Multiple frequencies**: Create more complex signals
- **Window functions**: Apply Hamming, Hanning, or Blackman windows
- **Inverse FFT**: Transform back to time domain

## 📚 Related Examples

- `plot_line_axis_titles` - Enhanced plotting techniques
- `noise_fractal_2d` - Signal generation with noise
- `data_analysis_example` - Statistical signal analysis

## 🔬 Technical Details

**FFT Implementation:**

- Uses VSL's built-in FFT algorithms
- Supports complex number operations
- Automatic memory management
- Optional FFTW3 backend for performance

**Performance Notes:**

- Signal length affects computation time
- Power-of-2 lengths are most efficient
- FFTW3 backend provides significant speedup for large signals

## 🐛 Troubleshooting

**Memory errors**: Reduce signal length for large datasets

**FFT plan creation fails**: Check signal length and available memory

**FFTW3 not found**: Install FFTW3 development packages or use built-in FFT

**Plot display issues**: Ensure web browser is installed and accessible

## 🔗 Additional Resources

- [FFT Algorithm Theory](https://en.wikipedia.org/wiki/Fast_Fourier_transform)
- [FFTW3 Documentation](http://www.fftw.org/fftw3_doc/)
- [VSL FFT Module Reference](https://vlang.github.io/vsl/fft/)
---

Dive into signal processing with VSL! 🚀 Explore more examples in the
[examples directory](../).
