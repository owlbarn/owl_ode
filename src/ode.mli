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
  val solve : ((t -> float -> Mat.mat) -> t -> tspec_t -> unit -> float array * output)
end


val odeint : 
  (module SolverT with type output = 'a and type t = 'b) ->
  ('b -> float -> Mat.mat) ->
  'b ->
  tspec_t -> 
  unit ->
  float array * 'a

val cvode : 
  ?stiff:bool -> 
  ?relative_tol:float -> 
  ?abs_tol:float ->
  unit -> 
  (Mat.mat -> float -> Mat.mat) ->
  Mat.mat ->
  tspec_t ->
  unit ->
  float array * Mat.mat
  
module Owl_Cvode : SolverT with type t = Mat.mat  and type output = Mat.mat



