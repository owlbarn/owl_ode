# OwlDE - Ordinary Differential Equation Solvers [![Build Status](https://travis-ci.org/owlbarn/owl_ode.svg?branch=master)](https://travis-ci.org/owlbarn/owl_ode)

Please refer to the relevant [`owl` projects page](https://ocaml.xyz/project/finished.html#ordinary-differential-equation-solver) for more details.

The library is published on the opam repository and can be installed with `opam install owl-ode`. The bindings for SUNDIALS and ODEPACK can be installed separately in the same fashion: `opam install owl-ode-sundials` and `opam install owl-ode-odepack` respectively.

You can run the current examples as follows
```
# owl-ode main library
dune exec examples/damped.exe
dune exec examples/custom_rk45.exe
# owl-ode-sundials
dune exec examples/van_der_pol_sundials.exe
# owl-ode-odepack
dune exec examples/van_der_pol_odepack.exe
```
provided that you have installed the relevant libraries and their external dependencies (e.g. openblas, sundials).
In most cases, the external dependencies can be installed from `opam` itself by running `opam depext owl-ode owl-ode-odepack owl-ode-sundials` before attempting the installation of the ocaml libraries.

In case of linking issues, please refer to `owl`'s troubleshooting section of the readme (especially if you are running a variant of `ubuntu`): https://github.com/owlbarn/owl/blob/master/README.md#troubleshooting

The documentation for the library is accessible at [ocaml.xyz/owl\_ode/owl-ode](http://ocaml.xyz/owl_ode/owl-ode/).

## Tutorial

### Overview

Consider the problem of integrating a linear dymaical system that evolves according to 

```latex
dx/dt = f(x,t) = Ax      x(t0) = x0,
``` 

where `x` is the state of the system, `dx/dt` is the time derivative of the state, and `t` is time.
Our system `A` is the matrix `[[1,-1; 2,-3]]` and the system's initial state `x0` is at `[[-1]; [1]]`. 
We want to integrate for 2 seconds with a step size of 1 millisecond. Here is how you would solve this 
problem using OwlDE:

```ocaml
(* f(x,t) *)
let f x t = 
   let a = [|[|1.; -1.|];
             [|2.; -3.|]|]
           |> Owl.Mat.of_arrays in
   Owl.Mat.(a *@ x)

(* temporal specification:
   construct a record using the constructor T1 and 
   includes information of start time, duration, 
   and step size.*)
let tspec = Owl_ode.Types.(T1 {t0 = 0.; duration = 2.; dt=1E-3})

(* initial state of the system *)
let x0 = Mat.of_array [|-1.; 1.|] 2 1

(* putting everything together *)
let ts, xs = Owl_ode.Ode.odeint (module Owl_ode.Native.D.RK4) f x0 tspec () 

(* or equivalently *)
let ts, xs = Owl_ode.Ode.odeint Owl_ode.Native.D.rk4 f x0 tspec ()
```

The results of `odeint` in this example are two matrices `xs` and `ts`, which contain the value of the state `x` at each time `t`. More specifically, column 0 of the matrix `xs` contains x(t0), while column `2000` contains `x(t0 +. duration)`.

Here, we integrated the dynamical system with `Native.D.RK4`, a fixed-step, double-precision Runge-Kutta solver. 

In Owl Ode, We support a number of natively-implemented double-precision solvers in `Native.D` and single-precision ones in `Native.S`.

The simple example above illustrates the basic components of defining and solving an ode problem using Owl Ode.
The main function `Owl_ode.odeint` takes as its arguments:

- a solver module of type `Solver`, 
- a function `f` that evolves the state,
- an initial state `x0`, and
- temporal spsecification `tspec`.

The solver module constrains the the type of `x0` and that of function `f` . For example, the solvers in `Owl_ode.Native`, assume that the states are matrices (i.e. `x:mat` is a matrix) and `f:mat->float->mat` returns the time derivative of `x` at time `t`.


We have provided a number of single and double-precision symplectic solvers in `Owl_ode.Symplectic`. 
For symplectic ode problems, the state of the system is a tuple `(x,p):mat * mat`, where `x` and `p` are the position and momentum coordinates of the system and `f:(mat,mat)->float->mat` is a forcing function defined with at state `(x,p)` and time `t`. For a detailed example on how to call symplectic solvers, see `example/damped.ml`.

### Sundials Cvode

We have implemented a thin wrapper over Sundials Cvode (via [sundialsml](https://github.com/inria-parkas/sundialsml) wrapper). To use Cvode, one can use 

- `Owl_ode_sundials.Owl_Cvode` or 
- `Owl_ode_sundials.Owl_Cvode_Stiff`. 

Currently, we only support double-precision Sundials solvers. To use Sundials in Owl Ode, one needs to install `Sundials` and `sundialsml` (see [sundialsml](https://github.com/inria-parkas/sundialsml) for instructions). 

Note that the sundials formula on osx installs a too recent version of sundials. You can use the custom formula https://gist.github.com/mseri/60d26461b764e77b45d82ad7f0b0d7de to install the correct one.

### ODEPACK Lsoda

We have implemented a thin wrapper over ODEPACK (via the [odepack](https://github.com/Chris00/ocaml-odepack) OCaml library).
Currently only `Owl_ode_odepack.lsoda` is provided, with configurable absolute and relative tolerances.

### Automatic inference of state dimensionality
All the provided solvers automatically infer the dimensionality of the state from the initial state.
Consider Native solvers, for which the state of the system is a matrix. The initial state can be a row vector, a column vector, or a matrix, so long as it is consistent with that of `f`. 
If the initial state `x0` is a row vector with dimensions `1xN` and we integrate the system for `T` time steps, the time and states will be stacked vertically in the output (i.e. `ts` will have dimensions `Tx1` and and `xs` will have dimensions `TxN`). On the contrary, if the initial state `x0` is a column vector with dimensions, the results will be stacked horizontally (i.e. `ts` will have dimensions `1xT` and `xs` will have dimensions `NxT`).

We also support temporal integration of matrices.  That is, cases in which the state `x` is a matrix of dimensions of dimensions `NxM`. By default, in the output, we flatten and stack the states vertically (i.e., `ts` has dimensions `Tx1` and  `xs` has dimensions `TxNM`. We have a helper function `Native.D.to_state_array` which can be used to "unflatten" `xs` into an array of matrices.

### Custom Solvers

We can define new solver module by creating a module of type `Solver`. For example, to create a custom Cvode solver that has a relative tolerance of 1E-7 as opposed to the default 1E-4, we can define and use `custom_cvode` as follows:

```ocaml
let custom_cvode = Owl_ode_sundials.cvode ~stiff:false ~relative_tol:1E-7 ~abs_tol:1E-4 
(* usage *)
let ts, xs = Owl_ode.Ode.odeint custom_cvode f x0 tspec ()
```

Here, we use the `cvode` function construct a solver module `Custom_Owl_Cvode`. This function is conveniently defined in `src/sundials/owl_ode_sundials.ml`. It takes the parameters (`stiff`, `relative_tol`, and `abs_tol`) and returns a solver module of type 

```ocaml
val custom_cvode : (module Solver with 
                     type state = Mat.mat
                     and type f = Mat.mat -> float -> Mat.mat
                     and type step_output = Mat.mat * float
                     and type solve_output = Mat.mat * Mat.mat)
```

Similar helper functions like `cvode` have been also defined for native and symplectic solvers.

 
## Supported Solvers

### Native
- Euler 
- Midpoint
- RK4
- RK23 
- RK45 

example usage: `Owl_ode.Native.D.Euler` (or `Owl_ode.Native.D.euler`), `Owl_ode.Native.S.Euler` (or `Owl_ode.Native.S.euler`)

### Symplectic
- Symplectic_Euler
- PseudoLeapFrog
- LeapFrog
- Ruth3
- Ruth4

example usage: `Owl_ode.Native.D.Symplectic_Euler`, `Owl_ode.Symplectic.S.Symplectic_Euler` 

### Sundials
- Owl_Cvode (Adams)
- Owl_Cvode_Stiff (BDF)

example usage: `Owl_ode_sundials.Owl_Cvode`

We only support double-precisions Sundials solvers. 

### ODEPACK
- LSODA (automatic switching to stiff/non-stiff algorithms)

We only support double-precision Odepack solvers.

## JavaScript and Mirage backends

The `owl-ode-base` contains implementations that are purely written in OCaml.
As such, they are compatible for use in Mirage OS or in conjunction with `js_of_ocaml`, where C library linking is not supported.

You can see an example of this here: http://www.mseri.me/owlde-demo-icfp2019/ (source code: https://github.com/mseri/owlde-demo-icfp2019)

## NOTES

The main idea is develop a uniform interface to integrate ODE solvers (and in the future finite element methods) into Owl.
Currently there are three options available, providing incompatible underlying representations:

- [sundialsml](https://github.com/inria-parkas/sundialsml), providing a wrapper over Sundials

- [ocaml-odepack](https://github.com/Chris00/ocaml-odepack), providing bindings for ODEPACK (same solvers used by scipy's old interface `scipy.integrate.odeint`)

- [gsl-ocaml](https://github.com/mmottl/gsl-ocaml), providing bindings for GSL, in particular the ODE integrator bindings are here [mmottl/gsl-ocaml/src/odeiv.mli](https://github.com/mmottl/gsl-ocaml/blob/master/src/odeiv.mli)

Of course such an interface could provide additional purely OCaml functionalities, like robust native implementations of

- [x] standard fixed-step ode solvers, like Euler, Midpoint, Runge-Kutta 4

- [x] standard adaptive solvers, say rk2(3), and rk4(5) or [Tsit5](http://users.ntua.gr/tsitoura/RK54_new_v2.pdf) (in progress, missing Tsit5)

- [x] symplectic ode solvers, like Störmer-Verlet, Forest-Ruth or Yoshida

- [x] sundialsml interface (already partially implemented)

- [x] odepack interface (already partially implemented, currently not fully configurable/controllable) and 

- [ ] implementations leveraging Owl's specific capabilities, e.g. for a Taylor integrator built upon Algodiff.

   Albeit relatively old and standard, a good starting point could be the two references from [TaylorSeries.jl](https://github.com/JuliaDiff/TaylorSeries.jl), namely:

   - W. Tucker, Validated numerics: A short introduction to rigorous computations, Princeton University Press (2011).

   - A. Haro, Automatic differentiation methods in computational dynamical systems: Invariant manifolds and normal forms of vector fields at fixed points, preprint.


Some important points to address for this are:

- [X] provide a uniform type safe interface, capable of accepting pluggable new engines and dealing with the different sets of configuration options of each of them (maybe extensible types or GADTs can help in this regard more than Functors?)

- [X] full Owl types interoperability

- [X] ease of use (compared to JuliaDiffEq and Scipy)

- [ ] make the native implementations more robust (right now they are naive OCaml implementations)

- ...

OwlDE can be used to implement the [Neural ODE](https://arxiv.org/abs/1806.07366) idea in Owl: see https://github.com/tachukao/adjoint_ode/ and https://github.com/mseri/owlde-demo-icfp2019

## Further comments

We currently cannot have implicit methods for the lack of vector-valued root finding functions. We should add implementations for those, and then introduce some implicit methods (e.g. the implicit Störmer-Verlet is much more robust and works nicely for non-separable Hamiltonians). At least we can use Sundials for now `:-)`

It would also be nice to provide a function that takes the pair `(t, y)` and returns the interpolated function.

We should make the integrators more robust and with better failure modes, we could take inspiration from the very readable scipy implementation [https://github.com/scipy/scipy/blob/v1.2.0/scipy/integrate/_ivp/rk.py#L15].


## Contributing

We use [`ocamlformat`](https://github.com/ocaml-ppx/ocamlformat) to format out code. Our preferred ocamlformat setup is specified in `.ocamlformat`.
With dune, it is super simple to reformat the entire code base. Once you have [`ocamlformat`](https://github.com/ocaml-ppx/ocamlformat) installed, 
all you have to do in the project directory is do

```sh 
dune build @fmt
dune promote
```



