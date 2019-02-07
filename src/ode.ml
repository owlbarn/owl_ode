open Owl
open Types

let odeint (type a b) 
    (module Solver : SolverT with type output=a and type t=b)
    (f : (b -> float -> Mat.mat))
    (y0: b)
    (tspec: tspec_t)
  = Solver.solve f y0 tspec

let cvode ?(stiff=false) ?(relative_tol=1E-4) ?(abs_tol=1E-8) () =  
  let integrate = Sundials.cvode ~stiff ~relative_tol ~abs_tol in
  fun f y0 tspec ->
    let tspan, dt = match tspec with
      | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
      | T2 {tspan; dt} -> tspan, dt 
      | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED 
    in integrate ~f ~tspan ~dt ~y0

module Owl_Cvode = struct
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = cvode ~stiff:true ()
end




