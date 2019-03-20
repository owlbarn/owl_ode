open Owl_ode

(* TODO: a module like this can be made generic and
   exposed in Common for convenience *)
module IC = struct
  type t = {x0: float; y0: float}
  let create x0 y0 = {x0; y0}
  let to_initial {x0;y0} = Owl.Mat.of_arrays [|[|x0|];[|y0|]|]
  let to_symplectic_initial {x0; y0} = (
    Owl.Mat.of_arrays [|[|x0|]|]
  , Owl.Mat.of_arrays [|[|y0|]|]
  )
end

let oscillator:
  Owl.Mat.mat -> float -> Owl.Mat.mat =
  fun xs _t ->
  let j = [|[|0.;  1.|];
            [|-1.; 0.|]|]
          |> Owl.Mat.of_arrays
  in Owl.Mat.(j *@ xs)

let oscillator_symplectic:
  (Owl.Mat.mat * Owl.Mat.mat) -> float -> Owl.Mat.mat =
  fun (xs, _ps) _t -> Owl.Mat.neg xs

let sin_ic = IC.create 0.0 1.0
let cos_ic = IC.create 1.0 0.0

let dt = 0.1
let tspec = Types.T1 {t0=0.0; duration=1.0; dt}

let fixed =
  [ Ode.odeint (module Native.D.Euler), 1, "Euler"
  ; Ode.odeint (module Native.D.Midpoint), 2, "Midpoint"
  ; Ode.odeint (module Native.D.RK4), 4, "RK4"
  ]
let adaptive =
  [ Ode.odeint (module Native.D.RK23), 2, "RK23"
  ; Ode.odeint (module Native.D.RK45), 4, "RK45"
  ]
let symplectic =
  [ Ode.odeint (module Symplectic.D.Leapfrog), 2, "Leapfrog"
  ; Ode.odeint (module Symplectic.D.PseudoLeapfrog), 2, "PseudoLeapfrog"
  ; Ode.odeint (module Symplectic.D.Ruth3), 3, "Ruth3"
  ; Ode.odeint (module Symplectic.D.Ruth4), 4, "Ruth4"
  ;]

let test_native algo ord tspec exact ic : int =
  let t, sol =
    algo oscillator (IC.to_initial ic) tspec ()
  in
  let open Owl in
  Mat.((row sol 0) - (map exact t))
  |> Mat.map abs_float
  |> Mat.max'
  |> Maths.log10
  |> Maths.neg
  |> Maths.floor
  |> int_of_float
  |> min ord


let test_symplectic algo ord tspec exact ic : int =
  let t, sol, _ = 
    algo oscillator_symplectic (IC.to_symplectic_initial ic) tspec ()
  in
  let open Owl in
  Mat.((col sol 0) - (map exact t))
  |> Mat.map abs_float
  |> Mat.max'
  |> Maths.log10
  |> Maths.neg
  |> Maths.floor
  |> int_of_float
  |> min ord

let native test list () =
  let tester (algo, ord, name) =
    Alcotest.(check @@ int) ("sin " ^ name) ord (test algo ord tspec Owl.Maths.sin sin_ic);
    Alcotest.(check @@ int) ("cos " ^ name) ord (test algo ord tspec Owl.Maths.cos cos_ic);
  in List.iter tester list


let test_set = [
  "Native - Fixed Step" , `Quick, native test_native fixed;
  "Native - Adaptive" , `Quick, native test_native adaptive;
  "Symplectic - Fixed Step" , `Quick, native test_symplectic symplectic;
]

(* Run it *)
let () =
  Alcotest.run "owl-ode test set" [
    "test_set", test_set;
  ]