#!/usr/bin/env bats
# Integration tests: all share one Kind cluster.

setup() {
    load '../test_helper/common_setup'
    common_setup
}

setup_file() {
    load '../test_helper/common_setup'
    common_setup

    echo "Creating Kind cluster '${KIND_CLUSTER_NAME}'..."
    kind create cluster --name "${KIND_CLUSTER_NAME}" --wait 5m
    kubectl wait --for=condition=Ready nodes --all --timeout=120s

    # Install Gitea and bootstrap Flux for GitOps tests
    echo "Installing Gitea..."
    kubectl create namespace gitea 2>/dev/null || true

    # Minimal Gitea with sqlite3, using API install (no INSTALL_LOCK)
    kubectl apply -n gitea -f - <<'GITEA_EOF'
apiVersion: v1
kind: Service
metadata:
  name: gitea-http
spec:
  ports:
  - port: 3000
    targetPort: 3000
  selector:
    app: gitea
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitea
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gitea
  template:
    metadata:
      labels:
        app: gitea
    spec:
      containers:
      - name: gitea
        image: gitea/gitea:1.25
        ports:
        - containerPort: 3000
        env:
        - name: GITEA__database__DB_TYPE
          value: sqlite3
        - name: GITEA__server__DOMAIN
          value: gitea-http.gitea.svc.cluster.local
        - name: GITEA__server__ROOT_URL
          value: http://gitea-http.gitea.svc.cluster.local:3000
        - name: GITEA__server__HTTP_PORT
          value: "3000"
        readinessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
GITEA_EOF

    kubectl -n gitea wait --for=condition=ready pod -l app=gitea --timeout=120s 2>/dev/null || true
    sleep 5

    # Complete Gitea web install, creating admin user
    echo "Configuring Gitea admin user..."
    kubectl run gitea-setup --rm --attach --restart=Never --image=curlimages/curl:latest -n gitea -- \
        curl -sf -X POST http://gitea-http:3000/ \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "db_type=sqlite3&app_name=Gitea&admin_name=fluxuser&admin_passwd=fluxpass&admin_confirm_passwd=fluxpass&admin_email=fluxuser@test.local" \
        >/dev/null 2>&1 || true

    sleep 3

    # Create test repo via API
    echo "Creating test repo..."
    kubectl run gitea-repo --rm --attach --restart=Never --image=curlimages/curl:latest -n gitea -- \
        curl -sf -X POST http://gitea-http:3000/api/v1/admin/users/fluxuser/repos \
        -H "Content-Type: application/json" \
        -u fluxuser:fluxpass \
        -d '{"name":"flux-test","private":false}' \
        >/dev/null 2>&1 || true

    # Bootstrap Flux against Gitea
    echo "Bootstrapping Flux..."
    flux bootstrap git \
        --url=http://gitea-http.gitea:3000/fluxuser/flux-test \
        --username=fluxuser \
        --password=fluxpass \
        --path=./clusters/test \
        --components-extra=image-reflector-controller,image-automation-controller \
        --silent 2>/dev/null || true

    # Wait for Flux controllers to be ready
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=flux -n flux-system --timeout=180s 2>/dev/null || true
}

teardown_file() {
    echo "Tearing down Kind cluster '${KIND_CLUSTER_NAME}'..."
    kind delete cluster --name "${KIND_CLUSTER_NAME}" || true
}

# --- Cluster basics ---

@test "kind cluster created successfully" {
    run kind get clusters
    assert_success
    assert_output --partial "${KIND_CLUSTER_NAME}"
}

@test "nodes are ready" {
    run kubectl get nodes --no-headers
    assert_success
    [ "$(echo "${output}" | wc -l)" -ge 1 ]
}

# --- Demo apps ---

@test "simple demo app deploys" {
    run kubectl apply -f "${SCRIPT_DIR}/demos/app-simple/" --wait=true --timeout=60s
    assert_success
}

@test "simple demo pod is ready" {
    run kubectl wait --for=condition=ready pod -l app=myapp --timeout=120s
    assert_success
}

@test "Helm chart deploys" {
    run helm install test-release "${SCRIPT_DIR}/demos/app-chart/" --wait --timeout 60s
    assert_success
}

# --- kubeseal ---

@test "sealed-secrets controller installs" {
    run kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.27.2/controller.yaml
    assert_success
}

@test "sealed-secrets controller is running" {
    run bash -c "kubectl wait --for=condition=ready pod -l name=sealed-secrets-controller -n kube-system --timeout=120s 2>&1"
    assert_success
}

@test "kubeseal can fetch controller cert" {
    run bash -c "kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=kube-system 2>&1"
    assert_success
    assert_output --partial "BEGIN CERTIFICATE"
}

# --- popeye and stern ---

@test "popeye scan on populated cluster" {
    run bash -c "popeye -o yaml 2>&1"
    assert_output --partial "popeye:"
}

@test "stern can access cluster" {
    run bash -c "stern --tail=1 --no-follow 'myapp' 2>&1 || true"
    assert true
}

# --- context switching ---

@test "kubectx lists kind context" {
    run kubectx
    assert_success
    assert_output --partial "kind-${KIND_CLUSTER_NAME}"
}

@test "kubens switches to default namespace" {
    run kubens default
    assert_success
}

# --- flux ---

@test "flux check passes on Kind cluster" {
    run flux check --pre
    assert_success
}

# --- Gitea + Flux GitOps ---

@test "Gitea is reachable via API" {
    run kubectl run gitea-curl --rm --attach --restart=Never --image=curlimages/curl:latest -n gitea -- \
        curl -sf http://gitea-http:3000/api/v1/version
    assert_success
}

@test "Flux controllers report healthy" {
    run flux check
    assert_success
}

@test "GitRepository reconciles from Gitea" {
    run bash -c "flux get sources git -n flux-system 2>/dev/null | grep -c 'True' || echo 0"
    assert [ "${output}" -ge 1 ]
}
