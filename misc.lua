if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("ethereal", "ice", "default:ice", {
		description = "Ice",
		tiles = {"default_ice.png"},
		groups = {cracky = 3, puts_out_fire = 1, cools_lava = 1},
		sounds = default.node_sound_glass_defaults(),
	})
end

local function spawn_particles(pos, name, multiplier)
	local player = minetest.get_player_by_name(name)
	local bubble_dir = player:get_look_horizontal()
	local x_offset = (0.3 * math.cos(bubble_dir)) * multiplier
	local z_offset = (0.3 * math.sin(bubble_dir)) * multiplier
	minetest.add_particlespawner({
		amount = math.random(3,6), 
		time = 0.6,
		minpos = {x=pos.x+x_offset, y=pos.y+1.5, z=pos.z+z_offset}, 
		maxpos = {x=pos.x+x_offset, y=pos.y+1.5, z=pos.z+z_offset},
		minvel = {x=-0.1, y=1, z=-0.1},
		maxvel = {x=0.1, y=1, z=0.1},
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 0.5,
		maxexptime = 0.9,
		minsize = 0.4, 
		maxsize = 1.2,
		collisiondetection = false,
		verticle = false,
		texture = "air_bubble.png",
	})
end

local timer_mask = 0
local timer_pos = 0
local current_pos = {}

local function is_water(pos, offset)
	local name = minetest.get_node({x=pos.x, y=pos.y+offset, z=pos.z}).name
	return minetest.get_item_group(name, "water") ~= 0
end

minetest.register_globalstep(function(dtime)
	timer_mask = timer_mask + dtime;
	timer_pos = timer_pos + dtime;
	if timer_pos >= 0.5 then
		for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			current_pos[name] = player:get_pos()
		end
		timer_pos = 0
	end
	if timer_mask < math.random(4,6) then
		return
	end
	timer_mask = 0
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local inv = minetest.get_inventory({type="detached", name=name.."_armor"})
		if inv:contains_item("armor", ItemStack("uc_misc:helmet_rebreather")) then
			if player:get_breath() ~= 11 then
				player:set_breath(10)
				if is_water(pos, 1) then
					minetest.sound_play("breath_"..tostring(math.random(1,3)), {
						to_player = name,
						gain = 1.4,
					})
					minetest.after(2, function()
						if not is_water(current_pos[name], 1) then
							return
						else
							spawn_particles(current_pos[name], name, 1)
							spawn_particles(current_pos[name], name, -1)
						end
					end)
				end
			end
		end
	end
end)

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
		local pos = player:get_pos()
		if is_water(pos, 1) then
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

minetest.register_node("uc_misc:wing", {
	description = "Dragon Wing",
	tiles = {"default_stone.png"},
	groups = {cracky = 3, stone = 1},
	drawtype = "mesh",
	walkable = false,
	mesh = "wing.obj",
	paramtype2 = "facedir",
})