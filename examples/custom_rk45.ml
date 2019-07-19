open Owl
open Owl_ode
open Owl_ode.Types

let tau = 150E-3

let f =
  let mu = 10. in
  let lambda = 0.1 in
  fun y _t ->
    let y = Mat.to_array y in
    [| [| y.(1); -.y.(0) +. (mu *. y.(1) *. (lambda -. Maths.sqr y.(0))) |] |]
    |> Mat.of_arrays


let y0 = Mat.of_array [| 0.02; 0.03 |] 1 2

let print_dim x =
  let d1, d2 = Mat.shape x in
  Printf.printf "%i, %i\n" d1 d2


(* use Ode provided cvode integrator *)
let () =
  let tspec = T1 { t0 = 0.0; dt = 1E-2; duration = 30.0 } in
  let custom_rk45 = Native.D.rk45 ~tol:1E-9 ~dtmax:10.0 in
  let ts, ys = Ode.odeint custom_rk45 f y0 tspec () in
  (* save ts and ys *)
  Mat.save_txt Mat.(ts @|| ys) "custom_rk45.txt"
