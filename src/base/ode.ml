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
    (module Solver : Solver
      with type f = a
       and type solve_output = b
       and type state = c
       and type step_output = d)
    (f : a)
    ~(dt : float)
    (y0 : c)
    (t0 : float)
  =
  Solver.step f ~dt y0 t0


let odeint
    (type a b c d)
    (module Solver : Solver
      with type f = a
       and type solve_output = b
       and type state = c
       and type step_output = d)
    (f : a)
    (y0 : c)
    (tspec : tspec)
  =
  Solver.solve f y0 tspec
