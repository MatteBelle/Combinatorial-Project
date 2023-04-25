include "globals.mzn";

int: m; %m couriers
set of int: COURIERS = 1..m;
int: n; %n items
set of int: ITEMS = 1..n;
constraint n>=m;
% To achieve a fair division among drivers, the objective is to minimize the maximum distance travelled by any courier. 

array[COURIERS] of int: load_sizes; %each courier has a load size li
array[ITEMS] of var int: sizes; %each item has a size sj
constraint forall(i in ITEMS)(
    sizes[i] > 0); 
    %each item has a size sj

set of int: DISTRIB_POINTS = 1..n+1;
array[DISTRIB_POINTS,DISTRIB_POINTS] of int: distances;
array[COURIERS, ITEMS] of bool: items_in_courier;
constraint forall(c in COURIERS) (
    sum(i in ITEMS)(items_in_courier[c,i] * sizes[i]) <= load_sizes[c]); 
    %sum of the sizes of the items present in that courier is less than            
    %or equal to the load size of that courier

%Each item is delivered exactly by one courier
constraint forall(i in ITEMS)(
    sum(c in COURIERS)(items_in_courier[c,i]) == 1);
    
%TODO Ogni corriere deve prendere su almeno un pacco









