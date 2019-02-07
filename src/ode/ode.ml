open Types

let odeint (type a b c) 
    (module Solver : SolverT with type output=a and type s=b and type t=c)
    (f : (b -> float -> c))
    (y0: b)
    (tspec: tspec_t)
  = Solver.solve f y0 tspec




