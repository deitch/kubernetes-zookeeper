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

In addition, zookeeper normally listens as server and election on ports `2888` and `3888` (or whatever you config in `ZOO_SERVERS`). However, it only listens on the port specified in the entry for that file. So if you have:

```
ZOO_SERVERS=server.0=zk-0:2888:3888 server.1=zk-1:2888:3888 server.2=zk-2:2888:3888
```

then `server.0` will bind for _clients_ on all interfaces at `2181` but for leader election on `zk-0:3888`. Sometimes this is fine; sometimes you want it to bind on all interfaces there too!

To set it to bind on all interfaces (the usual situation in a container), or if your servername is not yet DNS resolvable, set the env var `ZOO_SERVER_ALL_IFACES=1`.
