-- ==
-- input { [2,1,3] } output { [false,false,true,true,false,false] }
-- input { [2,0,3] } output { [false,false,true,false,false] }

-- Segmented scan with integer addition
let segmented_scan [n] 't (op: t -> t -> t) (ne: t)
                          (flags: [n]bool) (as: [n]t): [n]t =
  (unzip (scan (\(x_flag,x) (y_flag,y) ->
                (x_flag || y_flag,
                 if y_flag then y else x `op` y))
          (false, ne)
          (zip flags as))).1

let replicated_iota [n] (reps:[n]i32) : []i32 =
  let s1 = scan (+) 0 reps
  let s2 = map (\i -> if i==0 then 0 else unsafe s1[i-1]) (iota n)
  let tmp = scatter (replicate (unsafe s1[n-1]) 0) s2 (iota n)
  let flags = map (>0) tmp
  in segmented_scan (+) 0 flags tmp

let segmented_replicate [n] (reps:[n]i32) (vs:[n]i32) : []i32 =
  let idxs = replicated_iota reps
  in map (\i -> unsafe vs[i]) idxs

let idxs_to_flags [n] (is : [n]i32) : []bool =
  let vs = segmented_replicate is (iota n)
  in map2 (!=) vs ([0] ++ vs[:length vs-1])

let main (xs: []i32): []bool =
  idxs_to_flags xs
