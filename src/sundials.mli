val wrap : 
  Owl.Mat.mat ->
  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

val unwrap :
  int * int -> 
  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t -> 
  Owl.Mat.mat

(* returns arrays of time and state *)
val cvode :
  stiff:bool->
  f:(Owl.Mat.mat -> float -> Owl.Mat.mat) ->
  tspan:float * float ->
  dt:float ->
  y0:Owl.Mat.mat -> 
  unit ->
  float array * Owl.Mat.mat 


