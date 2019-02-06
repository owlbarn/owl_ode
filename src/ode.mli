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
  type ode_problem_t = {f: Owl.Mat.mat -> float -> Owl.Mat.mat; y0: Owl.Mat.mat}

  include SolverT with type tspec_t = default_tspec_t
                   and type output_t = float array * Owl.Mat.mat
                   and type problem_t = ode_problem_t

  val cvode : ?stiff:bool -> ?relative_tol:float ->
    ?abs_tol:float-> unit-> algorithm_t
  val euler: algorithm_t 
  val rk4: algorithm_t 
end

module type SymplecticSolverT = sig
  type hamiltonian_problem_t = {f: Owl.Mat.mat -> Owl.Mat.mat -> float -> Owl.Mat.mat; x0: Owl.Mat.mat; p0: Owl.Mat.mat}

  include SolverT with type tspec_t = default_tspec_t
                   and type output_t = float array * Owl.Mat.mat * Owl.Mat.mat
                   and type problem_t = hamiltonian_problem_t

  val symplectic_euler : algorithm_t
  val leapfrog: algorithm_t 
  val pseudoleapfrog: algorithm_t 
  val ruth3: algorithm_t 
  val ruth4: algorithm_t 
end

module OdeSolver : OdeSolverT
module SymplecticSolver: SymplecticSolverT
