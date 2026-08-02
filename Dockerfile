# OPA's official Envoy-enabled image already contains the envoy_ext_authz_grpc
# plugin and speaks the Envoy ext_authz v3 gRPC protocol natively - no custom
# adapter needed. This image only layers on the Rego policies and plugin config.
# The `-static` variant is a distroless image with no shell; its ENTRYPOINT is
# the exec-form ["/opa"], so CMD below is passed straight to the opa binary.
FROM openpolicyagent/opa:1.19.0-envoy-static

COPY policies /policies
COPY config /config

ENTRYPOINT ["/opa"]
CMD ["run", "--server", "--addr=0.0.0.0:8181", "--config-file=/config/opa-config.yaml", "/policies"]
