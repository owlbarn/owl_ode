open Owl

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

module OdeSolver = struct
  type ode_problem_t = {f: Owl.Mat.mat -> float -> Owl.Mat.mat; y0: Owl.Mat.mat}

  type problem_t = ode_problem_t
  type tspec_t = default_tspec_t
  type output_t = float array * Mat.mat
  type algorithm_t = 
    | Euler
    | RK4 
    | Cvode of {stiff: bool; relative_tol: float; abs_tol:float}

  let odeint ~algo = 
    let integrate =
      match algo with
      | Euler         -> Native.euler 
      | RK4           -> Native.rk4 
      | Cvode {stiff; relative_tol; abs_tol} -> (Sundials.cvode ~stiff ~relative_tol ~abs_tol)
    in
    fun ~problem ~tspec ->
      let f = problem.f and y0 = problem.y0 in
      let tspan, dt =   
        match tspec with
        | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
        | T2 {tspan; dt} -> tspan, dt 
        | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED in
      integrate ~f ~tspan ~dt ~y0

  let cvode 
      ?(stiff=false) 
      ?(relative_tol=1E-4) 
      ?(abs_tol=1E-8) () = 
    (Cvode {stiff; relative_tol; abs_tol})
  let euler = Euler
  let rk4 = RK4
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

module SymplecticSolver = struct
  type hamiltonian_problem_t = {f: Owl.Mat.mat -> Owl.Mat.mat -> float -> Owl.Mat.mat; x0: Owl.Mat.mat; p0: Owl.Mat.mat}

  type problem_t = hamiltonian_problem_t
  type tspec_t = default_tspec_t
  type output_t = float array * Mat.mat * Mat.mat
  type algorithm_t = 
    | Symplectic_Euler
    | Leapfrog
    | Pseudoleapfrog
    | Ruth3
    | Ruth4

  let odeint ~algo = 
    let integrate = 
      match algo with
      | Symplectic_Euler -> Symplectic.symplectic_euler 
      | Leapfrog -> Symplectic.leapfrog 
      | Pseudoleapfrog -> Symplectic.pseudoleapfrog 
      | Ruth3 -> Symplectic.ruth3 
      | Ruth4 -> Symplectic.ruth4 
    in 
    fun ~problem ~tspec ->
      let f = problem.f and x0 = problem.x0 and p0 = problem.p0 in
      let tspan, dt =   
        match tspec with
        | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
        | T2 {tspan; dt} -> tspan, dt 
        | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED in 
      integrate ~f ~tspan ~dt x0 p0  

  let symplectic_euler = Symplectic_Euler 
  let leapfrog = Leapfrog
  let pseudoleapfrog = Pseudoleapfrog
  let ruth3 = Ruth3
  let ruth4 = Ruth4
end
