val wrap
  :  Owl.Arr.arr
  -> (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

val unwrap
  :  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t
  -> Owl.Arr.arr

val cvode
  :  stiff:bool
  -> relative_tol:float
  -> abs_tol:float
  -> (module Owl_ode.Types.Solver
        with type state = Owl.Arr.arr
         and type f = Owl.Arr.arr -> float -> Owl.Arr.arr
         and type step_output = Owl.Arr.arr * float
         and type solve_output = Owl.Arr.arr * Owl.Arr.arr)

module Owl_Cvode :
  Owl_ode.Types.Solver
    with type state = Owl.Arr.arr
     and type f = Owl.Arr.arr -> float -> Owl.Arr.arr
     and type step_output = Owl.Arr.arr * float
     and type solve_output = Owl.Arr.arr * Owl.Arr.arr

module Owl_Cvode_Stiff :
  Owl_ode.Types.Solver
    with type state = Owl.Arr.arr
     and type f = Owl.Arr.arr -> float -> Owl.Arr.arr
     and type step_output = Owl.Arr.arr * float
     and type solve_output = Owl.Arr.arr * Owl.Arr.arr
