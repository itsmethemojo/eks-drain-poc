# This is a POC to increase safety when updating EKS node amis

the idea about this POC is to update all your EKS nodes wit new images in a fast and least disrupting manner

## Part 1

i first experimented with draining each node whenever all pods from the last evicted node are fully up and running again

also i would start a all new nodes i will need later simultaneously before hand, to not loose time when starting them whenever i drain one

for that i used [k3d](https://github.com/rancher/k3d)

```
cd k3d
./k3d-safe-drain.sh
```

## Part 2

TODO
