(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

type mat = Owl_dense_matrix_d.mat

include Symplectic_generic.Make (Owl_dense_ndarray.D)

module Symplectic_Euler = struct
  type s = mat * mat
  type t = mat
  type step_output = (mat * mat) * float
  type output = mat * mat * mat

  let step = symplectic_euler_s
  let solve = prepare step
end

module PseudoLeapfrog = struct
  type s = mat * mat
  type t = mat
  type step_output = (mat * mat) * float
  type output = mat * mat * mat

  let step = pseudoleapfrog_s
  let solve = prepare step
end

module Leapfrog = struct
  type s = mat * mat
  type t = mat
  type step_output = (mat * mat) * float
  type output = mat * mat * mat

  let step = leapfrog_s
  let solve = prepare step
end

module Ruth3 = struct
  type s = mat * mat
  type t = mat
  type step_output = (mat * mat) * float
  type output = mat * mat * mat

  let step = ruth3_s
  let solve = prepare step
end

module Ruth4 = struct
  type s = mat * mat
  type t = mat
  type step_output = (mat * mat) * float
  type output = mat * mat * mat

  let step = ruth4_s
  let solve = prepare step
end
