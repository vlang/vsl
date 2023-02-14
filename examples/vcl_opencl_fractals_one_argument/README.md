# This is example of create fractals from vcl (OpenCL)
until find equivalent library output from Vlang will saved to "nameV.bin" 
and if you want check outputs (which will in dir "outputs") from opencl example you have to execute theese commands:
```
cd  ~/.vmodules/vsl/examples/vcl_opencl_fractals_one_argument/
v run .
python3 converter.py
```
Control images will be in dir "images"
Of course you can add yours kernels and run with this vlang code, the new kernel must contains 
```
__kernel void @name(__write_only image2d_t outputImage){
```
where \@name must be name of your kernel and name of file `\@name.cl`
