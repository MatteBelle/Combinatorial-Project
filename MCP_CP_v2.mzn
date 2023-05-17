include "globals.mzn";

int: m; %m couriers
set of int: COURIERS = 1..m;
int: n; %n items
set of int: ITEMS = 1..n;
constraint n>=m;
% To achieve a fair division among drivers, the objective is to minimize the maximum distance travelled by any courier. 

array[COURIERS] of int: load_sizes; %each courier has a load size li
array[ITEMS] of int: sizes; %each item has a size sj
constraint sum(s in ITEMS) (sizes[s]) <= sum(ls in COURIERS) (load_sizes[ls]);
constraint forall(i in ITEMS)(
    sizes[i] > 0); 
    %each item has a size sj

set of int: DISTRIB_POINTS = 1..n+1;
set of int: PATH = 1..(n-(m-1)+2);
array[DISTRIB_POINTS,DISTRIB_POINTS] of int: distances;
array[COURIERS, PATH] of var 1..n+1: paths; % n - (m-1) + 2 
constraint all_different_except(paths[COURIERS,ITEMS],{n+1});
constraint forall(c in COURIERS) (
  paths[c,1] = n+1 /\ paths[c,(n-(m-1)+2)]=n+1);
constraint forall(c in COURIERS) (
  forall(i in 2..n-1) (paths[c,i] < n+2));
var int: items_total = sum(ITEMS);
var int: matrix_total = sum(c in COURIERS,i in ITEMS)(paths[c,i]);
var int: matrix_empty_total = m*((n+1)*(n-(m-1)+2));
var int: row_empty = (n+1)*(n-(m-1)+2);

constraint matrix_total = matrix_empty_total - items_total;
constraint forall(c in COURIERS) (
  sum(p in PATH)(paths[c,p]) < row_empty);
  
constraint forall(c in COURIERS) (
  sum(p in PATH where paths[c,p]<n+1)(sizes[paths[c,p]]) <= load_sizes[c]);
var int: c1_size = sum(p in PATH where paths[1,p]<n+1)(sizes[paths[1,p]]);

var int: result = sum(c in COURIERS)(sum(p in 1..(n-(m-1)+1))(distances[paths[c,p],paths[c,p+1]]));

%ann: search_ann;
%search_ann = int_search(paths, dom_w_deg, indomain_min);
array[COURIERS] of var int: courier_distances;
constraint forall(c in COURIERS) (courier_distances[c] = sum(p in 1..(n-(m-1)+1))(distances[paths[c,p],paths[c,p+1]]));
array[1..1,1..2] of var int: res = [| max(courier_distances), sum(c in COURIERS)(sum(p in 1..(n-(m-1)+1))(distances[paths[c,p],paths[c,p+1]]))|];
solve minimize sum(res);

output ["Distance done: \(result)\n"];
output ["Courier paths: \n"] ++ [
    show([paths[c, p] | p in PATH where paths[c, p] < n+1]) ++ "\n" | c in COURIERS
];
%output ["size: \(c1_size)\n"];




