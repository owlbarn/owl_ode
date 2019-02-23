# Owl-ODE - Ordinary Differential Equation Solvers

Please refer to the [Project Page](http://ocaml.xyz/project/proposal.html#project-13-differential-equation-solvers) for details.

You can run the current example with `dune exec examples/van_der_pol.exe`,  `dune exec examples/damped.exe`.

## Tutorial

### Overview

Consider the problem of integrating a linear dymaical system that evolves according to 

```latex
x' = f(x,t) = Ax,
``` 

where `x` is the state of the system, `x'` is the time derivative of the state, and `t` is time. 

We begin by defining `f(x,t)` (and use as `A` the matrix `[[1,-1; 2,3]]`):

```ocaml
let f x t = 
   let a = [|[|1.; -1.|];
             [|2.; -3.|]|]
           |> Owl.Mat.of_arrays in
   Owl.Mat.(a *@ x)
```

Next, we specify the temporal details of the problem:

```ocaml
let tspec = Owl_ode.Types.(T1 {t0 = 0.; duration = 2.; dt=1E-3})
```

Here, we construct a record using the constructor `T1`, which includes information of start time `t0`, duration `duration`, and step size `dt`.

We then provide the initial state of the dynamical system `x0` (in this example `x(0) = [-1; 1]`: 

```ocaml
let x0 = Mat.of_array [|-1.; 1.|] 2 1
```

and putting everything together, we call:
```ocaml
let ts, xs = Owl_ode.odeint (module Owl_ode.Native.D.RK4) f x0 tspec () 
```

The results of `odeint` in this example are two matrices `ts` and `xs`, which contain the times `t`s and states `x(t)`s in their respective columns. Column 0 of `xs` contains x(t0) and column `2000` contains `x(t0 +. duration)`.


Here, we integrated the dynamical system with `Native.D.RK4`, a fixed-step, double-precision Runge-Kutta solver. In Owl Ode, We support a number of natively-implemented double-precision solvers in `Native.D` and single-precision ones in `Native.S`.

The simple example above illustrates the basic components of defining and solving an ode problem using Owl Ode.
The main function `Owl_ode.odeint` takes as its arguments:

- a solver module of type `SolverT`, 
- a function `f` that evolves the state,
- an initial state `x0`, and
- temporal spsecification `tspec`.

The solver module constrains the the type of `x0` and that of function `f` . For example, the solvers in `Owl_ode.Native`, assume that `the states are matrices (i.e. x:mat` is a matrix) and `f:mat->float->mat` returns the time derivative of `x` at time `t`.


We have provided a number of single and double-precision symplectic solvers in `Owl_ode.Symplectic`. 
For symplectic ode problems, the state of the system is a tuple `(x,p):mat * mat`, where `x` and `p` are the position and momentum coordinates of the system and `f:(mat,mat)->float->mat` is a forcing function defined with at state `(x,p)` and time `t`. For a detailed example on how to call symplectic solvers, see `example/damped.ml`.

### Sundials Cvode

We have implemented a thin wrapper over Sundials Cvode (via [sundialsml's](https://github.com/inria-parkas/sundialsml) own wrapper). To use Cvode, one can use 

- `Owl_ode_sundials.Owl_Cvode` or 
- `Owl_ode_sundials.Owl_Cvode_Stiff`. 

Currently, we only support double-precision Sundials solvers. To use Sundials in Owl Ode, one needs to install `Sundials` and `sundialsml` (see [sundialsml](https://github.com/inria-parkas/sundialsml) for instructions). 


### Automatic inference of state dimensionality
All the provided solvers automatically infer the dimensionality of the state from the initial state.
Consider Native solvers, for which the state of the system is a matrix. The initial state can be a row vector, a column vector, or a matrix, so long as it is consistent with that of `f`. 
If the initial state `x0` is a row vector with dimensions `1xN` and we integrate the system for `T` time steps, the time and states will be stacked vertically in the output (i.e. `ts` will have dimensions `Tx1` and and `xs` will have dimensions `TxN`). On the contrary, if the initial state `x0` is a column vector with dimensions, the results will be stacked horizontally (i.e. `ts` will have dimensions `1xT` and `xs` will have dimensions `NxT`).

We also support temporal integration of matrices.  That is, cases in which the state `x` is a matrix of dimensions of dimensions `NxM`. By default, in the output, we flatten and stack the states vertically (i.e., `ts` has dimensions `Tx1` and  `xs` has dimensions `TxNM`. We have a helper function `Common.to_state_array` which can be used to "unflatten" `xs` into an array of matrices.

### Custom Solvers

We can define new solver module by creating a module of type `SolverT`. For example, to create a custom Cvode solver that has a relative tolerance of 1E-7 as opposed to the default 1E-4, we can construct the following module:

```ocaml
module Custom_Owl_Cvode = struct
  type s = Mat.mat
  type t = Mat.mat
  type output = Mat.mat * Mat.mat
  let solve = cvode ~relative_tol:1E-7
end
```

In constructing this module, we need to define three types:

- `type s` is the type of state and thus also the initial condition (e.g. `x0`) provided to `odeint`.

- `type t` is type of the output of the evolution function `f:s->float->t`. (e.g. in the case of sympletic solvers, `type s = (Mat.mat, Mat.mat)` and `type t = Mat.mat`.)

- `type output` defines the output of `odeint`. In the case of sympletc solvers, `type output= Mat.mat * Mat.mat * Mat.mat`, which corresponds to matrices that contain the time, position, and momentum coordinates of the integration (see `examples/dampled.ml`).

Last but not least, we need to define a `solve` function which given the function `f`, initial condition, and temporal specification `tspec` solves the problem and returns the desired outputs (`type output`).
Several such functions have already been implemented. 
In this example, we simply call the `cvode` function conveniently defined in `src/sundials/owl_ode_sundials.ml`.  Similar helper functions have been also defined for native and symplectic solvers.

 
## Supported Solvers

### Native
- Euler 
- Midpoint
- RK4
- RK23 
- RK45 

example usage: `Owl_ode.Native.D.Euler`, `Owl_ode.Native.S.Euler` 

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

## NOTES

The main idea is develop a uniform interface to integrate ODE solvers (and in the future finite element methods) into Owl.
Currently there are three options available, providing incompatible underlying representations:

- [sundialsml](https://github.com/inria-parkas/sundialsml), providing a wrapper over Sundials

- [ocaml-odepack](https://github.com/Chris00/ocaml-odepack), providing bindings for ODEPACK (same solvers used by scipy's old interface `scipy.integrate.odeint`)

- [gsl-ocaml](https://github.com/mmottl/gsl-ocaml), providing bindings for GSL, in particular the ODE integrator bindings are here [mmottl/gsl-ocaml/src/odeiv.mli](https://github.com/mmottl/gsl-ocaml/blob/master/src/odeiv.mli)

Of course such an interface could provide additional purely OCaml functionalities, like robust native implementations of

- [x] standard fixed-step ode solvers, like Euler, Midpoint, Runge-Kutta 4

- [ ] standard adaptive solvers, say rk2(3), and rk4(5) or [Tsit5](http://users.ntua.gr/tsitoura/RK54_new_v2.pdf) (in progress)

- [x] symplectic ode solvers, like Störmer-Verlet, Forest-Ruth or Yoshida

- [ ] sundialsml interface (already partially implemented)

and implementations leveraging Owl's specific capabilities, like an implementation of the Taylor integrator built upon Algodiff.
Albeit relatively old and standard, a good starting point could be the two references from [TaylorSeries.jl](https://github.com/JuliaDiff/TaylorSeries.jl), namely:

- W. Tucker, Validated numerics: A short introduction to rigorous computations, Princeton University Press (2011).

- A. Haro, Automatic differentiation methods in computational dynamical systems: Invariant manifolds and normal forms of vector fields at fixed points, preprint.

Some important points to address for this are:

- [X] provide a uniform type safe interface, capable of accepting pluggable new engines and dealing with the different sets of configuration options of each of them (maybe extensible types or GADTs can help in this regard more than Functors?)

- [X] full Owl types interoperability

- [X] ease of use (compared to JuliaDiffEq and Scipy)

- [ ] make the native implementations robust (right now they are naive OCaml implementations)

- ...


It would be interesting to design an interface that allows to implement the [Neural ODE](https://arxiv.org/abs/1806.07366) idea in a natural way also in Owl.


## Further comments

We could provide two interfaces, one takes a stepper function and performs just a step, and can be iterated manually (like `odeint` in the current sundials implementation, or the integrators in the current ocaml implementation), and a lower level one mimicking sundials and odepack, that only performs each integration step separately.

We currently cannot have implicit methods for the lack of vector-valued root finding functions. We should add implementations for those, and then introduce some implicit methods (e.g. the implicit Störmer-Verlet is much more robust and works nicely for non-separable Hamiltonians). At least we can use Sundials for now `:-)`

It would also be nice to provide a function that takes the pair `(t, y)` and returns the interpolated function.

We should make the integrators more robust and with better failure modes, we could take inspiration from the very readable scipy implementation [https://github.com/scipy/scipy/blob/v1.2.0/scipy/integrate/_ivp/rk.py#L15].
