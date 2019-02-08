type mat = Owl_dense_matrix_d.mat

module Euler: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = float array * mat

module Midpoint: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = float array * mat

module RK4: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = float array * mat

(** Default tol = 1e-7 *)
module RK23: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = float array * mat  

module RK45: Types.SolverT
  with type s = mat
   and type t = mat
   and type output = float array * mat 
