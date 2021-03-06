---
apiVersion: "v1"
kind: "Service"
metadata:
  name: "bsm-api-deployment-service"
  namespace: "default"
  labels:
    app: "bsm-api"
spec:
  ports:
  - protocol: "TCP"
    port: 8080
  selector:
    name: "bsm-api"
  type: "LoadBalancer"
  loadBalancerIP: "${lb}"



