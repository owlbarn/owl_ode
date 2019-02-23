(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

type mat = Owl_dense_matrix_s.mat

module Euler: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = mat * mat

module Midpoint: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = mat * mat

module RK4: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = mat * mat

(** Default tol = 1e-7 *)
module RK23: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = mat * mat

module RK45: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = mat * mat

(* ----- helper function ----- *)

val to_state_array : 
  ?axis:int ->
  int * int ->
  mat ->
  mat array
 


