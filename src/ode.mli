(* TODO: make all solvers take float array as input *)
type default_tspec_t = 
  | T1 of {t0: float; duration:float; dt: float}
  | T2 of {tspan: (float * float); dt: float}
  | T3 of float array

module type SolverT = sig
  type problem_t
  type algorithm_t
  type tspec_t
  type output_t
  val odeint :
    algo: algorithm_t ->
    problem: problem_t ->
    tspec: tspec_t ->
    unit ->
    output_t 
end

module type OdeSolverT = sig
  include SolverT
    val cvode : ?stiff:bool -> ?relative_tol:float ->
      ?abs_tol:float-> unit-> algorithm_t
    val euler: algorithm_t 
    val rk4: algorithm_t 
end

module type SymplecticSolverT = sig
  include SolverT
    val symplectic_euler : algorithm_t
    val leapfrog: algorithm_t 
    val pseudoleapfrog: algorithm_t 
    val ruth3: algorithm_t 
    val ruth4: algorithm_t 
end

module OdeSolver : OdeSolverT
module SymplecticSolver: SymplecticSolverT
