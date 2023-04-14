<div align="center">
<p>
    <img
        style="width: 200px"
        width="200"
        src="https://raw.githubusercontent.com/vlang/vsl/master/static/vsl-logo.png?sanitize=true"
    >
</p>
<h1>The V Scientific Library</h1>

[vlang.io](https://vlang.io) |
[Docs](https://vlang.github.io/vsl) |
[Changelog](#) |
[Contributing](https://github.com/vlang/vsl/blob/master/CONTRIBUTING.md)

</div>
<div align="center">

[![Mentioned in Awesome V][awesomevbadge]][awesomevurl]
[![VSL Continuous Integration][workflowbadge]][workflowurl]
[![Deploy Documentation][deploydocsbadge]][deploydocsurl]
[![License: MIT][licensebadge]][licenseurl]
[![Modules][ModulesBadge]][ModulesUrl]

</div>

VSL is a V library to develop Artificial Intelligence and High-Performance Scientific Computations.

|                                                                                             |                                                                                       |                                                                       |                                                                              |
| :-----------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------: | :-------------------------------------------------------------------: | :--------------------------------------------------------------------------: |
|       ![sierpinski_triangle](https://raw.githubusercontent.com/vlang/vsl/master/vcl/static/sierpinski_triangle.png)       | ![mandelbrot_blue_red_black](https://raw.githubusercontent.com/vlang/vsl/master/vcl/static/mandelbrot_blue_red_black.png) |   ![julia](https://raw.githubusercontent.com/vlang/vsl/master/vcl/static/julia.png)   | ![mandelbrot_basic](https://raw.githubusercontent.com/vlang/vsl/master/vcl/static/mandelbrot_basic.png) |
| ![mandelbrot_pseudo_random_colors](https://raw.githubusercontent.com/vlang/vsl/master/vcl/static/mandelbrot_pseudo_random_colors.png) |   ![sierpinski_triangle2](https://raw.githubusercontent.com/vlang/vsl/master/vcl/static/sierpinski_triangle2.png)    | ![julia_set](https://raw.githubusercontent.com/vlang/vsl/master/vcl/static/julia_set.png) |   ![julia_basic](https://raw.githubusercontent.com/vlang/vsl/master/vcl/static/julia_basic.png)    |

## Docs

Visit [vsl docs](https://vlang.github.io/vsl) to know more about the supported features.

VSL is a Scientific Library with a great variety of different modules.
Although most modules offer pure-V definitions, VSL also provides modules
that wrap known C libraries among other backends that allow
high performance computing as an alternative.

This library contains essential functions for linear algebra computations
(operations between all combinations of vectors and matrices, eigenvalues and eigenvectors,
linear solvers) and the development of numerical methods (e.g. numerical quadrature).

Optionally, we link VSL with existent libraries written
in C and Fortran, such as Open BLAS and LAPACK.
These existing libraries have been fundamental for the development of high-performant
simulations over many years. We believe that it is possible to rewrite these
libraries in native V and at the same time achieve the same speed delivered by them, but at the same
time, we want to allow to the users of VSL the possibility to choose when to use these libraries
as backend and when not. That is why each module documents the flags that allow this at the
time of use.

## Installation

It is possible to optimize certain modules using different backends.
For this there are some C dependencies that can be installed optionally.
If you want to use these C dependencies and other libraries,
the easiest way to work with VSL is via Docker.
Having Docker and VS Code installed, you can start developing powerful numerical simulations
using VSL in a matter of seconds. Furthermore, the best part of it is that it works on
Windows, Linux, and macOS out of the box.

### Quick, containerized (recommended)

1. Install Docker
2. Install [Visual Studio Code](https://code.visualstudio.com/)
3. Install the [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) extension for VS Code
4. Clone <https://github.com/ulises-jeremias/hello-vsl>
5. Create your application within a container (see gif below)

Done. And your system will remain "clean".

![](https://raw.githubusercontent.com/vlang/vsl/master/static/vscode-open-in-container.gif)

Our [Docker Image](https://hub.docker.com/repository/docker/ulisesjeremias/vsl)
also contains V and the V Tools for working with VS Code (or not).
Below is a video showing the convenience of
VS Code + the V tools + VSL.

![](https://raw.githubusercontent.com/vlang/vsl/master/static/container.gif)

## Install VSL locally

### Via vpm

```sh
v install vsl
```

### Via [vpkg](https://github.com/v-pkg/vpkg)

```sh
vpkg get https://github.com/vlang/vsl
```

Done. Installation completed.

## Testing

To test the module, just type the following command:

```sh
v test .
```

## Contributors

<a href="https://github.com/vlang/vsl/contributors">
  <img src="https://contrib.rocks/image?repo=vlang/vsl"/>
</a>

Made with [contributors-img](https://contrib.rocks).

[awesomevbadge]: https://awesome.re/mentioned-badge.svg
[workflowbadge]: https://github.com/vlang/vsl/actions/workflows/ci.yml/badge.svg
[deploydocsbadge]: https://github.com/vlang/vsl/actions/workflows/deploy-docs.yml/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[ModulesBadge]: https://img.shields.io/badge/modules-reference-027d9c?logo=v&logoColor=white&logoWidth=10

[awesomevurl]: https://github.com/vlang/awesome-v/blob/master/README.md#scientific-computing
[workflowurl]: https://github.com/vlang/vsl/actions/workflows/ci.yml
[deploydocsurl]: https://github.com/vlang/vsl/actions/workflows/deploy-docs.yml
[licenseurl]: https://github.com/vlang/vsl/blob/master/LICENSE
[ModulesUrl]: https://vlang.github.io/vsl/
