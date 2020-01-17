(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

module Types : module type of Owl_ode_base.Types
module Common : module type of Owl_ode_base.Common
module Ode : module type of Owl_ode_base.Ode
module Native : module type of Native
module Symplectic : module type of Symplectic

(** The Types module provides some common types for 
    Owl_ode ODEs integrators. It is included in this module for convenience.
    *)

(** Time specification for the ODE solvers. *)
type tspec = Types.tspec =
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

(** Any solver compatible with {!Owl_ode_base.Ode.odeint}
    has to comply with the Solver type. You can use this
    to define completely new solvers, as done in the
    owl-ode-sundials, owl-ode-odepack or ocaml-cviode
    libraries, or to customize pre-existing solvers (see
    the van_der_pol example for one such cases). 

    The native ocaml solvers provided by {!Owl_ode_base} in both single and
    double precision can be found in {!Owl_ode_base.Native}, respectively
    in the {!Owl_ode_base.Native.S} and {!Owl_ode_base.Native.D} modules. These
    provide multiple single-step and adaptive implementations.

    Symplectic solvers for separable Hamiltonian systems are also
    available and can be found in {!Owl_ode_base.Symplectic.S} and
    {!Owl_ode_base.Symplectic.D}. Refer to the damped oscillator for an
    example of use.

    The generic solvers in {!Owl_ode_base.Native_generic} and in
    {!Owl_ode_base.Symplectic_generic} can also be used in conjunction
    with jsoo, although how to do that is currently undocumented. 
*)
module type Solver = Types.Solver
