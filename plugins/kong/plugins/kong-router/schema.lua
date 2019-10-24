return {
  no_consumer = true,
  fields = {
    upstream_name_prefix = {type = "string", default = "upstream"},
    claim_where_the_upstream_name_is_located = {type = "string", default = ".*"},
    continue_on_error = {type = "boolean", default = false},
    is_the_token_in_a_header_instead_of_a_cookie = {type = "boolean", default = false}
  }
}