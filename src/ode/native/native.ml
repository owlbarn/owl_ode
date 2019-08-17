(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

module Generic = struct
  include Owl_ode_base.Native_generic
end

module S = struct
  include Native_s
end

module D = struct
  include Native_d
end
