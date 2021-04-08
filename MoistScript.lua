
local Moistlocals = {}
Moistlocals.main_func = {}

local rootPath = utils.get_appdata_path("PopstarDevs", "2Take1Menu")

utils.make_dir(rootPath .. "\\Blacklist")

utils.make_dir(rootPath .. "\\lualogs")

utils.make_dir(rootPath .. "\\scripts\\MoistsLUA_cfg")


--TODO: Script Settings Set & save
local save_ini = rootPath .. "\\scripts\\MoistsLUA_cfg\\MoistsScript_settings.ini"

local toggle_setting, setting  = {}, {}
toggle_setting[#toggle_setting+1] = "MoistScript"
setting[toggle_setting[#toggle_setting]] = "3.0.0.0"


function saveSettings()

    local file = io.open(rootPath .. "\\scripts\\MoistsLUA_cfg\\MoistsScript_settings.ini", "w")
    io.output(file)
    for i, k in pairs(toggle_setting) do
        io.write(k.."="..tostring(setting[k]).."\n")
    end
    io.close()
end

save_ini_file = io.open(rootPath .. "\\scripts\\MoistsLUA_cfg\\MoistsScript_settings.ini", "a")
toggle = 1

if not utils.file_exists(rootPath .. "\\scripts\\MoistsLUA_cfg\\MoistsScript_settings.ini") then
    io.output(rootPath .. "\\scripts\\MoistsLUA_cfg\\MoistsScript_settings.ini")
    io.write("[MoistScript]")
    io.close()
end

function OverWriteSettingFile()
    local file = io.open(rootPath .. "\\scripts\\MoistsLUA_cfg\\MoistsScript_settings.ini", "w+")
    io.output(file)
    io.write("")
    io.close()
end


for line in io.lines(rootPath .. "\\scripts\\MoistsLUA_cfg\\MoistsScript_settings.ini") do
    local line = string.gsub(line, toggle_setting[toggle] .. "=", "")

    if toggle == 1 and setting["MoistScript"] ~= line then
    end
    if line == "true" then
        setting[toggle_setting[toggle]] = true
    elseif line == "false" then
        setting[toggle_setting[toggle]] = false
    elseif line ~= "nil" then
        if tonumber(line) ~= nil then
            setting[toggle_setting[toggle]] = tonumber(line)
        else
            setting[toggle_setting[toggle]] = line
        end
        if tostring(line) ~= nil then
			setting[toggle_setting[toggle]] = tostring(line)
        else
            setting[toggle_setting[toggle]] = line
        end

    end
    toggle = toggle + 1

end

--TODO: Function Variables
local SessionHost, ScriptHost = nil, nil


local playerFeatures, playersFeature, MoistFeat = {}, {}, {}


--TODO: Menu Feature Parents
MoistFeat.main = menu.add_feature("MoistScript 3.0.0.0 Beta", "parent", 0).id
MoistFeat.Online = menu.add_feature("Online Players", "parent", MoistFeat.main)
created_threads = menu.add_feature("Threads", "parent", 0)


--Util functions
local notif = ui.notify_above_map
local function notify_above_map(msg)
	ui.notify_above_map(tostring(msg), "MoistScript 3.0.0.0 Beta", 140)
end

local function set_waypoint(pos)
	if pos.x and pos.y then
		local coord = v2()
		coord.x = pos.x
		coord.y = pos.y
		ui.set_new_waypoint(coord)
	end
end

--Event hooks
local ChatEventID = event.add_event_listener("chat", function(e)
	local sender = player.get_player_name(e.player)
	print("<" .. sender .. "> " .. e.body)
end)

event.add_event_listener("exit", function()
	event.remove_event_listener("chat", ChatEventID)
end)


--Thread Functions
local thread, feat = {}, {}


Thread_thread = function(context)
    while true do

		system.wait(0)
    end
end

delete_threads = function(feat, data)
    menu.delete_thread(feat.data.thread)
    menu.create_thread(function(id) menu.delete_feature(id) end, feat.id)
end

function Thread(pid)
    local pid = pid
    local y = #thread + 1
    thread[y] = menu.create_thread(Thread_thread, { pid = pid } )
    local i = #feat + 1
    feat[i] = menu.add_feature("Delete Thread ".. i, "action", created_threads.id, delete_threads)
    feat[i].data = {thread = thread[y]}
end

--Player list


for pid=0,31 do
	
		
	local featureVars = {}
	
	featureVars.f = menu.add_feature("Player " .. pid, "parent", playersFeature.id)	

	local features = {}
	
	
	features["Waypoint"] = {feat = menu.add_feature("Set Waypoint On Player", "toggle", f.id, function(feat)
		if feat.on then
			for i=0,31 do
				if i ~= pid and playerFeatures[i].features["Waypoint"].feat then
					playerFeatures[i].features["Waypoint"].feat.on = false
				end
			end
		else
            ui.set_waypoint_off()
		end
		return HANDLER_POP
	end), type = "toggle", callback = function()
		set_waypoint(player.get_player_coords(pid))
	end}
	features["Waypoint"].feat.threaded = false
	
	playerFeatures[pid] = {feat = featureVars.f, scid = -1, features = features}
	featureVars.f.hidden = true
end

--Main loop

local loopFeat = menu.add_feature("Loop", "toggle", 0, function(feat)
	if feat.on then
		local Online = network.is_session_started()
		if not Online then
			SessionHost = nil
			ScriptHost = nil
		end
		local lpid = player.player_id()
		for pid=0,31 do
			local tbl = playerFeatures[pid]
			local f = tbl.feat
			local scid = player.get_player_scid(pid)
			if scid ~= 4294967295 then
				if f.hidden then f.hidden = false end
				local name = player.get_player_name(pid)
				local isYou = lpid == pid
				local tags = {}
				if Online then
					if isYou then
						tags[#tags + 1] = "Y"
					end
					if player.is_player_friend(pid) then
						tags[#tags + 1] = "F"
					end
					if player.is_player_modder(pid, -1) then
						tags[#tags + 1] = "M"
					end
					if player.is_player_host(pid) then
						tags[#tags + 1] = "H"
						if SessionHost ~= pid then
							SessionHost = pid
							notify_above_map("The session host is now " .. (isYou and "you" or name) .. ".")
						end
					end
					if pid == script.get_host_of_this_script() then
						tags[#tags + 1] = "S"
						if ScriptHost ~= pid then
							ScriptHost = pid
							notify_above_map("The script host is now " .. (isYou and "you" or name) .. ".")
						end
					end
					if tbl.scid ~= scid then
						for cf_name,cf in pairs(tbl.features) do
							if cf.type == "toggle" and cf.feat.on then
								cf.feat.on = false
							end
						end
						tbl.scid = scid
						if not isYou then
							--TODO: Modder shit
						end
					end
				end
				if #tags > 0 then
					name = name .. " [" .. table.concat(tags) .. "]"
				end
				if f.name ~= name then f.name = name end
				for cf_name,cf in pairs(tbl.features) do
					if (cf.type ~= "toggle" or cf.feat.on) and cf.callback then
						local status, err = pcall(cf.callback)
						if not status then
							notify_above_map("Error running feature " .. i .. " on pid " .. pid)
							print(err)
						end
					end
				end
			else
				if not f.hidden then
					f.hidden = true
					for cf_name,cf in pairs(tbl.features) do
						if cf.type == "toggle" and cf.feat.on then
							cf.feat.on = false
						end
					end
				end
			end
		end
		return HANDLER_CONTINUE
	end
	return HANDLER_POP
end)
loopFeat.hidden = true
loopFeat.threaded = false
loopFeat.on = true