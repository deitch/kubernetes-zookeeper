# Kubernetes zookeeper
Simple wrapper for the official zookeeper docker image.

Using kubernetes for zookeeper usually means StatefulSets. However, zookeeper requires environment variable `ZOO_MY_ID` to the unique ID of this cluster node. That unique ID should be provided by the ordinal number, which is not yet available in the kubernetes config file.

So we wrap the official entrypoint to determine it from the hostname and then set the environment variable `ZOO_MY_ID`.

Kubernetes StatefulSets append the ordinal to the hostname for the container. So if you have the following config:

```yml
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: zk
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: zk
      annotations:
    spec:
      containers:
      - name: zk
        image: zookeeper
        ports:
        - containerPort: 2181
          name: client
        - containerPort: 2888
          name: server
        - containerPort: 3888
          name: leader-election
        env:
        - name : ZOO_SERVERS
          value: server.0=zk-0:2888:3888 server.1=zk-1:2888:3888 server.2=zk-2:2888:3888
```

then it will fail, because `ZOO_MY_ID` isn't set for each. However, each container _will_ have the following hostnames:

```
zk-0
zk-1
zk-2
```

constructed from `${container_name}-${ordinal_index}`. Because of that, we can extract the ordinal from the `hostname`, and thus derive the correct `MY_ZOO_ID`

Simply use `image: deitch/kubernetes-zookeeper` instead of `image: zookeeper`.

**This is intended as a temporary fix.**

According to https://github.com/kubernetes/community/pull/147 , the ability to expose the ordinal as an env var via the downward API was merged into kubernetes, and should be released shortly. Once it does, you can go back to the library image and do:

```yml
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: zk
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: zk
      annotations:
    spec:
      containers:
      - name: zk
        image: zookeeper
        ports:
        - containerPort: 2181
          name: client
        - containerPort: 2888
          name: server
        - containerPort: 3888
          name: leader-election
        env:
        - name : ZOO_MY_ID
          valueFrom:
            fieldRef:
              fieldPath: metadata.annotations['spec.pod.beta.kubernetes.io/statefulset-index']
        - name : ZOO_SERVERS
          value: server.0=zk-0:2888:3888 server.1=zk-1:2888:3888 server.2=zk-2:2888:3888
```

