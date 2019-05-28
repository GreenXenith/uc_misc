--[[ Fairies ]]--
minetest.register_node("uc_misc:orchid", {
	description = "Dragon Orchid",
	drawtype = "plantlike",
	waving = 1,
	tiles = {"orchid.png"},
	use_texture_alpha = true,
	inventory_image = "orchid.png",
	wield_image = "orchid.png",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "degrotate",
	light_source = 4,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flower = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-2 / 16, -0.5, -2 / 16, 2 / 16, 0.4, 2 / 16},
	},
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		if node.name == "default:dirt_with_grass" then
			return minetest.item_place(itemstack, placer, pointed_thing, math.random(0, 179))
		end
	end,
})

minetest.register_node("uc_misc:orchid_seeds", {
	description = "Orchid Seeds",
	tiles = {"orchid_seeds.png"},
	inventory_image = "orchid_seeds.png",
	wield_image = "orchid_seeds.png",
	drawtype = "signlike",
	groups = {snappy = 3, attached_node = 1, flammable = 2},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
	sounds = default.node_sound_dirt_defaults({
		dig = {name = "", gain = 0},
		dug = {name = "default_grass_footstep", gain = 0.2},
		place = {name = "default_place_node", gain = 0.25},
	}),
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local under = vector.subtract(pos, {x = 0, y = 1, z = 0})
		local node = minetest.get_node(under)
		if node.name == "default:dirt_with_grass" then
			minetest.set_node(pos, {name = "uc_misc:orchid", param2 = math.random(0, 179)})
		end
	end,
})

minetest.register_craft({
	output = "uc_misc:orchid_seeds",
	type = "shapeless",
	recipe = {"farming:wheat", "uc_misc:pixie_dust"},
})

local function get_time()
	return minetest.get_timeofday() * 24000
end

local function add_fairy(pos)
	local fairy = minetest.add_entity(pos, "uc_misc:fairy")
	fairy:set_armor_groups({immortal = 1})
end

minetest.register_abm({
	nodenames = {"uc_misc:orchid"},
	interval = 20,
	chance = 30,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- Only spawn at night
		if get_time() < 4500 or get_time() > 20000 then
			add_fairy({x=pos.x,y=pos.y+0.3,z=pos.z})
		end
	end
})

local function capture(entity, player)
	local inv = minetest.get_inventory({type = "player", name = player:get_player_name()})
	local fairy_bottle = ItemStack("uc_misc:fairy_bottle")
	if player:get_wielded_item():get_name() == "vessels:glass_bottle" and inv:room_for_item("main", fairy_bottle) then
		local widx = player:get_wield_index()
		local wielded = inv:get_stack("main", widx)
		wielded:take_item(1)
		inv:set_stack("main", widx, wielded)
		inv:add_item("main", fairy_bottle)
		entity.object:remove()
	end
end

minetest.register_entity("uc_misc:fairy", {
	visual = "mesh",
	mesh = "fairy.b3d",
	physical = true,
	textures = {"fairy.png",},
	visual_size = {x=1.2, y=1.2},
	-- The next 2 values do nothing until 0.5.0 (forwards-compat!)
	glow = 10,
	use_texture_alpha = true,
	on_activate = function(self)
		local num = math.random(1,4)
		self.object:set_animation({x=1, y=20}, 40, 0)
		self.object:set_yaw(math.pi+num)
		-- Despawn after 30 seconds
		minetest.after(30, function()
		self.object:remove()
		end)
	end,
	on_step = function(self)
		-- Only spawn at night
		if get_time() < 4500 or get_time() > 20000 then
			-- Speed multiplier
			local speed = 3
			local vel = self.object:get_velocity()
			local yaw = self.object:get_yaw()
			local num = math.random(-(math.pi/180), (math.pi/180))
			-- Change yaw by one degree (-/+) every step
			self.object:set_yaw(yaw+num)
			-- Get velocity from yaw
			-- Negative math.sin(yaw) because Minetest"s axis are screwed up
			self.object:set_velocity({x=-math.sin(yaw)*speed, y=num*speed, z=math.cos(yaw)*speed})
			self.object:set_acceleration({x=-math.sin(6*vel.y), y=math.cos(6*vel.x), z=-math.sin(6*vel.y)})
			-- Magic dust stuff
			minetest.add_particlespawner({
				amount = 2,
				time = 0.2,
				minpos = {x=0, y=0, z=0},
				maxpos = {x=0, y=0, z=0},
				minvel = {x=-0.1, y=0, z=-0.1},
				maxvel = {x=0.1, y=-1, z=0.1},
				minacc = {x=0, y=-0.1, z=0},
				maxacc = {x=0, y=0.1, z=0},
				minexptime = 2,
				maxexptime = 3,
				minsize = 0.4,
				maxsize = 0.6,
				collisiondetection = true,
				collision_removal = true,
				attached = self.object,
				vertical = false,
				texture = "drop_particle.png",
				glow = 8
			})
			-- Randomly drop some things
			-- {"nodename", chance}
			local drops = {
				{"uc_misc:orchid", 1},
				{"uc_misc:orb", 3},
				{"uc_misc:galaxium_ingot", 5},
				{"default:diamond_block", 7},
				{"default:diamond", 10}
			}
			for k, v in ipairs(drops) do
				-- The chance range is really big because this is run every millisecond
				local drop_chance = math.random(1,1000000)
				if drop_chance >= 1 and drop_chance <= v[2] then
					minetest.add_item(self.object:get_pos(), v[1])
					return
				end
			end
			return
		end
		-- Disappear if daytime
		self.object:remove()
	end,
	on_rightclick = capture,
	on_punch = capture,
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
})

-- Fairy in a bottle
minetest.register_node("uc_misc:fairy_bottle", {
	description = "Fairy in a Bottle",
	inventory_image = "fairy_bottle.png",
	wield_image = "fairy_bottle.png",
	tiles = {{
		name = "fairy_bottle_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1.5
		},
	}},
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 9,
	walkable = false,
	groups = {oddly_breakable_by_hand = 3, attached_node = 1},
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	sounds = default.node_sound_glass_defaults(),
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		add_fairy({x=pos.x,y=pos.y+0.3,z=pos.z})
		minetest.set_node(pos, {name = "vessels:glass_bottle"})
	end,
	on_punch = function(pos, node)
		if get_time() < 4500 or get_time() > 20000 then
			if math.random(1, 100) == 1 then
				local dpos = table.copy(pos)
				dpos.y = dpos.y + 0.2
				local dust = minetest.add_item(dpos, ItemStack("uc_misc:pixie_dust "..math.random(1, 2)))
				dust:set_velocity({x = math.random(-2, 2), y = 2.9, z = math.random(-2, 2)})
			end
		end
	end,
})

minetest.register_craftitem("uc_misc:pixie_dust", {
	description = "Pixie Dust",
	inventory_image = "pixie_dust.png",
})

-- Decorative light thing
minetest.register_node("uc_misc:orb", {
	description = "Light Orb",
	drawtype = "mesh",
	mesh = "orb.obj",
	tiles = {"glow_orb.png"},
	use_texture_alpha = true,
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 8,
	walkable = true,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
	},
})

minetest.register_craft({
	output = "uc_misc:orb",
	recipe = {
		{"", "uc_misc:pixie_dust", ""},
		{"uc_misc:pixie_dust", "default:glass", "uc_misc:pixie_dust"},
		{"", "uc_misc:pixie_dust", ""}
	}
})
