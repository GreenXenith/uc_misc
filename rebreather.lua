
-- Rebreather --

-- Spawn bubbles
local function spawn_bubbles(player, multiplier)
	local x_offset = 0.3 * multiplier
	local pos = vector.new(x_offset, 1.5, 0)

	local vel_min = vector.new(0, 0.3, -0.2)
	local vel_max = vector.new(0.4 * multiplier, 0.6, 0.2)

	local acc_min = vector.new(0, 0.5, 0)
	local acc_max = vector.new(0, 1, 0)

	minetest.add_particlespawner({
		amount = math.random(3, 5),
		time = 0.6,
		minpos = pos,
		maxpos = pos,
		minvel = vel_min,
		maxvel = vel_max,
		minacc = acc_min,
		maxacc = acc_max,
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.8,
		maxsize = 1.2,
		collisiondetection = true,
		collision_removal = false,
		attached = player,
		verticle = false,
		texture = "air_bubble.png",
	})

	minetest.add_particlespawner({
		amount = math.random(5, 8),
		time = 0.6,
		minpos = pos,
		maxpos = pos,
		minvel = vel_min,
		maxvel = vel_max,
		minacc = acc_min,
		maxacc = acc_max,
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 0.4,
		maxsize = 0.8,
		collisiondetection = true,
		collision_removal = false,
		attached = player,
		verticle = false,
		texture = "air_bubble.png",
	})
end

local timer_mask = 0

local function is_in_water(player)
	local pos = player:get_pos() + vector.new(0, player:get_properties().eye_height, 0)
	return minetest.get_item_group(minetest.get_node(pos).name, "water") ~= 0
end

minetest.register_globalstep(function(dtime)
	timer_mask = timer_mask - dtime

	if timer_mask <= 0 then
		timer_mask = math.random(4, 5)

		for _, player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local inv = minetest.get_inventory({type = "detached", name = name .. "_armor"})

			if inv and inv:contains_item("armor", ItemStack("uc_misc:helmet_rebreather")) and is_in_water(player) then
				local max_breath = player:get_properties().max_breath or minetest.PLAYER_MAX_BREATH_DEFAULT

				if player:get_breath() ~= max_breath then
					player:set_breath(max_breath)
				end

				minetest.sound_play("breath_"..tostring(math.random(1,3)), {
					to_player = name,
					gain = 1.4,
				})

				-- Spawn bubbles when exhaling
				minetest.after(2, function()
					if is_in_water(player) then
						spawn_bubbles(player, -1)
						spawn_bubbles(player, 1)
					end
				end)
			end
		end
	end
end)

-- General underwater ambience
local timer_water = 0
local handles = {}

minetest.register_globalstep(function(dtime)
	timer_water = timer_water + dtime
	if timer_water < 0.5 then
		return
	end
	timer_water = 0

	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()

		-- Is player's head underwater
		if is_in_water(player) then
			if not handles[name] then
				handles[name] = minetest.sound_play("underwater", {
					to_player = name,
					loop = true,
					gain = 2.0,
				})
			end
		elseif handles[name] then
			minetest.sound_stop(handles[name])
			handles[name] = nil
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	handles[player:get_player_name()] = nil
end)

-- The actual rebreather
armor:register_armor("uc_misc:helmet_rebreather", {
	description = "Re-breather",
	inventory_image = "uc_misc_inv_helmet_rebreather.png",
	groups = {armor_head=1, armor_use=1000},
})

minetest.register_craft({
	output = "uc_misc:helmet_rebreather",
	recipe = {
		{"", "dye:orange", ""},
		{"homedecor:plastic_sheeting", "caverealms:mushroom_gills", "homedecor:plastic_sheeting"},
		{"pipeworks:pipe_1_empty", "default:steel_ingot", "pipeworks:pipe_1_empty"},
	},
})
