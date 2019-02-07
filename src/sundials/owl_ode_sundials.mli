val wrap : 
  Owl.Mat.mat ->
  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

val unwrap :
  int * int -> 
  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t -> 
  Owl.Mat.mat

(* returns arrays of time and state *)
(* val cvode_s :
  stiff:bool ->
  relative_tol:float ->
  abs_tol:float ->
  f:(Owl.Mat.mat -> float -> Owl.Mat.mat) ->
  tspan:float * float ->
  dt:float ->
  y0:Owl.Mat.mat -> 
  unit ->
  float array * Owl.Mat.mat  *)


val cvode : 
  ?stiff:bool -> 
  ?relative_tol:float -> 
  ?abs_tol:float ->
  unit -> 
  (Owl.Mat.mat -> float -> Owl.Mat.mat) ->
  Owl.Mat.mat ->
  Owl_ode.Types.tspec_t ->
  unit ->
  float array * Owl.Mat.mat

module Owl_Cvode: Owl_ode.Types.SolverT
  with type s = Owl.Mat.mat
   and type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat
