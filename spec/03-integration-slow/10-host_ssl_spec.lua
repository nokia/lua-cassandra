local utils = require "spec.spec_utils"
local host = require "cassandra.host"

local ca_path = utils.ssl_path.."/cassandra.pem"
local key_path = utils.ssl_path.."/client_key.pem"
local cert_path = utils.ssl_path.."/client_cert.pem"

local desc = describe
if _VERSION == "Lua 5.3" then
  -- No SSL spec for Lua 5.3 (LuaSec not compatible yet)
  desc = pending
end

desc("host SSL", function()
  setup(function()
    utils.ccm_start(1, {ssl = true, name = "ssl"})
  end)

  it("does not connect without SSL enabled", function()
    local peer = assert(host.new())

    local ok, err = peer:connect()
    assert.is_nil(ok)
    assert.equal("closed", err)
  end)
  it("connects with SSL", function()
    local peer = assert(host.new {ssl = true})
    assert(peer:connect())

    local rows, err = peer:execute "SELECT * FROM system.local"
    assert.is_nil(err)
    assert.equal(1, #rows)
  end)
  it("connects with SSL and verifying server certificate", function()
    local peer = assert(host.new {
      ssl = true,
      verify = true,
      cafile = ca_path
    })

    assert(peer:connect())

    local rows, err = peer:execute "SELECT * FROM system.local"
    assert.is_nil(err)
    assert.equal(1, #rows)
  end)
end)
