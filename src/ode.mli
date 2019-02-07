open Owl

val odeint : 
  (module Types.SolverT with type output = 'a and type t = 'b) ->
  ('b -> float -> Mat.mat) ->
  'b ->
  Types.tspec_t -> 
  unit ->
  'a

val cvode : 
  ?stiff:bool -> 
  ?relative_tol:float -> 
  ?abs_tol:float ->
  unit -> 
  (Mat.mat -> float -> Mat.mat) ->
  Mat.mat ->
  Types.tspec_t ->
  unit ->
  float array * Mat.mat

module Owl_Cvode : 
  Types.SolverT with type t = Mat.mat and type output = float array * Mat.mat

