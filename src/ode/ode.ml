open Owl
open Types

let odeint (type a b) 
    (module Solver : SolverT with type output=a and type t=b)
    (f : (b -> float -> Mat.mat))
    (y0: b)
    (tspec: tspec_t)
  = Solver.solve f y0 tspec




