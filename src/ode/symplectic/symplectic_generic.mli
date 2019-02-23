(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

open Types
module Make :
  functor (M: Owl_types_ndarray_algodiff.Sig with type elt = float) 
    -> sig
      type f_t = M.arr -> M.arr -> float -> M.arr

      val symplectic_euler_s :
        f:f_t ->
        dt:float ->
        M.arr ->
        M.arr ->
        float ->
        M.arr * M.arr * float

      val leapfrog_s:
        f:f_t ->
        dt:float ->
        M.arr ->
        M.arr ->
        float ->
        M.arr * M.arr * float

      val pseudoleapfrog_s:
        f:f_t ->
        dt:float ->
        M.arr ->
        M.arr ->
        float ->
        M.arr * M.arr * float

      val ruth3_s :
        f:f_t ->
        dt:float ->
        M.arr ->
        M.arr ->
        float ->
        M.arr * M.arr * float

      val ruth4_s :
        f:f_t ->
        dt:float ->
        M.arr ->
        M.arr ->
        float ->
        M.arr * M.arr * float

      val prepare:
        (f:('a -> 'b -> 'c) ->
         dt:float ->
         M.arr ->
         M.arr ->
         float ->
         M.arr * M.arr * float) ->
        ('a * 'b -> 'c) ->
        M.arr * M.arr ->
        tspec_t -> unit -> M.arr * M.arr * M.arr

      (* ----- helper functions ----- *)

      val to_state_array : 
        ?axis:int ->
        int * int ->
        M.arr ->
        M.arr ->
        M.arr array * M.arr array



    end
