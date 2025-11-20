helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install minio bitnami/minio -f values.yaml -n essentials
