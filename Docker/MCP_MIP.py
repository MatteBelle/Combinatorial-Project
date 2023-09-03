import numpy as np # Numpy for matrix operations
import sys
import time

# receive instance number from command line argument
instance = sys.argv[1]
# open the file in Instances folder
f = open(f"./../Instances/inst{instance}.dat", "r")
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
from ortools.linear_solver import pywraplp

def solve_courier_problem(courier_capacities, item_sizes, item_distances):
    num_couriers = len(courier_capacities)
    num_items = len(item_sizes)

    solver = pywraplp.Solver.CreateSolver('SCIP')
    max_distance = solver.IntVar(0, solver.infinity(), 'max_distance')

    # Create variables
    assignment = [[[solver.IntVar(0, 1, f'assignment_{i}_{j}_{k}') for j in range(num_items + 1)] for k in range(num_items + 1)] for i in range(num_couriers)]
    
    # The diagonal of the matrix is 0
    solver.Add(sum(assignment[i][j][j] for i in range(num_couriers) for j in range(num_items + 1)) == 0)
    
    # Create constraints: items are assigned to at most one courier
    for j in range(num_items):
        solver.Add(sum(assignment[i][j][k] for i in range(num_couriers) for k in range(num_items + 1)) == 1)
        solver.Add(sum(assignment[i][k][j] for i in range(num_couriers) for k in range(num_items + 1)) == 1)
    
    for i in range(num_couriers):
        # We set boundaries for max distance, so that we can minimize it later
        solver.Add(sum(assignment[i][j][k] * item_distances[j][k] for j in range(num_items + 1) for k in range(num_items + 1)) <= max_distance)
        # Create constraints: each courier carries at least one item
        solver.Add(sum(assignment[i][num_items][k] for k in range(num_items + 1)) == 1)
        # Create constraint: courier capacities are respected
        solver.Add(sum(assignment[i][j][k] * item_sizes[j] for j in range(num_items) for k in range(num_items + 1)) <= courier_capacities[i])
        for j in range(num_items + 1):
            # Create constraint: n arcs in, n arcs out
            solver.Add(sum(assignment[i][j][k] for k in range(num_items + 1)) == sum(assignment[i][k][j] for k in range(num_items + 1)))
    
    # Create constraint: Eliminate subtours using the Miller-Tucker-Zemlin (MTZ) formulation
    u = [[solver.IntVar(0, solver.infinity(), f'u_{i}_{j}') for j in range(num_items + 1)] for i in range(num_couriers)]

    for i in range(num_couriers):
        for j in range(0, num_items + 1):
            for k in range(0, num_items + 1):
                if j != k and j != num_items:
                    # I add the constraint of the MTZ formulation
                    solver.Add(u[i][j] - u[i][k] + 1 <= (num_items - 1) * (1 - assignment[i][j][k]))
    
    solver.Minimize(max_distance)
    
    solver.set_time_limit(300000)
    
    status = solver.Solve()

    if status == pywraplp.Solver.OPTIMAL:
        print('Solution:')
        for i in range(num_couriers):
            print(f'Courier {i} takes item: ')
            print('{')
            for j in range(num_items):
                for k in range(num_items + 1):
                    if assignment[i][j][k].solution_value() > 0:
                        print(f' -> {j}')
            print('}')
        print('Max distance:', max_distance.solution_value())
        print('Objective value:', solver.Objective().Value())
        # I print the values of assignment
        # for each courier i create and print a item matrix
        print()
        for i in range(num_couriers):
            print(f'Courier {i} item matrix:')
            for j in range(num_items + 1):
                for k in range(num_items + 1):
                    print(int(assignment[i][j][k].solution_value()), end=' ')
                print()
            print()
        # I print the values of u
        print()
        print('u matrix:')
        for i in range(num_couriers):
            for j in range(num_items + 1):
                print(int(u[i][j].solution_value()), end=' ')
            print()
        print(item_distances)
    else:
        print('The problem does not have an optimal solution.')

solve_courier_problem(load_size, item_size, distance)
