open Owl

module Euler: Types.SolverT
  with type t = Mat.mat
   and type output = float array * Mat.mat

module RK4: Types.SolverT
  with type t = Mat.mat
   and type output = float array * Mat.mat
