module Symplectic_Euler: Types.SolverT
  with type s = Owl.Mat.mat * Owl.Mat.mat
   and type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat * Owl.Mat.mat

module PseudoLeapfrog: Types.SolverT
  with type s = Owl.Mat.mat * Owl.Mat.mat
   and type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat * Owl.Mat.mat

module Leapfrog: Types.SolverT
  with type s = Owl.Mat.mat * Owl.Mat.mat
   and type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat * Owl.Mat.mat

module Ruth3: Types.SolverT
  with type s = Owl.Mat.mat * Owl.Mat.mat
   and type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat * Owl.Mat.mat

module Ruth4: Types.SolverT
  with type s = Owl.Mat.mat * Owl.Mat.mat
   and type t = Owl.Mat.mat
   and type output = float array * Owl.Mat.mat * Owl.Mat.mat
