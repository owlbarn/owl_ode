open Owl
open Bigarray
open Sundials

val wrap : 
  Mat.mat ->
  (float, float64_elt, c_layout) Bigarray.Array1.t

val unwrap :
  int * int -> 
  (float, float64_elt, c_layout) Bigarray.Array1.t -> 
  Mat.mat

(* returns arrays of time and state *)
val odeint :
  ?stiff:bool ->
  f:(float -> Mat.mat -> Mat.mat) ->
  ?t0:float ->
  y0:Mat.mat -> 
  dt:float ->
  duration:float -> 
  unit ->
  float array * Mat.mat array 

val print_dim : Mat.mat -> unit


