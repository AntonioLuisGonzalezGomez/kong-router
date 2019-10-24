local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local ngx_re_gmatch = ngx.re.gmatch

local _M = {}

local function retrieve_token(request, conf)
    local is_the_token_in_a_header_instead_of_a_cookie = conf.is_the_token_in_a_header_instead_of_a_cookie
    local authorization_header

    if is_the_token_in_a_header_instead_of_a_cookie then
        kong.log.debug("Retrieving token from header")
        authorization_header = request.get_headers()["Authorization"]
    else
        kong.log.debug("Retrieving token from cookie")
        authorization_header = ngx.var.cookie_Authorization
    end
    if authorization_header then
        local iterator, iter_err = ngx_re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
        if not iterator then
            return nil, iter_err
        end

        local m, err = iterator()
        if err then
            return nil, err
        end

        if m and #m > 0 then
            return m[1]
        end
    end
end

function _M.execute(conf)
    kong.log.debug("Executing kong-router plugin")
    local continue_on_error = conf.continue_on_error
    local token, err = retrieve_token(ngx.req, conf)

    kong.log.debug("Token retrieved")
    if err and not continue_on_error then
        kong.log.err(err)
        return kong.response.exit(401, "Error retrieving JWT token")
    end

    if not token and not continue_on_error then
        kong.log.err("Unauthorized")
        return kong.response.exit(401, "Token required")
    elseif not token and continue_on_error then
        kong.log.err("Token is empty")
        return kong.response.exit(401, "Token is empty")
    end

    local jwt, err_new = jwt_decoder:new(token)
    if err_new and not continue_on_error then
        kong.log.err("Internal server error")
        return kong.response.exit(500, "Internal server error")
    end
    kong.log.debug("Token decoded")

    local claims = jwt.claims
    for claim_key, claim_value in pairs(claims) do
        if string.match(claim_key, "^" .. conf.claim_where_the_upstream_name_is_located .. "$") then
            kong.log.debug("Setting upstream to: " .. conf.upstream_name_prefix .. tostring(claim_value))
            local ok, err_set_us = kong.service.set_upstream(conf.upstream_name_prefix .. tostring(claim_value))
            if not ok then
                kong.log.err(err_set_us)
                return kong.response.exit(404, "Destination upstream not found")
            end
            kong.log.debug("The upstream has been correctly set: " .. conf.upstream_name_prefix .. tostring(claim_value))
        end
    end
end

return _M