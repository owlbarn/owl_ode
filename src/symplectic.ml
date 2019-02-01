type timespan = float * float
(** Representation of a time span. *)  

let steps t0 t1 dt =
  (t1 -. t0)/.dt |> Float.floor |> int_of_float

(* opening Owl.Mat or Owl.Arr messes up badly all the integer operations *)
let (.${}) = Owl.Mat.(.${})
let (.${}<-) = Owl.Mat.(.${}<-)

let symplectic_euler ~f y0 (t0, t1) dt =
  let _, elts = Owl.Mat.shape y0 in
  assert (Owl.Maths.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = Owl.Mat.empty steps elts in

  sol.${[[0]]}<- y0;
  for idx = 1 to steps-1 do
    let xs = sol.${[[idx-1]; [0; elts/2-1]]} in
    let ps = sol.${[[idx-1]; [elts/2; elts-1]]} in
    let t = t0 +. dt *. (float_of_int idx) in
    let fxs = f xs ps t in
    let psnew = Owl.Mat.(ps + mul_scalar fxs dt) in
    sol.${[[idx]; [elts/2; elts-1]]}<- psnew;
    sol.${[[idx]; [0; elts/2-1]]}<- Owl.Mat.(xs + mul_scalar psnew dt);
  done;
  sol

let leapfrog ~f y0 (t0, t1) dt =
  let _, elts = Owl.Mat.shape y0 in
  assert (Owl.Maths.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = Owl.Mat.empty steps elts in

  sol.${[[0]]}<- y0;
  for idx = 1 to steps-1 do
    let xs = sol.${[[idx-1]; [0; elts/2-1]]} in
    let ps = sol.${[[idx-1]; [elts/2; elts-1]]} in
    let t = t0 +. dt *. (float_of_int idx) in
    let fxs = f xs ps t in
    let xsnew = Owl.Mat.(xs + mul_scalar ps dt + mul_scalar fxs (dt*.dt*.0.5)) in
    let fxsnew = f xsnew ps (t +. dt) in
    sol.${[[idx]; [0; elts/2-1]]}<- xsnew;
    sol.${[[idx]; [elts/2; elts-1]]}<- Owl.Mat.(ps + mul_scalar (fxs + fxsnew) (dt*.0.5));
  done;
  sol

(*
    (* XXX: 
    We would like to do

        pint = so.fsolve(
            lambda pint: p - pint + 0.5*h*acc(x, pint, t0+i*h),
            p
        )[0]
        xnew = x + h*pint
        pnew = pint + 0.5*h*acc(xnew, pint, t0+(i+1)*h)
        sol[i+1] = np.array((pnew, xnew))

    but http://ocaml.xyz/apidoc/owl_maths_root.html does not seem
    powerful enough for that in general.
    *)

let leapfrog_implicit ~f y0 (t0, t1) dt =
  let _, elts = Owl.Mat.shape y0 in
  assert (Owl.Maths.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = Owl.Mat.empty steps elts in

  sol.${[[0]]}<- y0;
   for idx = 1 to steps-1 do
    (* TODO *)
    ()
   done;
   sol
*)

(* TODO: impl below is rushed up and definitely broken*)

(* For the values used in the implementations below
   see Candy-Rozmus (https://www.sciencedirect.com/science/article/pii/002199919190299Z)
   and https://en.wikipedia.org/wiki/Symplectic_integrator *)

let symint_step ~coeffs ~f xs0 ps0 t0 dt =
  List.fold_left (fun (xs, ps, t) (ai, bi) ->
      let psnew = Owl.Mat.(mul_scalar (f xs ps t) (dt*.bi)) in
      let xsnew = Owl.Mat.(mul_scalar ps (dt *. ai)) in
      let t = t +. dt*.ai in
      (xsnew, psnew, t))
    (xs0, ps0, t0)
    coeffs

let symint ~coeffs ~f y0 (t0, t1) dt =
  let _, elts = Owl.Mat.shape y0 in
  assert (Owl.Maths.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = Owl.Mat.empty steps elts in

  sol.${[[0]]}<- y0;
  let t = ref t0 in
  for idx = 1 to steps-1 do
    let xs = sol.${[[idx-1]; [0; elts/2-1]]} in
    let ps = sol.${[[idx-1]; [elts/2; elts-1]]} in
    let xsnew, psnew, tnew = symint_step ~coeffs ~f xs ps !t dt in
    t := tnew;
    sol.${[[idx]; [0; elts/2-1]]}<- xsnew;
    sol.${[[idx]; [elts/2; elts-1]]}<- psnew;
  done;
  sol

let cleapfrog = [ (0.5, 0.0); (0.5, 1.0) ]
let cpseudoleapfrog = [ (1.0, 0.5); (0.0, 0.5) ]
let cruth3 = [ (2.0/.3.0, 7.0/.24.0); (-2.0/.3.0, 0.75); (1.0, -1.0/.24.0)]
let cruth4 = let c = Owl.Maths.pow 2.0 (1.0/.3.0) in
  [ (0.5, 0.0); (0.5*.(1.0-.c), 1.0); (0.5*.(1.0-.c), -.c); (0.5, 1.0)]
  |> List.map (fun (v1,v2) -> v1 /. (2.0 -. c), (v2 /. (2.0 -. c)))

let leapfrog' ~f y0 (t0, t1) dt = symint ~coeffs:cleapfrog ~f y0 (t0, t1) dt
let pseudoleapfrog ~f y0 (t0, t1) dt = symint ~coeffs:cpseudoleapfrog ~f y0 (t0, t1) dt
let ruth3 ~f y0 (t0, t1) dt = symint ~coeffs:cruth3 ~f y0 (t0, t1) dt
let ruth4 ~f y0 (t0, t1) dt = symint ~coeffs:cruth4 ~f y0 (t0, t1) dt
