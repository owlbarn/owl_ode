(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

open Types

module Make (M : Owl_types_ndarray_algodiff.Sig with type elt = float) : sig
  type f_t = M.arr -> float -> M.arr

  val prepare
    :  ('a -> dt:float -> M.arr -> float -> M.arr * float)
    -> 'a
    -> M.arr
    -> tspec
    -> unit
    -> M.arr * M.arr

  val adaptive_prepare
    :  (dtmax:float -> 'a -> dt:float -> M.arr -> float -> M.arr * float * float * bool)
    -> 'a
    -> M.arr
    -> tspec
    -> unit
    -> M.arr * M.arr

  val euler_s : f_t -> dt:float -> M.arr -> float -> M.arr * float
  val midpoint_s : f_t -> dt:float -> M.arr -> float -> M.arr * float
  val rk4_s : f_t -> dt:float -> M.arr -> float -> M.arr * float

  val rk23_s
    :  tol:float
    -> dtmax:float
    -> f_t
    -> dt:float
    -> M.arr
    -> float
    -> M.arr * float * float * bool

  val rk45_s
    :  tol:float
    -> dtmax:float
    -> f_t
    -> dt:float
    -> M.arr
    -> float
    -> M.arr * float * float * bool

  val euler
    : (module Types.Solver
         with type state = M.arr
          and type f = M.arr -> float -> M.arr
          and type step_output = M.arr * float
          and type solve_output = M.arr * M.arr)

  val midpoint
    : (module Types.Solver
         with type state = M.arr
          and type f = M.arr -> float -> M.arr
          and type step_output = M.arr * float
          and type solve_output = M.arr * M.arr)

  val rk4
    : (module Types.Solver
         with type state = M.arr
          and type f = M.arr -> float -> M.arr
          and type step_output = M.arr * float
          and type solve_output = M.arr * M.arr)

  val rk23
    :  tol:float
    -> dtmax:float
    -> (module Types.Solver
          with type state = M.arr
           and type f = M.arr -> float -> M.arr
           and type step_output = M.arr * float * float * bool
           and type solve_output = M.arr * M.arr)

  val rk45
    :  tol:float
    -> dtmax:float
    -> (module Solver
          with type state = M.arr
           and type f = M.arr -> float -> M.arr
           and type step_output = M.arr * float * float * bool
           and type solve_output = M.arr * M.arr)

  (* ----- helper functions ----- *)

  val to_state_array : ?axis:int -> int * int -> M.arr -> M.arr array
end
