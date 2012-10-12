# OpenCLAda - An Ada binding for the OpenCL host API

## About
This is OpenCLAda, a thick Ada binding for the OpenCL host API.
This binding enables you to write OpenCL hosts in Ada. It does **not**
enable you to write OpenCL kernels in Ada.

## Prerequisites

OpenCLAda currently supports MacOSX, Linux and Windows. You need to have

 - a GNAT compiler
 - an OpenCL implementation
 - OpenGLAda

available on your system. GNAT GPL Edition is available at
[the AdaCore website](http://libre.adacore.com/libre/download/). OpenCL is
usually available from your hardware vendor. On MacOSX, it's already part of
the operating system. On Windows, you'll need an `OpenCL.lib` file to link against.
This is usually not part of the OpenCL implementation, but can be acquired as
part of an SDK from your hardware vendor (eg the
[AMD APP SDK](http://developer.amd.com/SDKS/AMDAPPSDK/Pages/default.aspx)).

[OpenGLAda](https://github.com/flyx86/openglada) is required for OpenCL's
cl_gl extension (you can compile OpenCLAda with the cl_gl extension, so that
you do not need OpenGLAda, see below). If you don't have OpenGLAda installed,
just download its source and make sure the path to `opengl.gpr` is included in the
`ADA_PROJECT_PATH` environment variable. To compile the tests, you also need
the [GLFW library](http://www.glfw.org/), as the tests use the GLFW wrapper
included in OpenGLAda.

## Compilation

On MacOSX and Linux, open a terminal,
navigate to the OpenCLAda directory and do:

	$ make

On Windows, it could work the same way if you're using MinGW or Cygwin.
However, I didn't try either one. Anyway, to compile without make, just do

	$ gprbuild -p -P opencl.gpr -XGL_Backend=Windows -XCL_GL=Yes

*Note: The variable __GL_Backend__ is shared with OpenGLAda, hence the name.
You have to provide it even when compiling without OpenGL support because
it defines the way OpenCLAda links with your system.*

The compiler needs to find the `OpenCL.lib` file mentioned above. If you're
unsure how to achieve this, just copy it into `C:\GNAT\2011\lib` or wherever
you installed your GNAT compiler.

*Note: The availability of an OpenCL implementation will not be tested when
building OpenCLAda. So if you want to make sure that OpenCL is available,
build the tests and see if they are linked properly (see below).*

If you want to build OpenCLAda without the cl_gl extension, do:

   $ gprbuild -p -P opencl.gpr -XGL_Backend={Windows|MacOSX|Linux} -XCL_GL=No

*Note: The makefile does not support switching off cl_gl.*

## Installation

On MacOSX, Linux and MinGW / Cygwin, you can install the library with:

	$ make install

On Windows, there is no standard way to install the library; probably the
best thing you can do is just including OpenCLAda in your project.

## Tests

OpenCLAda comes with some tests (or rather, examples). I wrote them to test
some of the basic functionality of the API. You can build them with

	$ make tests

or

	$ gprbuild -p -P opencl.gpr -XGL_Backend={Windows|MacOSX|Linux} -XTests=Yes
	
A basic "hello world" example is also included. After compilation,
the executables will be located in the `bin` directory. They can only be
executed in the `bin` directory, as they load some OpenCL kernel files through
relative paths.

## Usage

There is some
[overview over the OpenCLAda API on the Wiki](https://github.com/flyx86/OpenCLAda/wiki/Overview).
For more information, please consult the
[Khronos OpenCL API Registry](http://www.khronos.org/registry/cl/).

## Contributing

You're welcome to contribute code or file bug reports on the
[project's page on GitHub](https://github.com/flyx86/openclada).

## License

This code is distributed under the terms of the
Simplified BSD License, which you can find in the file
`COPYING`.
