  GNU nano 6.2                                          run_graph.sh                                                    #!/bin/bash

# Run the first command and capture its output
output=$(minizinc --solver Gecode MCP_CP_graph.mzn ./../Instances/inst$1.dzn)
# Check if the first command succeeded
if [ $? -eq 0 ]; then
    # Pass the output as an argument to the second command
    python3 ./../utility/cp_sol.py "$output"
else
    echo "Error: The first command failed."
fi









