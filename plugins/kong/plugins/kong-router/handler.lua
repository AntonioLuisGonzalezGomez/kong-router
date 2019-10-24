local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.kong-router.access"

local OtaKongRouter = BasePlugin:extend()

function OtaKongRouter:new()
  OtaKongRouter.super.new(self, "kong-router")
end

function OtaKongRouter:access(conf)
  OtaKongRouter.super.access(self)
  access.execute(conf)
end

return OtaKongRouter