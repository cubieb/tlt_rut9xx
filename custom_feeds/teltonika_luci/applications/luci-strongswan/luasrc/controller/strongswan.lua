--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: openvpn.lua 7362 2011-08-12 13:16:27Z jow $
]]--

module("luci.controller.strongswan", package.seeall)

function index()
	entry( {"admin", "services", "vpn", "ipsec"},  arcombine(cbi("strongswan_add"), cbi("strongswan_edit")), _("IPsec"), 2).leaf=true
end
