val wrap
  :  Owl.Mat.mat
  -> (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

val unwrap
  :  int * int
  -> (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t
  -> Owl.Mat.mat

val lsoda_i
  :  relative_tol:float
  -> abs_tol:float
  -> (Owl.Mat.mat -> float -> Owl.Mat.mat)
  -> Owl.Mat.mat
  -> Owl_ode.Types.tspec
  -> unit
  -> Owl.Mat.mat * Owl.Mat.mat

val lsoda_s
  :  relative_tol:float
  -> abs_tol:float
  -> (Owl.Mat.mat -> float -> Owl.Mat.mat)
  -> dt:float
  -> Owl.Mat.mat
  -> float
  -> Owl.Mat.mat * float

val lsoda
  :  relative_tol:float
  -> abs_tol:float
  -> (module Owl_ode.Types.Solver
        with type state = Owl.Mat.mat
         and type f = Owl.Mat.mat -> float -> Owl.Mat.mat
         and type step_output = Owl.Mat.mat * float
         and type solve_output = Owl.Mat.mat * Owl.Mat.mat)

module Lsoda :
  Owl_ode.Types.Solver
    with type state = Owl.Mat.mat
     and type f = Owl.Mat.mat -> float -> Owl.Mat.mat
     and type step_output = Owl.Mat.mat * float
     and type solve_output = Owl.Mat.mat * Owl.Mat.mat
