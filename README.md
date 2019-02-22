# Owl-ODE - Ordinary Differential Equation Solvers

Please refer to the [Project Page](http://ocaml.xyz/project/proposal.html#project-13-differential-equation-solvers) for details.

You can run the current example with `dune exec examples/van_der_pol.exe`,  `dune exec examples/damped.exe`.

## Tutorial

### Overview

Consider the problem of integrating a dymaical system that evolves according to `x' = f(x,t) = Ax`, 
where `x` is the state of the system, `x'` is the time derivative of the state, and `t` is time. 
We begin by defining f(x,t):

```ocaml
open Owl

let f x t = 
   let a = [|[|1.; -1.|];
             [|2.; -3.|]|]
           |> Mat.of_arrays in
   Mat.(a *@ x)
```

Next, we define the temporal specifications of the problem:

```ocaml
let tspec = Owl_ode.Types.(T1 {t0 = 0.; duration = 2.; dt=1E-3}
```

Here, we construct a record using the constructor `T1`, which specifies `t0`, `druation`, and step size `dt`.

Last but not least, we define the initial state of the dynamical system `x0`: 

```ocaml
let x0 = Mat.of_array [|-1.; 1.|] 2 1
```

Putting everything together, we can now call:
```ocaml
let ts, xs = Owl_ode.odeint (module Owl_ode.Native.D.RK4) f x0 tspec () 
```

The results `ts` and `xs` are matrices that contain `t` and `x(t)` respectively,
where column 0 of `xs` corresponds to x(t0) and column `2000` corresponds to `x(t0 +. duration)`
(`ts` has dimensions `1x2001` and `xs` has dimensions `2x2001`).

We choose a solver for integrating the dynamical system by specifying the module `Native.D.RK4`, 
a fixed-step, double-precision Runge-Kutta solver. 
We support a number of natively-implemented double-precision solvers in `Native.D` as well
as single-precision ones in `Native.S.RK4`.


The simple example above illustrates the basic components of defining and solving an ode problem using Owl Ode.
The main function `Owl_ode.odeint` takes as its arguments:
* a solver of module type `SolverT`, 
* a function `f` that evolves the state,
* an initial state `x0`, and
* temporal spsecification `tspec`.

The solver constrains the the type of the state `x` and that of the function `f` . 
For example, the solvers in `Owl_ode.Native`, assume that `x:mat` is a matrix and `f:mat->float->mat` returns the time derivative of `x` at time `t`.

### Sympletic Solvers 

We have implemented a number of symplectic solvers in `Owl_ode.Symplectic`. 
With sympletic solvers, the state of the system is a tuple `(x,p):mat * mat`, where `x` and `p` are the position and momentum of the system and
 `f:(mat,mat)->float->mat` is the force at state `(x,p)` and time `t`.
For a detailed example on how to use symplectic solvers, see `example/damped.ml`.


### Sundials Cvode

We have implemented a thin wrapper over Sundials Cvode (via [sundialsml's](https://github.com/inria-parkas/sundialsml)). 
To use Cvode, one can use the `module Owl_ode_sundials.Cvode` as a solver.

### Automatic inference of state dimensionality

Native, sympletic and sundials solvers automatically infer the dimensionality of the state from the initial state.
If the initial state `x0` is a row vector, the result time `t` and states `x(t)` are stacked horizontally in `ts` and `xs`.
On the contrary, if the initial state `x0` is a column vecotr, the results will be stacked vertically.

We also support integration of matrix states. By default, the states are flattened and stacked vertically in the results `xs`. 
We have a helper function `Common.to_state_array` which can be used to "unflatten" the states into an array of matrices.


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

- provide a uniform type safe interface, capable of accepting pluggable new engines and dealing with the different sets of configuration options of each of them (maybe extensible types or GADTs can help in this regard more than Functors?)

- full Owl types interoperability

- ease of use (compared to JuliaDiffEq and Scipy)

- make the native implementations robust (right now they are naive OCaml implementations)

- ...


It would be interesting to design an interface that allows to implement the [Neural ODE](https://arxiv.org/abs/1806.07366) idea in a natural way also in Owl.


## Further comments

We could provide two interfaces, one takes a stepper function and performs just a step, and can be iterated manually (like `odeint` in the current sundials implementation, or the integrators in the current ocaml implementation), and a lower level one mimicking sundials and odepack, that only performs each integration step separately.

We currently cannot have implicit methods for the lack of vector-valued root finding functions. We should add implementations for those, and then introduce some implicit methods (e.g. the implicit Stoermer-Verlet is much more robust and works nicely for non-separable Hamiltonians). At least we can use Sundials for now `:-)`

It would also be nice to provide a function that takes the pair (t, y) and returns the interpolated function.

We should make the integrators more robust and with better failure modes, we could take inspiration from the very readable scipy implementation [https://github.com/scipy/scipy/blob/v1.2.0/scipy/integrate/_ivp/rk.py#L15].
