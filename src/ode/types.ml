(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

(** The Types module provides some common types for 
    Owl_ode ODEs integrators. *)

(** Time specification for the ODE solvers. *)
type tspec =
  | T1 of
      { t0 : float
      ; duration : float
      ; dt : float
      }
      (** The [T1] constructor allow to specify the initial
      and final integration time, in the sense that the
      solver starts with t=t0 and integrates until it
      reaches t=t0+duration, and the timestep dt. 
      This last parameter is ignored by the adaptive
      methods. *)
  | T2 of
      { tspan : float * float
      ; dt : float
      }
      (** The [T2] constructor allow to specify a tuple 
      (t0, tf) of the initial and final integration
      time, in the sense that the solver starts with
      t=t0 and integrates until it reaches t=tf, and
      the timestep dt. This last parameter is ignored
      by the adaptive methods. *)
  | T3 of float array
      (** The [T3] constructor is currently unsupported
      and may change or disappear in the future. *)

(** Any solver compatible with {!Owl_ode.Ode.odeint}
    has to comply with the Solver type. You can use this
    to define completely new solvers, as done in the
    owl-ode-sundials or ocaml-cviode libraries, or
    to customize pre-existing solvers (see the
    van_der_pol example for one such cases). 

    The native ocaml solvers provided by Owl_ode in both single and
    double precision can be found in {!Owl_ode.Native}, respectively
    in the {!Owl_ode.Native.S} and {!Owl_ode.Native.D} modules. These
    provide multiple single-step and adaptive implementations.

    Symplectic solvers for separable Hamiltonian systems are also
    available and can be found in {!Owl_ode.Symplectic.S} and
    {!Owl_ode.Symplectic.D}. Refer to the damped oscillator for an
    example of use.

    The generic solvers in {!Owl_ode.Native_generic} and in
    {!Owl_ode.Symplectic_generic} can also be used in conjunction
    with jsoo, although how to do that is currently undocumented. 
*)
module type Solver = sig
  (** [state] is the type of the state (and thus also of
       the initial condition) provided to {!Owl_ode.Ode.odeint}.
       For example {!Owl.Mat.mat}. *)
  type state

  (** [f] is type of the evolution function. For example, in the case of 
      sympletic solvers, [type state = Owl.Mat.(mat*mat)] and
      [type f = state -> float -> Owl.Mat.mat]. *)
  type f

  (** [step_output] defines the type of the output of {!Owl_ode.Ode.step}.
      For example, in the case of native adaptive solvers,
      [type output = Owl.Mat.(mat * float * float * bool)], corresponds
      to matrices and floats that contain respectively the y1,
      t1, dt, and whether this step was valid *)
  type step_output

  (** [solve_output] defines the type of the output of {!Owl_ode.Ode.odeint}.
      For example, in the case of sympletc solvers,
      [type output = Owl.Mat.(mat * mat * mat)], corresponds
      to matrices that contain respectively the time,
      position, and momentum coordinates of the
      integrated solution *)
  type solve_output

  (** [step f dt y0 t0 ()] solves for one step given dt, y0, t0
      and the evolution function. Several such functions have already been
      implemented in this library and can be used as reference. *)
  val step : f -> dt:float -> state -> float -> step_output

  (** [solve f y0 tspec ()] solves the initial value problem

      ∂ₜ y = f(y, t)
      y(t₀) = y₀

      with the given evolution function f, initial condition y0, and
      temporal specification tspec, and returns the desired outputs
      of type output. Several such functions have already been
      implemented in this library and can be used as reference. *)
  val solve : f -> state -> tspec -> unit -> solve_output
end
