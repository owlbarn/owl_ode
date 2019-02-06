open Owl
open Bigarray

let wrap x = reshape_1 x Mat.(numel x) 

let unwrap (dim1, dim2) x = 
  genarray_of_array2 (reshape_2 (genarray_of_array1 x) dim1 dim2)

let cvode ~stiff ~relative_tol ~abs_tol ~f ~tspan:(t0, t1) ~dt ~y0 =
  (* Maybe this kind of checks should go to Common -- with an odeint equivalent
     and be used everywhere. We will just pass the step function to be used in
     the integration loop: that one will take the ~f parameter. *)
  let dim1, dim2 = Mat.shape y0 in
  assert (dim2 = 1);
  assert ((Mat.shape (f y0 t0)) = (dim1, dim2));
  (* rhs function that sundials understands *)
  let f_wrapped t y yd =
    let y = unwrap (dim1, dim2) y in
    let dy = f y t in
    Array1.blit (wrap dy) yd in
  let y = wrap y0 in
  let yvec = Nvector_serial.wrap y in
  let tolerances = Cvode.(SStolerances (relative_tol, abs_tol)) in
  let session = match stiff with
    | false -> Cvode.(init Adams Functional tolerances f_wrapped t0 yvec) 
    | true  -> Cvode.(init BDF   Functional tolerances f_wrapped t0 yvec) in
  let duration = t1 -. t0 in
  Cvode.set_stop_time session duration;
  fun () ->
    let step _y t = 
      let (t', _) = Cvode.solve_normal session t yvec in
      let y' = Mat.copy (unwrap (dim1, dim2) y) in
      y', t' in
    Common.integrate ~step ~dt ~tspan:(t0, t1) y0
