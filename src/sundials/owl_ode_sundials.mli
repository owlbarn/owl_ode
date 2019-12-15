val wrap
  :  Owl.Mat.mat
  -> (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

val unwrap
  :  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t
  -> Owl.Mat.mat

val cvode
  :  stiff:bool
  -> relative_tol:float
  -> abs_tol:float
  -> (module Owl_ode.Types.Solver
        with type state = Owl.Mat.mat
         and type f = Owl.Mat.mat -> float -> Owl.Mat.mat
         and type step_output = Owl.Mat.mat * float
         and type solve_output = Owl.Mat.mat * Owl.Mat.mat)

module Owl_Cvode :
  Owl_ode.Types.Solver
    with type state = Owl.Mat.mat
     and type f = Owl.Mat.mat -> float -> Owl.Mat.mat
     and type step_output = Owl.Mat.mat * float
     and type solve_output = Owl.Mat.mat * Owl.Mat.mat

module Owl_Cvode_Stiff :
  Owl_ode.Types.Solver
    with type state = Owl.Mat.mat
     and type f = Owl.Mat.mat -> float -> Owl.Mat.mat
     and type step_output = Owl.Mat.mat * float
     and type solve_output = Owl.Mat.mat * Owl.Mat.mat
