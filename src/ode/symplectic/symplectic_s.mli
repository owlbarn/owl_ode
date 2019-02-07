type mat = Owl_dense_matrix_s.mat

module Symplectic_Euler: Types.SolverT
  with type s = mat * mat
   and type t = mat
   and type output = float array * mat * mat

module PseudoLeapfrog: Types.SolverT
  with type s = mat * mat
   and type t = mat
   and type output = float array * mat * mat

module Leapfrog: Types.SolverT
  with type s = mat * mat
   and type t = mat
   and type output = float array * mat * mat

module Ruth3: Types.SolverT
  with type s = mat * mat
   and type t = mat
   and type output = float array * mat * mat

module Ruth4: Types.SolverT
  with type s = mat * mat
   and type t = mat
   and type output = float array * mat * mat  
