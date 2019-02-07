val odeint : 
  (module Types.SolverT with type output = 'a and type s = 'b and type t = 'c) ->
  ('b -> float -> 'c) ->
  'b ->
  Types.tspec_t -> 
  unit ->
  'a


