include "globals.mzn";
%VERSION NUMBER: 3 
% To achieve a fair division among drivers, the objective is to minimize the maximum distance travelled by any courier. 
% EGALITARIAN BALANCING https://ceur-ws.org/Vol-3173/5.pdf
% GRAPH-BASED APPROACH https://github.com/MiniZinc/minizinc-benchmarks/blob/master/cvrp/cvrp.mzn
% THEORY BEHIND IT https://ozgurakgun.github.io/ModRef2017/files/ModRef2017_MTSP.pdf

%VARIABLES DEFINITION:
int: m; %m couriers
set of int: COURIERS = 1..m;
int: n; %n items
set of int: ITEMS = 1..n;
array[COURIERS] of int: load_sizes; %Each courier has a load size li
array[ITEMS] of int: sizes; %Each item has a size sj
set of int: DISTRIB_POINTS = 1..n+1;
array[DISTRIB_POINTS,DISTRIB_POINTS] of int: distances;
%In this version we are trying a graph based approach instead of a paths array one
%The inspiration and reference for this solution is present in the MiniZinc-benchmarks repository on github, listed as cvrp 
set of int: GRAPH_NODES = 1..(n+2*m);
set of int: ORIGIN_NODES = (n+1)..(n+2*m);
set of int: START_ORIGIN_NODES = (n+1)..(n+m);
set of int: END_ORIGIN_NODES = (n+m+1)..(n+m*2);

%Tour representation
array[GRAPH_NODES, GRAPH_NODES] of int: distance_graph = array2d(GRAPH_NODES, GRAPH_NODES,
        [if i <= n /\ j <= n then distances[i, j] % Distance between items based on the distances array
         elseif i <= n /\ j in ORIGIN_NODES then distances[n+1, i] % Distance from an item to courier origin
         elseif i in ORIGIN_NODES /\ j <= n then distances[j, n+1] % Distance from courier origin to an item
         elseif i in ORIGIN_NODES /\ j in ORIGIN_NODES then 0 % Distance between courier origin points is 0
         else distances[n+1,n+1] % Default value for other cases
         endif | i, j in GRAPH_NODES]);

array[GRAPH_NODES] of var GRAPH_NODES: successor;
array[GRAPH_NODES] of var GRAPH_NODES: predecessor;
array[GRAPH_NODES] of var COURIERS: courier_per_item;
array[ITEMS] of var COURIERS: courier_count;
array[GRAPH_NODES] of var 0..max(load_sizes): load_at_node;
array[GRAPH_NODES] of int: weight = [ 
  if i <= n then 
    sizes[i]
  else 
    0
  endif
| i in GRAPH_NODES]; 
 
% ------ initialization constraints ---- %
% predecessor of start nodes are end nodes
constraint redundant_constraint(forall(i in (n+2..n+m))(
  predecessor[i] = i+m-1
  )
);
constraint redundant_constraint(
   predecessor[n+1] = n+2*m
);

% successors of end nodes are start nodes
constraint forall(i in (n+m+1..n+2*m-1)) (
  successor[i] = i-m+1 
);
constraint successor[n+2*m] = n+1;

% associate each start/end nodes with a vehicle
constraint forall(i in START_ORIGIN_NODES) (
  courier_per_item[i] = i-n
);   
constraint forall(i in END_ORIGIN_NODES) (
  courier_per_item[i] = i-n-m
);
constraint forall(i in ITEMS) (
  courier_count[i] = courier_per_item[i]
);

% vehicle load when starting at the depot
constraint forall(i in START_ORIGIN_NODES) (
  load_at_node[i] = 0 
);

% Predecessor/successor constraints
constraint redundant_constraint(forall(i in GRAPH_NODES) (
  successor[predecessor[i]] = i
  )
);

constraint redundant_constraint(
   forall(i in GRAPH_NODES) (
      predecessor[successor[i]] = i
   )
);

% Subtour elimination 
constraint circuit(successor);
constraint redundant_constraint(circuit(predecessor));

% Vehicle of node i is the same as the vehicle for the predecessor
constraint redundant_constraint(forall(i in ITEMS) (
  courier_per_item[predecessor[i]] = courier_per_item[i]
  )
);
constraint forall(i in ITEMS) (
  courier_per_item[successor[i]] = courier_per_item[i]
);
constraint forall(c in COURIERS) (
  count_eq(courier_count, c) >= 1);  
  
% Load constraints 
constraint forall(i in ITEMS) (
  load_at_node[i] + weight[i] = load_at_node[successor[i]]
);
constraint forall(i in START_ORIGIN_NODES) (
  load_at_node[i] = load_at_node[successor[i]] 
);

%constraint forall(c in COURIERS)(sum([load_at_node[j] | j in GRAPH_NODES where courier_per_item[j] = c])<=load_sizes[c]);
% Check that partial load is always less or equal then the capacity for each vehicle.
constraint redundant_constraint(
    forall(i in ITEMS)(
        load_at_node[i] <= load_sizes[courier_per_item[i]]
    )
);
% Check that final load is less or equal then the capacity for each vehicle.
constraint forall(c in COURIERS)(
    load_at_node[c+n+m] <= load_sizes[c]
);

% SYMMETRY BREAKING
% Define variables for node ordering
% array[1..n] of var 1..n: node_order;

% % Symmetry-breaking constraint to enforce node ordering with lex
% constraint lex_less(node_order, [successor[i] | i in 1..n]);

% % Define variables for vehicle assignments
% array[1..n] of var COURIERS: vehicle_assignment;

% % Symmetry-breaking constraint to enforce vehicle assignment with lex
% constraint lex_less([vehicle_assignment[i] | i in 1..n], [vehicle_assignment[i] | i in 2..n]);

% Objective to minimize
var int: total_distance = sum([distance_graph[i, successor[i]] | i in GRAPH_NODES]);
array[COURIERS] of var int: distance_done_per_courier;
constraint forall(c in COURIERS)(distance_done_per_courier[c] = sum([distance_graph[i, successor[i]] | i in GRAPH_NODES where courier_per_item[i] = c]));
var int : z = max(distance_done_per_courier);
var int: obj_func = z;
%var int: obj_func = total_distance*2 + (z-min(distance_done_per_courier))*m;
%array[COURIERS] of var int: courier_distances = [total_distance * (courier_per_item[i] == c) | i in GRAPH_NODES, c in COURIERS];
%array[1..1,1..2] of var int: obj_func = [| (max(courier_distances) - min(courier_distances)), total_distance|]; 

solve :: seq_search([int_search(successor, dom_w_deg, indomain_random),
               int_search(predecessor, dom_w_deg, indomain_random),
               int_search(courier_per_item, first_fail, indomain_random),
               int_search(load_at_node, first_fail, indomain_min),
               %int_search(distance_done_per_courier, first_fail, indomain_min),
               restart_luby(n*n)
              ])
% solve :: seq_search([int_search(successor, input_order, indomain_min),
%                int_search(predecessor, input_order, indomain_min),
%                int_search(courier_per_item, first_fail, indomain_min),
%                int_search([load_at_node[j] | j in GRAPH_NODES], first_fail, indomain_min),
%                int_search(distance_done_per_courier, first_fail, indomain_min),
%                restart_luby(n*n)
%               ])    
minimize obj_func;

output 
   [show(obj_func)] ++   
   [ "-"] ++ [show(m)] ++ 
   [ "-"] ++ [show(n)] ++ 
   [ "-'"]
;
output
  [show([successor[i] | i in GRAPH_NODES])] ++ ["'"]
;