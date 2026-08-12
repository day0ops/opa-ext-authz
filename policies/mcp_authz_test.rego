package agentgateway.authz

# Builds an ext_authz CheckRequest input document carrying only the
# x-api-key header, like agentgateway sends for the MCP demo route.
mcp_request(key) := {"attributes": {"request": {"http": {"headers": {"x-api-key": key}}}}}

test_valid_api_key_allowed if {
	allow with input as mcp_request("demo-mcp-api-key-12345")
}

test_invalid_api_key_denied if {
	not allow with input as mcp_request("wrong-key")
}

test_missing_api_key_denied if {
	not allow with input as {"attributes": {"request": {"http": {"headers": {}}}}}
}
