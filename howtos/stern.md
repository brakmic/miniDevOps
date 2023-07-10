# How to Use Stern to Tail Kubernetes Logs

[Stern](https://github.com/stern/stern) is a log tailing tool designed for Kubernetes. Stern can tail logs from multiple pods simultaneously, and even use regex patterns to define which pods' logs to show. Here's a simple guide on how to use it:

## 1. Launch the Docker Image

This Docker image already has Stern installed. If you're not already running it, launch it with:

```bash
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}:/root/local --rm --network=host --workdir /root brakmic/devops:latest
```

## 2. Utilize Bash Completion

The Bash completion scripts for Stern are already installed. You can start typing a Stern command and press the `TAB` key to see possible completions. For example, start typing `stern --` and then press `TAB`:

```bash
stern --
```

It will display all available flags:

```bash
--all-namespaces        --container             --exclude               --field-selector=       --max-log-requests      --only-log-lines        --since=                --timestamps

--color                 --container-state       --exclude-container     --help                  --max-log-requests=     --output                --tail                  --timezone

--color=                --container-state=      --exclude-container=    --include               --namespace             --output=               --tail=                 --timezone=

--completion            --container=            --exclude-pod           --include=              --namespace=            --prompt                --template              --verbosity

--completion=           --context               --exclude-pod=          --init-containers       --no-follow             --selector              --template-file         --verbosity=

--config                --context=              --exclude=              --kubeconfig            --node                  --selector=             --template-file=        --version

--config=               --ephemeral-containers  --field-selector        --kubeconfig=           --node=                 --since                 --template=
```

If you type `stern` followed by a space and then press `TAB`, it will show you the available resources in your Kubernetes cluster that you can tail logs from, like pods and containers:

```bash
stern <TAB>
```

You'll get a list of resources like this:

```bash
daemonset/              deployment/             job/                    pod/                    replicaset/

replicationcontroller/  service/                statefulset/
```

## 3. Tail Logs

To tail logs from your pods, simply use the `stern` command followed by a regex pattern that matches the names of the pods. For example, if you have pods `some-app-1`, `some-app-2`, etc., you can tail all their logs like this:

```bash
stern some-app-
```

This command will start streaming the logs from all pods whose names start with "some-app-". If a new pod matching the pattern is created, Stern will automatically start tailing its logs too.

## 4. Filter Log Streams

Stern allows you to filter log streams using regex patterns. For example, if you want to show only the log lines that contain "ERROR", you can do this:

```bash
stern some-app- -e "ERROR"
```

## 5. Tail Multiple Containers

If your pods have multiple containers and you want to tail logs from specific containers, you can use the `-c` option:

```bash
stern some-app- -c some-container
```

This command will tail logs only from the containers named "some-container" in the pods whose names start with "some-app-".

## Note

- Stern requires access to the Kubernetes API server to find and watch pods, so you need to have the necessary permissions.
- Stern streams the logs and does not keep them. If you need to keep the logs, you should consider using a logging solution that can store logs persistently.

For more information about Stern and its capabilities, you can refer to the [GitHub page](https://github.com/stern/stern).
