#!/bin/bash

# prepare environment for python script
python3 -m virtualenv .venv > /dev/null && source .venv/bin/activate > /dev/null
pip3 install -r requirements.txt > /dev/null

function wait_until_all_pods_are_ready() {
  echo -e "\nwaiting till all pods are ready\n"
  time python3 wait_until_all_pods_are_ready.py
  # kubectl wait might be better, but it does include the completed jobs pods now and does not terminate so
  # time kubectl wait --namespace=kube-system --for=condition=Ready --timeout=600s --all pods
}

function list_nodes_and_pods() {
  echo -e "\nlist all nodes and pods\n"
  kubectl get nodes --sort-by=.metadata.name
  echo ""
  kubectl get pods -o wide | grep -v READY |awk '{print $7"          "$1"          "$2}' | sort
}

echo -e "\nset up a 3 node cluster\n"
k3d cluster create eks-drain -a 6
kubectl cordon k3d-eks-drain-server-0
# simulate having only 3 node cluster
for i in 3 4 5
do
  kubectl cordon k3d-eks-drain-agent-$i;
done

helm repo add bitnami https://charts.bitnami.com/bitnami
echo -e "\ninstall some slow booting pods\n"
helm install slow-app bitnami/nginx -f slow.yaml

wait_until_all_pods_are_ready

echo -e "\nscale up to a 6 node cluster\n"
# simulate addinf 3 new nodes
for i in 3 4 5
do
  kubectl uncordon k3d-eks-drain-agent-$i
done

list_nodes_and_pods

for i in 0 1 2
do
  echo -e "\ndraining node k3d-eks-drain-agent-$i\n"
  kubectl drain k3d-eks-drain-agent-$i --ignore-daemonsets --delete-emptydir-data
  wait_until_all_pods_are_ready
done

echo -e "\nlooks like all nodes are drained\n"

list_nodes_and_pods

echo -e "\ncleaning up\n"
k3d cluster delete eks-drain
