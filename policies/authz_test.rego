package agentgateway.authz

# Builds an ext_authz CheckRequest input document like agentgateway sends: the
# identity in the lowercased `x-user-id` header and the model in the JSON body.
request(user, model) := {"attributes": {"request": {"http": {
	"headers": {"x-user-id": user},
	"body": json.marshal({"model": model}),
}}}}

test_alice_gpt4o_allowed_via_org if {
	allow with input as request("alice", "gpt-4o")
}

test_bob_gpt4o_allowed_via_org if {
	allow with input as request("bob", "gpt-4o")
}

test_bob_claude_allowed_via_team if {
	allow with input as request("bob", "claude-sonnet-5")
}

test_alice_claude_denied if {
	not allow with input as request("alice", "claude-sonnet-5")
}

test_erin_gpt4o_allowed_via_direct if {
	allow with input as request("erin", "gpt-4o")
}

test_dave_gpt4o_allowed_via_provider_extra if {
	allow with input as request("dave", "gpt-4o")
}

test_charlie_gpt4o_denied if {
	not allow with input as request("charlie", "gpt-4o")
}

test_mcp_user_gpt4o_allowed_via_direct if {
	allow with input as request("mcp-user", "gpt-4o")
}

test_mcp_user_gpt35_denied if {
	not allow with input as request("mcp-user", "gpt-3.5-turbo")
}

test_missing_user_denied if {
	not allow with input as {"attributes": {"request": {"http": {
		"headers": {},
		"body": json.marshal({"model": "gpt-4o"}),
	}}}}
}

test_missing_model_denied if {
	not allow with input as {"attributes": {"request": {"http": {
		"headers": {"x-user-id": "alice"},
		"body": "{}",
	}}}}
}
