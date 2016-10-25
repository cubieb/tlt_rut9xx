--[[
LuCI - Lua Configuration Interface

Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

local map, section, interface, empty = ...
local ifc = interface

local ipaddr, netmask, gateway, broadcast, dns, accept_ra, send_rs, ip6addr, ip6gw
local macaddr, mtu, metric
local sys = require "luci.sys"
local util = require "luci.util"

ipaddr = section:taboption("general", Value, "ipaddr", translate("IPv4 address"), translate("Your router address on the WAN (Wide Area Network)"))
netmask = section:taboption("general", Value, "netmask", translate("IPv4 netmask"), translate("A mask used to define how large the WAN (Wide Area Network) is"))
gateway = section:taboption("general", Value, "gateway", translate("IPv4 gateway"), translate("Address where the router will send all the outgoing traffic to"))
broadcast = section:taboption("general", Value, "broadcast", translate("IPv4 broadcast"), translate("Broadcast address (autogenerated if not set). It is recommended to leave it empty"))
dns = section:taboption("general", DynamicList, "dns", translate("Use custom DNS servers"), translate("By using custom DNS server the router will take care of host name resolution. You can enter multiple DNS servers"))

ipaddr.datatype = "ip4addr"

netmask.datatype = "ip4addr"
netmask.default = "255.255.255.0"
netmask:value("255.255.255.0")
netmask:value("255.255.0.0")
netmask:value("255.0.0.0")

gateway.datatype = "ip4addr"

broadcast.datatype = "ip4addr"

dns.datatype = "ipaddr"
dns.cast     = "string"

if luci.model.network:has_ipv6() then
	local value=util.trim(sys.exec("uci get -q system.ipv6.enable"))
	if tonumber(value)==1 then
		--luci.sys.call("uci delete -q network.wan6=interface; uci commit network")
		--accept_ra = s:taboption("general", Flag, "accept_ra", translate("Accept router advertisements"))
		--accept_ra = section:taboption("general", Flag, "accept_ra", translate("Accept router advertisements"))
		
		--send_rs = s:taboption("general", Flag, "send_rs", translate("Send router solicitations"))
		--send_rs = section:taboption("general", Flag, "send_rs", translate("Send router solicitations"))
		
		ip6addr = section:taboption("general", Value, "ip6addr", translate("IPv6 address"))
		ip6gw = section:taboption("general", Value, "ip6gw", translate("IPv6 gateway"))

		--accept_ra.default = accept_ra.disabled

		--send_rs.default = send_rs.enabled
		--send_rs:depends("accept_ra", "")

		ip6addr.datatype = "ip6addr"
		--ip6addr:depends("accept_ra", "")

		ip6gw.datatype = "ip6addr"
		--ip6gw:depends("accept_ra", "")
	end
end

macaddr = section:taboption("advanced", Value, "macaddr", translate("Override MAC address"), translate("Override MAC (Media Access Control) address of the WAN (Wide Area Network) interface"))
macaddr.placeholder = ifc and ifc:mac() or "00:00:00:00:00:00"
macaddr.datatype    = "macaddr"

mtu = section:taboption("advanced", Value, "mtu", translate("Override MTU"), translate("MTU (Maximum Transmission Unit) specifies the largest possible size of a data packet"))
mtu.placeholder = "1500"
mtu.datatype    = "max(1500)"

metric = section:taboption("advanced", Value, "metric", translate("Use gateway metric"), translate("The WAN (Wide Area Network) configuration generates a routing table entry by default. With this field you can alter the metric of that entry"))
metric.placeholder = "0"
metric.datatype    = "uinteger"
--[[
if empty then
	function broadcast.cfgvalue(self, section)
		return ""
	end
	function macaddr.cfgvalue(self, section)
		return ""
	end
end
]]--