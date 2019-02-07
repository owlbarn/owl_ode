open Owl
open Types

type f_t = Mat.mat -> float -> Mat.mat

let euler_s ~(f:f_t) ~dt = fun y0 t0 ->
  let y = Mat.(y0 + (f y0 t0) *$ dt) in
  let t = t0 +. dt in
  y, t

let midpoint_s ~(f:f_t) ~dt = fun y0 t0 ->
  let k1 = Mat.(dt $* (f y0 t0)) in
  let k2 = Mat.(dt $* (f (y0 + k1 *$ 0.5) (t0 +. 0.5 *. dt))) in
  let y = Mat.(y0 + k2) in
  let t = t0 +. dt in
  y, t

let rk4_s ~(f:f_t) ~dt = fun y0 t0 ->
  let k1 = Mat.(dt $* (f y0 t0)) in
  let k2 = Mat.(dt $* (f (y0 + k1 *$ 0.5) (t0 +. 0.5 *. dt))) in
  let k3 = Mat.(dt $* (f (y0 + k2 *$ 0.5) (t0 +. 0.5 *. dt))) in
  let k4 = Mat.(dt $* (f (y0 + k3) (t0 +. dt))) in
  let dy = Mat.((k1 + k2 + k3 + k4) /$ 6.) in
  let y = Mat.(y0 + dy) in
  let t = t0 +. dt in
  y, t

let prepare step f y0 tspec () =
  let tspan, dt = match tspec with
    | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
    | T2 {tspan; dt} -> tspan, dt 
    | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED 
  in
  let step = step ~f ~dt in
  Common.integrate ~step ~tspan ~dt y0


module Euler = struct
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = prepare euler_s
end

module Midpoint = struct
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = prepare midpoint_s
end

module RK4 = struct
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = prepare rk4_s
end
