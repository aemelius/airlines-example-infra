. env.sh

eksctl create cluster \
--name ${CLUSTER_NAME} \
--version 1.13 \
--nodegroup-name standard-workers \
--node-type t3.medium \
--nodes 3 \
--nodes-min 1 \
--nodes-max 4 \
--node-ami auto \
-r eu-west-2
