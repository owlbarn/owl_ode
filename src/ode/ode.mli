(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

(** {2:odelib Ode library} *)

(** [step (module Solver) f dt y0 t0 ()] takes one step with the evolution
    function f(y,t) starting  at time t0 with a step size of dt and returns
    output of type step_output.
*)
val step
  :  (module Types.SolverT
        with type output = 'a
         and type s = 'b
         and type step_output = 'c
         and type t = 'd)
  -> ('b -> float -> 'd)
  -> dt:float
  -> 'b
  -> float
  -> 'c

(** [odeint (module Solver) f y0 timespec ()] numerically integrates
    an initial value problem for a system of ODEs given an initial value:

    ∂ₜ y = f(y, t)

    y(t₀) = y₀

    Here t is a one-dimensional independent variable (time), y(t) is an
    n-dimensional vector-valued function (state), and the n-dimensional
    vector-valued function f(y, t) determines the differential equations.

    The goal is to find y(t) approximately satisfying the differential
    equations, given an initial value y(t₀)=y₀. The time t₀ is passed as
    part of the timespec, that includes also the final integration time
    and a time step. Refer to {!Owl_ode.Types.tspec_t} for further
    information.

    The solver has to be passed as a first-class module and have a common
    type, {!Owl_ode.Types.SolverT}. This is useful to write new custom
    solvers or extend and customise the provided ones.
 
    Refer to the documentation of the {!Owl_ode.Types.SolverT} type 
    for further information.
*)
val odeint
  :  (module Types.SolverT
        with type output = 'a
         and type s = 'b
         and type step_output = 'c
         and type t = 'd)
  -> ('b -> float -> 'd)
  -> 'b
  -> Types.tspec_t
  -> unit
  -> 'a
