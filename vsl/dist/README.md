# Probability Distributions algorithms

## Histograms

```v ignore
// Histogram holds data for computing/plotting histograms
//
//  bin[i] corresponds to station[i] <= x < station[i+1]
//
//       [ bin[0] )[ bin[1] )[ bin[2] )[ bin[3] )[ bin[4] )
//    ---|---------|---------|---------|---------|---------|---  x
//     s[0]      s[1]      s[2]      s[3]      s[4]      s[5]
//
pub struct Histogram {
pub mut:
	stations []f64 // stations
	counts   []int     // counts
}
```
