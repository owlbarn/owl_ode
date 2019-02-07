val odeint : 
  (module Types.SolverT with type output = 'a and type t = 'b) ->
  ('b -> float -> Owl.Mat.mat) ->
  'b ->
  Types.tspec_t -> 
  unit ->
  'a


