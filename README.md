# Kubernetes zookeeper
Simple wrapper for the official zookeeper docker image.

Using kubernetes for zookeeper usually means StatefulSets. However, zookeeper requires environment variable `ZOO_MY_ID` to the unique ID of this cluster node. That unique ID should be provided by the ordinal number, which is not available in the kubernetes config file.

So we wrap the official entrypoint to determine it and then set the environment variable.


