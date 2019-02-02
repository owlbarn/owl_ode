val wrap : 
  Owl.Mat.mat ->
  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

val unwrap :
  int * int -> 
  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t -> 
  Owl.Mat.mat

(* returns arrays of time and state *)
val odeint :
  ?stiff:bool ->
  f:(float -> Owl.Mat.mat -> Owl.Mat.mat) ->
  ?t0:float ->
  y0:Owl.Mat.mat -> 
  dt:float ->
  duration:float -> 
  unit ->
  float array * Owl.Mat.mat array 

val print_dim : Owl.Mat.mat -> unit


