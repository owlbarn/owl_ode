type mat = Owl_dense_matrix_d.mat

include Symplectic_generic

module Symplectic_Euler = struct
  type s = mat * mat
  type t = mat
  type output = float array * mat * mat
  let solve = prepare symplectic_euler_s
end

module PseudoLeapfrog = struct
  type s = mat * mat
  type t = mat
  type output = float array * mat * mat
  let solve = prepare pseudoleapfrog_s
end

module Leapfrog = struct
  type s = mat * mat
  type t = mat
  type output = float array * mat * mat
  let solve = prepare leapfrog_s
end

module Ruth3 = struct
  type s = mat * mat
  type t = mat
  type output = float array * mat * mat
  let solve = prepare ruth3_s
end

module Ruth4 = struct
  type s = mat * mat
  type t = mat
  type output = float array * mat * mat
  let solve = prepare ruth4_s
end 
