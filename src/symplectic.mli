open Owl

module Symplectic_Euler: Types.SolverT
  with type t = Mat.mat * Mat.mat
   and type output = float array * Mat.mat * Mat.mat

module PseudoLeapfrog: Types.SolverT
  with type t = Mat.mat * Mat.mat
   and type output = float array * Mat.mat * Mat.mat

module Leapfrog: Types.SolverT
  with type t = Mat.mat * Mat.mat
   and type output = float array * Mat.mat * Mat.mat

module Ruth3: Types.SolverT
  with type t = Mat.mat * Mat.mat
   and type output = float array * Mat.mat * Mat.mat

module Ruth4: Types.SolverT
  with type t = Mat.mat * Mat.mat
   and type output = float array * Mat.mat * Mat.mat
