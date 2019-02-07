type tspec_t = 
  | T1 of {t0: float; duration:float; dt: float}
  | T2 of {tspan: (float * float); dt: float}
  | T3 of float array

module type SolverT = sig
  type s
  type t
  type output
  val solve : ((s -> float -> t) -> s -> tspec_t -> unit -> output)
end




