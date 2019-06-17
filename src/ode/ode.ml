(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

open Types

let step
    (type a b c d)
    (module Solver : SolverT
      with type output = a
       and type s = b
       and type step_output = c
       and type t = d)
    (f : b -> float -> d)
    ~(dt : float)
    (y0 : b)
    (t0 : float)
  =
  Solver.step f ~dt y0 t0


let odeint
    (type a b c d)
    (module Solver : SolverT
      with type output = a
       and type s = b
       and type step_output = c
       and type t = d)
    (f : b -> float -> d)
    (y0 : b)
    (tspec : tspec_t)
  =
  Solver.solve f y0 tspec
