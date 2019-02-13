(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

type mat = Owl_dense_matrix_d.mat

include Native_generic

module Euler = struct
  type s = mat
  type t = mat
  type output = mat * mat
  let solve = prepare euler_s
end


module Midpoint = struct
  type s = mat
  type t = mat
  type output = mat * mat
  let solve = prepare midpoint_s
end

module RK4 = struct
  type s = mat
  type t = mat
  type output = mat * mat
  let solve = prepare rk4_s
end

module RK23 = struct
  type s = mat
  type t = mat
  type output = mat * mat
  let solve = adaptive_prepare (rk23_s ~tol:1e-7)
end

module RK45 = struct
  type s = mat
  type t = mat
  type output = mat * mat
  let solve = adaptive_prepare (rk45_s ~tol:1e-7)
end
