open Owl

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

module OdeSolver : SolverT = struct
  type problem_t = 
    {f: Mat.mat -> float -> Mat.mat; y0: Mat.mat}
  type tspec_t = default_tspec_t
  type output_t = float array * Mat.mat
  type algorithms = 
    | Euler
    | RK4 
    | Cvode of {stiff: bool}

  let make_algo prms = match prms with
    | Euler      -> Euler
    | RK4        -> RK4 
    | Cvode prms -> Cvode prms

  let odeint ~algo = 
    let integrate =
      match algo with
      | Euler         -> Native.euler 
      | RK4           -> Native.rk4 
      | Cvode {stiff} -> (Sundials.cvode ~stiff)
    in
    fun ~problem ~tspec ->
      let f = problem.f and y0 = problem.y0 in
      let tspan, dt =   
        match tspec with
        | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
        | T2 {tspan; dt} -> tspan, dt 
        | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED in
      integrate ~f ~tspan ~dt ~y0
end


module SymplecticSolver : SolverT = struct
  type problem_t = 
    {f: Mat.mat -> Mat.mat -> float -> Mat.mat; x0: Mat.mat; p0: Mat.mat}
  type tspec_t = default_tspec_t
  type output_t = float array * Mat.mat * Mat.mat
  type algorithms = 
    | Symplectic_Euler
    | Leapfrog
    | Pseudoleapfrog
    | Ruth3
    | Ruth4

  let make_algo prms = match prms with
    | Symplectic_Euler -> Symplectic_Euler
    | Leapfrog         -> Leapfrog
    | Pseudoleapfrog   -> Pseudoleapfrog
    | Ruth3            -> Ruth3
    | Ruth4            -> Ruth4

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

end
