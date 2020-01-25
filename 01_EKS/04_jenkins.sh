# export STORAGE_CLASS_RESOURCE_FILE=storage-class.yaml

# cat <<EoF > ${STORAGE_CLASS_RESOURCE_FILE}
# ---
# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
#   name: gp2
#   annotations:
#     "storageclass.kubernetes.io/is-default-class": "true"
# provisioner: kubernetes.io/aws-ebs
# parameters:
#   type: gp2
# reclaimPolicy: Retain
# mountOptions:
#   - debug
# EoF

# kubectl apply -f ${STORAGE_CLASS_RESOURCE_FILE}

helm install stable/jenkins
