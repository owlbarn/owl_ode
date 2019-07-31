(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

open Types

module Make (M : Owl_types_ndarray_algodiff.Sig with type elt = float) : sig
  type f_t = M.arr * M.arr -> float -> M.arr

  val symplectic_euler_s
    :  f_t
    -> dt:float
    -> M.arr * M.arr
    -> float
    -> (M.arr * M.arr) * float

  val leapfrog_s : f_t -> dt:float -> M.arr * M.arr -> float -> (M.arr * M.arr) * float

  val pseudoleapfrog_s
    :  f_t
    -> dt:float
    -> M.arr * M.arr
    -> float
    -> (M.arr * M.arr) * float

  val ruth3_s : f_t -> dt:float -> M.arr * M.arr -> float -> (M.arr * M.arr) * float
  val ruth4_s : f_t -> dt:float -> M.arr * M.arr -> float -> (M.arr * M.arr) * float

  val prepare
    :  ('a -> dt:float -> M.arr * M.arr -> float -> (M.arr * M.arr) * float)
    -> 'a
    -> M.arr * M.arr
    -> tspec
    -> unit
    -> M.arr * M.arr * M.arr

  val symplectic_euler
    : (module Types.Solver
         with type state = M.arr * M.arr
          and type f = M.arr * M.arr -> float -> M.arr
          and type step_output = (M.arr * M.arr) * float
          and type solve_output = M.arr * M.arr * M.arr)

  val leapfrog
    : (module Types.Solver
         with type state = M.arr * M.arr
          and type f = M.arr * M.arr -> float -> M.arr
          and type step_output = (M.arr * M.arr) * float
          and type solve_output = M.arr * M.arr * M.arr)

  val pseudoleapfrog
    : (module Types.Solver
         with type state = M.arr * M.arr
          and type f = M.arr * M.arr -> float -> M.arr
          and type step_output = (M.arr * M.arr) * float
          and type solve_output = M.arr * M.arr * M.arr)

  val ruth3
    : (module Types.Solver
         with type state = M.arr * M.arr
          and type f = M.arr * M.arr -> float -> M.arr
          and type step_output = (M.arr * M.arr) * float
          and type solve_output = M.arr * M.arr * M.arr)

  val ruth4
    : (module Types.Solver
         with type state = M.arr * M.arr
          and type f = M.arr * M.arr -> float -> M.arr
          and type step_output = (M.arr * M.arr) * float
          and type solve_output = M.arr * M.arr * M.arr)

  (* ----- helper functions ----- *)

  val to_state_array
    :  ?axis:int
    -> int * int
    -> M.arr
    -> M.arr
    -> M.arr array * M.arr array
end
