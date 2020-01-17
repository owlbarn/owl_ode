(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

module Types = Owl_ode_base.Types

type mat = Owl_dense_matrix_d.mat

include Owl_ode_base.Native_generic.Make (Owl_algodiff_primal_ops.D)

module Euler = struct
  type state = mat
  type f = mat -> float -> mat
  type step_output = mat * float
  type solve_output = mat * mat

  let step = euler_s
  let solve = prepare step
end

module Midpoint = struct
  type state = mat
  type f = mat -> float -> mat
  type step_output = mat * float
  type solve_output = mat * mat

  let step = midpoint_s
  let solve = prepare step
end

module RK4 = struct
  type state = mat
  type f = mat -> float -> mat
  type step_output = mat * float
  type solve_output = mat * mat

  let step = rk4_s
  let solve = prepare step
end

module RK23 = struct
  type state = mat
  type f = mat -> float -> mat
  type step_output = mat * float * float * bool
  type solve_output = mat * mat

  let step = rk23_s ~tol:1e-7 ~dtmax:1E-4
  let solve = adaptive_prepare (rk23_s ~tol:1E-7)
end

module RK45 = struct
  type state = mat
  type f = mat -> float -> mat
  type step_output = mat * float * float * bool
  type solve_output = mat * mat

  let step = rk45_s ~tol:1e-7 ~dtmax:1E-4
  let solve = adaptive_prepare (rk45_s ~tol:1E-7)
end
