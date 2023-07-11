# How to Use Skaffold for Continuous Development on Kubernetes

[Skaffold](https://skaffold.dev/) is a command-line tool designed to facilitate continuous development for Kubernetes applications. Your Docker image comes pre-installed with Skaffold, making it easy to iterate on your applications without having to manually rebuild, push, and deploy your code. Here's a step-by-step guide on how to use Skaffold:

## 1. Launch the Docker Image

Your Docker image already has Skaffold installed. If you're not already running the Docker container, launch it:

```bash
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}:/root/local --rm --network=host --workdir /root brakmic/devops:latest
```

## 2. Utilize Bash Completion

The Bash completion scripts for Skaffold are already installed and loaded in your Docker image. You can start typing a Skaffold command and press the `TAB` key to see possible completions. For example, start typing `skaffold dev --` and then press `TAB`:

```bash
skaffold dev --
```

Pressing `TAB` will display all available flags for the `skaffold dev` command.

## 3. Develop with Skaffold

Skaffold has a `dev` command that watches your source code for changes and continuously builds, pushes, and deploys your application as you write code:

```bash
skaffold dev
```

This command will start a development cycle on your application. Any changes you make to your source code will be automatically detected, and the application will be rebuilt, pushed, and redeployed to your Kubernetes cluster.

## 4. Deploy with Skaffold

You can also use Skaffold to perform a one-time deployment of your application with the `run` command:

```bash
skaffold run
```

This command will build, push, and deploy your application once, similar to how `dev` works but without watching for changes in your source code.

## 5. Validate with Skaffold

The `skaffold diagnose` command inspects your Skaffold configuration and checks it for issues:

```bash
skaffold diagnose
```

This command will output a detailed analysis of your Skaffold configuration and Kubernetes resources, helping you troubleshoot any potential issues.

## Note

- Skaffold requires access to the Kubernetes API server to deploy applications, so you need to have the necessary permissions.
- Skaffold supports a variety of build and deploy strategies, which can be configured in a `skaffold.yaml` file in your application's source code directory.

For more information about Skaffold and its capabilities, you can refer to the [GitHub page](https://github.com/GoogleContainerTools/skaffold).
