# Combinatorial-Project
Project for "Combinatorial Decision Making and Optimization". Constraint modeling and optimization.

INSTRUCTIONS FOR DOCKER:
Load docker image:
docker load -i cdmo.tar

Run container:
docker run -it cdmo

Run python libraries install script:
./install_script.sh

To run SMT and MIP:
cd SMT/ or cd MIP 
python3 "Name of the model you want to run"

To run CP:
1) matrix model:
   cd CP/
   minizinc --solver "Name of the solver you want to run" "Name of the model you want to run" "Data file you want to use"
2) graph model:
   cd CP/
   ./
