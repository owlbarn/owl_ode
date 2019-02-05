(* TODO: make all solvers take float array as input *)
type default_tspec_t = 
  | T1 of {t0: float; duration:float; dt: float}
  | T2 of {tspan: (float * float); dt: float}
  | T3 of float array

module type SolverT = sig
  type problem_t
  type algorithms
  type tspec_t
  type output_t
  val odeint :
    algo: algorithms ->
    problem: problem_t ->
    tspec: tspec_t ->
    unit ->
    output_t 
  val make_algo : algorithms -> algorithms
end

module OdeSolver : SolverT

module SymplecticSolver: SolverT
