from z3 import * # The Z3 Theorem Prover
import numpy as np # Numpy for matrix operations
import sys
# open the file in Instances folder
# receive instance number from command line argument
instance = sys.argv[1]
# open the file in Instances folder
f = open("./../Instances/inst{instance}.dat", "r")
# the first line is the number of couriers
m = int(f.readline())
# the second line is the number of items
n = int(f.readline())
# the third line is the load size of each courier
load_size = [int(x) for x in f.readline().split()]
# the fourth line is the size of each item
item_size = [int(x) for x in f.readline().split()]
# the rest is the distance matrix
distance = []
for i in range(n+1):
    distance.append([int(x) for x in f.readline().split()])
# close the file
f.close()
# output the distance matrix as a numpy array
distance = np.array(distance)
# implement the graph based approach as an adjacency matrix m x n x n
graph_nodes = [[[Bool("x_%s_%s_%s" % (i, j, k)) for k in range(m)] for j in range(n + 1)] for i in range(n + 1)]
constraints = []

for i in range(n + 1):
    # main diagonal equal to 0 (no self loops)
    constraints.append(PbEq([(graph_nodes[i][i][k], 1) for k in range(m)], 0))

# Each node visited only once
for i in range(n):
    constraints.append(And([PbEq([(graph_nodes[i][j][k],1) for k in range(m) for j in range(n+1)
                            ],1),
                            PbEq([(graph_nodes[j][i][k],1) for k in range(m) for j in range(n+1)
                            ],1)]))
    
# Each courier can go to the origin at maximum once
for k in range(m):
    constraints.append(And([PbEq([(graph_nodes[n][j][k],1) for j in range(n)
                    ],1),
                    PbEq([(graph_nodes[j][n][k],1) for j in range(n)
                    ],1)]))

# the load of each courier cannot exceed its load size
for k in range(m):
    for i in range(n):
        constraints.append(PbLe([(graph_nodes[i][j][k],item_size[i]) for i in range(n) for j in range(n+1)], load_size[k]))

# n arcs in n arcs out
for k in range(m):
    for j in range(n+1):
        constraints.append(Sum([If(graph_nodes[i][j][k], 1, 0) for i in range(n+1)]) == Sum([If(graph_nodes[j][i][k], 1, 0) for i in range(n+1)]))

#mtz Subtour elimination: u_i - u_j + n*x_ij <= n-1
u = [Int("u_%s" % i) for i in range(n + 1)]
for k in range(m):
    for i in range(n):
        for j in range(n):
            constraints.append(u[i] + If(graph_nodes[i][j][k], 1, 0) <= u[j] + (n - 1) * (1 - If(graph_nodes[i][j][k], 1, 0)))
            constraints.append(u[i] >= 0)


                
# total distance objective function
# total_distance = Int("total_distance")
# have to sum over all k but also need to add the distance from the depot to the first item and from the last item to the depot
# constraints.append(total_distance == Sum([If(graph_nodes[i][j][k], distance[i][j].item(), 0) for i in range(n + 1) for j in range(n + 1) for k in range(m)]))

max_distance_per_courier = [Int("max_distance_per_courier_%s" % k) for k in range(m)]
for k in range(m):
    constraints.append(max_distance_per_courier[k] == Sum([If(graph_nodes[i][j][k], distance[i][j].item(), 0) for i in range(n + 1) for j in range(n + 1)]))

best_max_distance = math.inf
graph_node_per_courier = [[] for k in range(m)]

s = Solver()
s.add(constraints)
for l in range(1000):
    if s.check()==sat:
        model = s.model()
        max_distance = max([model[max_distance_per_courier[k]].as_long() for k in range(m)])
        if max_distance < best_max_distance:
            best_max_distance = max_distance
            graph_node_per_courier = [[] for k in range(m)]
            for k in range(m):
                s.add(max_distance_per_courier[k] < max_distance)
                for i in range(n + 1):
                    for j in range(n + 1):
                        if model[graph_nodes[i][j][k]] == True:
                            graph_node_per_courier[k].append((i,j))
            print("best_max_distance:", best_max_distance)
            paths = [[] for k in range(m)]
            for k in range(m):
                paths[k].append(n)
                count = len(graph_node_per_courier[k])-1
                for i in range(count):
                    for elem in graph_node_per_courier[k]:
                        if elem[0] == paths[k][-1]:
                            paths[k].append(elem[1])
                            break
                paths[k].append(n)
            # remove from paths first and last element
            for k in range(m):
                paths[k].pop(0)
                paths[k].pop(-1)
            print("paths:", paths)
    else:
        break
print("best_max_distance:", best_max_distance)
print("graph_node_per_courier:", graph_node_per_courier)

# order the path of each courier of the variable graph_node_per_courier
paths = [[] for k in range(m)]
for k in range(m):
    paths[k].append(n)
    count = len(graph_node_per_courier[k])-1
    for i in range(count):
        for elem in graph_node_per_courier[k]:
            if elem[0] == paths[k][-1]:
                paths[k].append(elem[1])
                break
    paths[k].append(n)

# remove from paths first and last element
for k in range(m):
    paths[k].pop(0)
    paths[k].pop(-1)
print("paths:", paths)

# UNCOMMENT FOR OBJECTIVE FUNCTION MINIMIZING THE TOTAL DISTANCE
#s.minimize(total_distance)
#if s.check() == sat:
 #   model = s.model()

 #   print("total_distance:", model[total_distance])
 #   print("graph_nodes:")
 #   # print the human readable solution
 #   for k in range(m):
 #       print("courier", k)
 #       for i in range(n + 1):
 #           for j in range(n + 1):
 #               if model[graph_nodes[i][j][k]] == True:
 #                   print(i, "->", j)
    # plot the solution
# else:
  #  print("unsat")
