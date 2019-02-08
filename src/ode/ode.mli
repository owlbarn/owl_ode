(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

val odeint : 
  (module Types.SolverT with type output = 'a and type s = 'b and type t = 'c) ->
  ('b -> float -> 'c) ->
  'b ->
  Types.tspec_t ->
  unit ->
  'a
