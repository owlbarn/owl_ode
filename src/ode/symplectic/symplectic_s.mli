(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

type mat = Owl_dense_matrix_s.mat

module Symplectic_Euler :
  Types.Solver
  with type state = mat * mat
   and type f = mat * mat -> float -> mat
   and type step_output = (mat * mat) * float
   and type solve_output = mat * mat * mat

module PseudoLeapfrog :
  Types.Solver
  with type state = mat * mat
   and type f = mat * mat -> float -> mat
   and type step_output = (mat * mat) * float
   and type solve_output = mat * mat * mat

module Leapfrog :
  Types.Solver
  with type state = mat * mat
   and type f = mat * mat -> float -> mat
   and type step_output = (mat * mat) * float
   and type solve_output = mat * mat * mat

module Ruth3 :
  Types.Solver
  with type state = mat * mat
   and type f = mat * mat -> float -> mat
   and type step_output = (mat * mat) * float
   and type solve_output = mat * mat * mat

module Ruth4 :
  Types.Solver
  with type state = mat * mat
   and type f = mat * mat -> float -> mat
   and type step_output = (mat * mat) * float
   and type solve_output = mat * mat * mat

val symplectic_euler
  : (module Types.Solver
       with type state = mat * mat
        and type f = mat * mat -> float -> mat
        and type step_output = (mat * mat) * float
        and type solve_output = mat * mat * mat)

val leapfrog
  : (module Types.Solver
       with type state = mat * mat
        and type f = mat * mat -> float -> mat
        and type step_output = (mat * mat) * float
        and type solve_output = mat * mat * mat)

val pseudoleapfrog
  : (module Types.Solver
       with type state = mat * mat
        and type f = mat * mat -> float -> mat
        and type step_output = (mat * mat) * float
        and type solve_output = mat * mat * mat)

val ruth3
  : (module Types.Solver
       with type state = mat * mat
        and type f = mat * mat -> float -> mat
        and type step_output = (mat * mat) * float
        and type solve_output = mat * mat * mat)

val ruth4
  : (module Types.Solver
       with type state = mat * mat
        and type f = mat * mat -> float -> mat
        and type step_output = (mat * mat) * float
        and type solve_output = mat * mat * mat)

(* ----- helper function ----- *)

val to_state_array : ?axis:int -> int * int -> mat -> mat -> mat array * mat array
