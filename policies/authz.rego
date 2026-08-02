# ReBAC-style LLM authorization for agentgateway, evaluated by OPA's
# envoy_ext_authz_grpc plugin. The decision path `agentgateway/authz/allow`
# (see config/opa-config.yaml) resolves to `data.agentgateway.authz.allow`.
package agentgateway.authz

default allow := false

# agentgateway lowercases header keys before they reach ext_authz, so the
# identity header is always the lowercase `x-user-id`.
user := input.attributes.request.http.headers["x-user-id"]

# The caller must forward the request body (forwardBody policy). It arrives as a
# raw JSON string; the target model is its top-level `model` field.
model := json.unmarshal(input.attributes.request.http.body).model

allow if {
	user != ""
	model != ""
	permitted
}

# A user directly granted this specific model.
permitted if user in data.model_direct[model]

# A user whose org is entitled to the model's provider.
permitted if {
	provider := data.model_provider[model]
	some org in data.provider_org_can_use[provider]
	user in data.org_members[org]
}

# A user with a provider-wide extra grant, independent of org/team membership.
permitted if {
	provider := data.model_provider[model]
	user in data.provider_extra_can_use[provider]
}

# A user whose team is on the model's allowlist.
permitted if {
	some team in data.model_team_allowed[model]
	user in data.team_members[team]
}
