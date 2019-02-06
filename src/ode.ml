open Owl

type tspec_t = 
  | T1 of {t0: float; duration:float; dt: float}
  | T2 of {tspan: (float * float); dt: float}
  | T3 of float array

type ode_problem_t = {f: Mat.mat -> float -> Mat.mat; y0: Mat.mat}

type symplect_problem_t = {f: Mat.mat -> Mat.mat -> float -> Mat.mat; x0: Mat.mat; p0: Mat.mat} 

module type SolverT = sig
  type t
  type output
  val solve : ((t -> float -> Mat.mat) -> t -> tspec_t -> unit -> output)
end


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

let leapfrog =
  let integrate = Symplectic.leapfrog in
  fun f (x0,p0) tspec ->
    let f x0 p0 = f (x0,p0) in
    let tspan, dt = match tspec with
      | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
      | T2 {tspan; dt} -> tspan, dt 
      | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED 
    in integrate ~f ~tspan ~dt x0 p0

let ruth3 =
  let integrate = Symplectic.ruth3 in
  fun f (x0,p0) tspec ->
    let f x0 p0 = f (x0,p0) in
    let tspan, dt = match tspec with
      | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
      | T2 {tspan; dt} -> tspan, dt 
      | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED 
    in integrate ~f ~tspan ~dt x0 p0

let symplectic_euler =
  let integrate = Symplectic.symplectic_euler in
  fun f (x0,p0) tspec ->
    let f x0 p0 = f (x0,p0) in
    let tspan, dt = match tspec with
      | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
      | T2 {tspan; dt} -> tspan, dt 
      | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED 
    in integrate ~f ~tspan ~dt x0 p0


module Owl_Cvode = struct
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = cvode ~stiff:true ()
end




