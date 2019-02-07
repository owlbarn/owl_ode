module Euler: Types.SolverT
  with type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat

module Midpoint: Types.SolverT
  with type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat

module RK4: Types.SolverT
  with type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat

(** Default tol = 1e-7 -- untested, please do not rely on this *)
module RK45: Types.SolverT
  with type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat
