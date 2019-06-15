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

  val euler_s : f:f_t -> dt:float -> M.arr -> float -> M.arr * float
  val midpoint_s : f:f_t -> dt:float -> M.arr -> float -> M.arr * float
  val rk4_s : f:f_t -> dt:float -> M.arr -> float -> M.arr * float

  val prepare
    :  (f:'a -> dt:float -> M.arr -> float -> M.arr * float)
    -> 'a
    -> M.arr
    -> tspec_t
    -> unit
    -> M.arr * M.arr

  val adaptive_prepare
    :  (dtmax:float -> 'a -> M.arr -> float -> float -> float * M.arr * float * bool)
    -> 'a
    -> M.arr
    -> tspec_t
    -> unit
    -> M.arr * M.arr

  val rk23_s
    :  tol:float
    -> dtmax:float
    -> f_t
    -> M.arr
    -> float
    -> float
    -> float * M.arr * float * bool

  val rk45_s
    :  tol:float
    -> dtmax:float
    -> f_t
    -> M.arr
    -> float
    -> float
    -> float * M.arr * float * bool

  val euler
    : (module Types.SolverT
         with type s = M.arr
          and type t = M.arr
          and type output = M.arr * M.arr)

  val midpoint
    : (module Types.SolverT
         with type s = M.arr
          and type t = M.arr
          and type output = M.arr * M.arr)

  val rk4
    : (module Types.SolverT
         with type s = M.arr
          and type t = M.arr
          and type output = M.arr * M.arr)

  val rk23
    :  tol:float
    -> (module Types.SolverT
          with type s = M.arr
           and type t = M.arr
           and type output = M.arr * M.arr)

  val rk45
    :  tol:float
    -> (module SolverT
          with type s = M.arr
           and type t = M.arr
           and type output = M.arr * M.arr)

  (* ----- helper functions ----- *)

  val to_state_array : ?axis:int -> int * int -> M.arr -> M.arr array
end
