# API-key authorization for MCP traffic, evaluated by OPA's
# envoy_ext_authz_grpc plugin via the same decision path as authz.rego
# (agentgateway/authz/allow -> data.agentgateway.authz.allow). Rego lets a
# package span multiple files, so this adds an independent allow branch for
# MCP routes without touching authz.rego's LLM/model ReBAC rules.
package agentgateway.authz

# agentgateway lowercases header keys before they reach ext_authz.
mcp_api_key := input.attributes.request.http.headers["x-api-key"]

allow if {
	mcp_api_key != ""
	mcp_api_key in data.mcp_valid_api_keys
}
