apiVersion: apps/v1
kind: Deployment
metadata:
  name: shark-app
  labels:
    app: shark-app
spec:
  selector:
    matchLabels:
      app: shark-app
  template:
    metadata:
      labels:
        app: shark-app
    spec:
      containers:
      - name: shark-app
        image: ec2-35-170-208-112.compute-1.amazonaws.com/samiamoura/shark-application:GIT_COMMIT
