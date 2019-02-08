open Common
open Types

type 'a f_t = (float, 'a) M.t -> float -> (float, 'a) M.t

val euler_s :
  f:'a f_t ->
  dt:float->
  (float, 'a) M.t -> 
  float ->
  (float, 'a) M.t * float 

val midpoint_s :
  f:'a f_t ->
  dt:float->
  (float, 'a) M.t -> 
  float ->
  (float, 'a) M.t * float 


val rk4_s :
  f:'a f_t ->
  dt:float->
  (float, 'a) M.t -> 
  float ->
  (float, 'a) M.t * float 

val rk23_s :
  ?tol:float ->
  'a f_t ->
  (float, 'a) M.t ->
  tspec_t ->
  unit ->
  float array * (float, 'a) M.t

val rk45_s :
  ?tol:float ->
  'a f_t ->
  (float, 'a) M.t ->
  tspec_t ->
  unit ->
  float array * (float, 'a) M.t

val prepare :
  (f: 'a -> 
   dt: float -> 
   ('b, 'c) M.t ->
   float ->
   ('b, 'c) M.t * float) ->
  'a ->
  ('b, 'c) M.t ->
  tspec_t ->
  unit ->
  float array * ('b, 'c) M.t
 
