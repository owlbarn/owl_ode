open Owl
let euler ~f ~tspan ~dt ~y0 () =
  let step y0 t0 =
    let y = Mat.(y0 + (f y0 t0) *$ dt) in
    let t = t0 +. dt in
    y, t
  in
  Common.integrate ~step ~tspan ~dt y0 

let rk4 ~f ~tspan ~dt ~y0 () =
  let step y0 t0 =
    let k1 = Mat.(dt $* (f y0 t0)) in
    let k2 = Mat.(dt $* (f (y0 + k1 *$ 0.5) (t0 +. 0.5 *. dt))) in
    let k3 = Mat.(dt $* (f (y0 + k2 *$ 0.5) (t0 +. 0.5 *. dt))) in
    let k4 = Mat.(dt $* (f (y0 + k3) (t0 +. dt))) in
    let dy = Mat.((k1 + k2 + k3 + k4) /$ 6.) in
    let y = Mat.(y0 + dy) in
    let t = t0 +. dt in
    y, t in
  Common.integrate ~step ~tspan ~dt y0 
 
