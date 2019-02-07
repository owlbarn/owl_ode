The main idea is develop a uniform interface to integrate ODE solvers (and in the future finite element methods) into Owl.
Currently there are three options available, providing incompatible underlying representations:

- [sundialsml](https://github.com/inria-parkas/sundialsml), providing a wrapper over Sundials

- [ocaml-odepack](https://github.com/Chris00/ocaml-odepack), providing bindings for ODEPACK (same solvers used by scipy's old interface `scipy.integrate.odeint`)

- [gsl-ocaml](https://github.com/mmottl/gsl-ocaml), providing bindings for GSL, in particular the ODE integrator bindings are here [mmottl/gsl-ocaml/src/odeiv.mli](https://github.com/mmottl/gsl-ocaml/blob/master/src/odeiv.mli)

Of course such an interface could provide additional purely OCaml functionalities, like robust native implementations of

- standard ode solvers, like Euler, Midpoint, Runge-Kutta 4 and some adaptive ones, say rk2(3), and rk4(5) or [Tsit5](http://users.ntua.gr/tsitoura/RK54_new_v2.pdf)

- symplectic ode solvers, like Störmer-Verlet, Ruth3/4, Yosida

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
