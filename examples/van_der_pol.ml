open Owl

let tau = 150E-3 
let f = 
  let mu = 10. in
  let lambda = 0.1 in
  fun y _t ->
    let y = Mat.to_array y in
    [|[| y.(1) |]; 
      [| -.y.(0) +. mu *. y.(1) *. (lambda -. Maths.sqr y.(0))|]|]
    |> Mat.of_arrays

let y0 = Mat.of_array [|0.02; 0.03|] 2 1

let () = 
  let open Ode.OdeSolver in
  let problem = {f; y0} in
  let tspec = Ode.T1 {t0=0.0; dt=1E-2; duration=30.0} in
  let ts, ys = Ode.OdeSolver.odeint ~algo:(cvode ()) ~problem ~tspec () in
  (* save ts and ys *)
  let ts = [| ts |] |> Mat.of_arrays |> Mat.transpose in
  let ys = ys |> Mat.transpose in
  Mat.save_txt Mat.(ts @|| ys) "van_der_pol_dynamics.txt"
