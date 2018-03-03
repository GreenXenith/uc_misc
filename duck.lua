duck = {}
local radius = 3
local function calc_velocity(pos1, pos2, old_vel, power)
	-- Avoid errors caused by a vector of zero length
	if vector.equals(pos1, pos2) then
		return old_vel
	end

	local vel = vector.direction(pos1, pos2)
	vel = vector.normalize(vel)
	vel = vector.multiply(vel, power)

	-- Divide by distance
	local dist = vector.distance(pos1, pos2)
	dist = math.max(dist, 1)
	vel = vector.divide(vel, dist)

	-- Add old velocity
	vel = vector.add(vel, old_vel)

	-- randomize it a bit
	vel = vector.add(vel, {
		x = math.random() - 0.5,
		y = math.random() - 0.5,
		z = math.random() - 0.5,
	})

	-- Limit to terminal velocity
	dist = vector.length(vel)
	if dist > 250 then
		vel = vector.divide(vel, dist / 250)
	end
	return vel
end

local function entity_physics(pos, radius, drops)
	local objs = minetest.get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:getpos()
		local dist = math.max(1, vector.distance(pos, obj_pos))

		local damage = (2 / dist) * radius
		if obj:is_player() then
			-- currently the engine has no method to set
			-- player velocity. See #2960
			-- instead, we knock the player back 1.0 node, and slightly upwards
			local dir = vector.normalize(vector.subtract(obj_pos, pos))
			local moveoff = vector.multiply(dir, dist + 2)
			local newpos = vector.add(pos, moveoff)
			newpos = vector.add(newpos, {x = 0, y = 0.8, z = 0})
			obj:setpos(newpos)

			obj:set_hp(obj:get_hp() - damage)
		else
			local do_damage = true
			local do_knockback = true
			local luaobj = obj:get_luaentity()
			local objdef = minetest.registered_entities[luaobj.name]

			if objdef and objdef.on_blast then
				do_damage, do_knockback, entity_drops = objdef.on_blast(luaobj, damage)
			end

			if do_knockback then
				local obj_vel = obj:getvelocity()
				obj:setvelocity(calc_velocity(pos, obj_pos,
						obj_vel, radius * 10))
			end
			if do_damage then
				if not obj:get_armor_groups().immortal then
					obj:punch(obj, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = damage},
					}, nil)
				end
			end
		end
	end
end

local function add_effects(pos, radius, drops)
	minetest.add_particle({
		pos = pos,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 0.4,
		size = radius * 10,
		collisiondetection = false,
		vertical = false,
		texture = "boom.png",
		glow = 15,
	})
	minetest.add_particlespawner({
		amount = 64,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -10, y = -10, z = -10},
		maxvel = {x = 10, y = 10, z = 10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = radius * 3,
		maxsize = radius * 5,
		texture = "smoke.png",
	})
end

function duck.boom(pos, def)
	def = def or {}
	def.radius = 3
	def.damage_radius = def.damage_radius or def.radius * 2
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local sound = def.sound or "explode"
	minetest.set_node(pos, {name = "air"})
	minetest.sound_play(sound, {pos = pos, gain = 1.5,
			max_hear_distance = math.min(def.radius * 20, 128)})
	local damage_radius = (radius / def.radius) * def.damage_radius
	entity_physics(pos, damage_radius, drops)
	add_effects(pos, radius, drops)
end

minetest.register_node("uc_misc:rubber_duck", {
	description = "Rubber Duck",
	tiles = {
		"rubber_y.png",
		"rubber_o.png",
		"eye.png",
		"blank.png",
	},
	inventory_image = "inv_duck.png",
	groups = {snappy = 2},
	drawtype = "mesh",
	paramtype = "light",
	use_texture_alpha = true,
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, 0.35, 0.2, 0, -0.4},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, 0.35, 0.2, 0, -0.4},
	},
	mesh = "duck.obj",
	paramtype2 = "facedir",
})

minetest.register_node("uc_misc:explody_rubber_duck", {
	description = "Explody Rubber Duck",
	tiles = {
		"rubber_y.png",
		"rubber_o.png",
		"eye.png",
		"nuke.png",
	},
	inventory_image = "inv_nuke_duck.png",
	groups = {snappy = 2},
	drawtype = "mesh",
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, 0.35, 0.2, 0, -0.4},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, 0.35, 0.2, 0, -0.4},
	},
	mesh = "duck.obj",
	paramtype2 = "facedir",
	after_place_node = function(pos, placer)
		if placer:is_player() then
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", placer:get_player_name())
		end
	end,
	on_punch = function(pos)
		duck.boom(pos, def)
	end
})

minetest.register_craftitem("uc_misc:rubber_orange", {
	description = "Orange Rubber",
	inventory_image = "rubber_orange.png",
})

minetest.register_craftitem("uc_misc:rubber_yellow", {
	description = "Yellow Rubber",
	inventory_image = "rubber_yellow.png",
})

technic.register_alloy_recipe({
	input = {"technic:rubber", "dye:orange"},
	output = "uc_misc:rubber_orange",
	time = 6,
})

technic.register_alloy_recipe({
	input = {"technic:rubber", "dye:yellow"},
	output = "uc_misc:rubber_yellow",
	time = 6,
})

minetest.register_craft({
	output = "uc_misc:rubber_duck",
	recipe = {
		{"", "uc_misc:rubber_yellow", ""},
		{"uc_misc:rubber_orange", "uc_misc:rubber_yellow", "uc_misc:rubber_yellow"},
		{"", "uc_misc:rubber_yellow", "uc_misc:rubber_yellow"},
	}
})

minetest.register_craft({
	output = "uc_misc:explody_rubber_duck",
	recipe = {
		{"", "tnt:gunpowder", ""},
		{"tnt:gunpowder", "uc_misc:rubber_duck", "tnt:gunpowder"},
		{"", "tnt:gunpowder", ""},
	}
})

minetest.register_craft({
	output = "uc_misc:rubber_duck",
	recipe = {
		{"", "uc_misc:rubber_yellow", ""},
		{"uc_misc:rubber_yellow", "uc_misc:rubber_yellow", "uc_misc:rubber_orange"},
		{"uc_misc:rubber_yellow", "uc_misc:rubber_yellow", ""},
	}
})
