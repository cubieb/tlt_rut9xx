--[[
LuCI - Lua Configuration Interface

Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: init.lua 6731 2011-01-14 19:44:03Z soma $
]]--

module("luci.controller.ahcp", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/ahcpd") then
		return
	end

	entry({"admin", "network", "ahcpd"}, cbi("ahcp"), _(translate("AHCP Server")), 90).i18n = "ahcp"
	entry({"admin", "network", "ahcpd", "status"}, call("ahcp_status"))
end

function ahcp_status()
	local nfs = require "nixio.fs"
	local uci = require "luci.model.uci".cursor()
	local lsd = uci:get_first("ahcpd", "ahcpd", "lease_dir") or "/var/lib/leases"
	local idf = uci:get_first("ahcpd", "ahcpd", "id_file")   or "/var/lib/ahcpd-unique-id"

	local rv = {
		uid    = "00:00:00:00:00:00:00:00",
		leases = { }
	}

	idf = nfs.readfile(idf)
	if idf and #idf == 8 then
		rv.uid = "%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X" %{ idf:byte(1, 8) }
	end

	local itr = nfs.dir(lsd)
	if itr then
		local addr
		for addr in itr do
			if addr:match("^%d+%.%d+%.%d+%.%d+$") then
				local s = nfs.stat(lsd .. "/" .. addr)
				rv.leases[#rv.leases+1] = {
					addr = addr,
					age  = s and (os.time() - s.mtime) or 0
				}
			end
		end
	end

	table.sort(rv.leases, function(a, b) return a.age < b.age end)

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end
