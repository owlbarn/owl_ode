type mat = Owl_dense_matrix_d.mat

include Native_generic

module Euler = struct
  type s = mat
  type t = mat
  type output = float array * mat
  let solve = prepare euler_s
end


module Midpoint = struct
  type s = mat
  type t = mat
  type output = float array * mat
  let solve = prepare midpoint_s
end

module RK4 = struct
  type s = mat
  type t = mat
  type output = float array * mat
  let solve = prepare rk4_s
end

module RK45 = struct
  type s = mat
  type t = mat
  type output = float array * mat
  let solve = rk45_s ~tol:1e-7
end


