# FFT Signal Processing

Learn Fast Fourier Transform for signal analysis.

## What You'll Learn

- FFT fundamentals
- Frequency domain analysis
- Signal processing
- Visualization

## FFT Usage

```v ignore
import vsl.fft

signal := []f64{}  // Assume populated

mut plan := fft.create_plan(signal)?
fft.forward_fft(plan, mut signal)
spectrum := signal.clone()
```

## Next Steps

- [Examples](../../examples/fft_plot_example/) - Working examples

