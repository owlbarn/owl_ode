open Owl
open Ode

let tau = 150E-3 
let f = 
  let mu = 10. in
  let lambda = 0.1 in
  fun _t y ->
    let y = Mat.to_array y in
    [|[| y.(1) |]; 
      [| -.y.(0) +. mu *. y.(1) *. (lambda -. Maths.sqr y.(0))|]|]
    |> Mat.of_arrays

let y0 = Mat.of_array [|0.02; 0.03|] 2 1

let () = 
  let ts, ys = odeint ~f ~dt:1E-2 ~duration:30. ~y0 () in
  (* save ts and ys *)
  let ts = [| ts |] |> Mat.of_arrays |> Mat.transpose in
  let ys = ys |> Mat.concatenate ~axis:1 |> Mat.transpose in
  Mat.save_txt Mat.(ts @|| ys) "van_der_pol_dynamics"


