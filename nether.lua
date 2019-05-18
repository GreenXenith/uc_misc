minetest.register_node("uc_misc:rack", {
	description = "Netherrack",
	tiles = {"nether_rack.png"},
	is_ground_content = false,
	groups = {cracky = 3, level = 2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("uc_misc:sand", {
	description = "Nethersand",
	tiles = {"nether_sand.png"},
	is_ground_content = false,
	groups = {crumbly = 3, level = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults({
		footstep = {name = "default_gravel_footstep", gain = 0.45},
	}),
})

minetest.register_node("uc_misc:glowstone", {
	description = "Glowstone",
	tiles = {"nether_glowstone.png"},
	is_ground_content = false,
	light_source = 14,
	paramtype = "light",
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("uc_misc:brick", {
	description = "Nether Brick",
	tiles = {"nether_brick.png"},
	is_ground_content = false,
	groups = {cracky = 2, level = 2},
	sounds = default.node_sound_stone_defaults(),
})

local fence_texture =
	"default_fence_overlay.png^nether_brick.png^default_fence_overlay.png^[makealpha:255,126,126"

minetest.register_node("uc_misc:fence_nether_brick", {
	description = "Nether Brick Fence",
	drawtype = "fencelike",
	tiles = {"nether_brick.png"},
	inventory_image = fence_texture,
	wield_image = fence_texture,
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {cracky = 2, level = 2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(":default:obsidian", {
	description = "Obsidian",
	tiles = {"default_obsidian.png"},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky = 1, level = 2},
})

-- Register stair and slab

if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("uc_misc", "brick", "uc_misc:brick", {
		description = "Nether Brick",
		groups = {cracky = 2, level = 2},
		tiles = {"nether_brick.png"},
		sounds = default.node_sound_stone_defaults(),
	})
	stairsplus:register_alias_all("nether", "brick", "uc_misc", "brick")
	stairsplus:register_all("uc_misc", "rack", "uc_misc:rack", {
		description = "Nether Rack",
		groups = {cracky = 2, level = 2},
		tiles = {"nether_rack.png"},
		sounds = default.node_sound_stone_defaults(),
	})
	stairsplus:register_alias_all("nether", "rack", "uc_misc", "rack")
else
	stairs.register_stair_and_slab(
		"nether_brick",
		"uc_misc:brick",
		{cracky = 2, level = 2},
		{"nether_brick.png"},
		"Nether Stair",
		"Nether Slab",
		default.node_sound_stone_defaults()
	)
	stairs.register_stair_and_slab(
		"nether_rack",
		"uc_misc:rack",
		{cracky = 2, level = 2},
		{"nether_rack.png"},
		"Nether Rack Stair",
		"Nether Rack Slab",
		default.node_sound_stone_defaults()
	)
end

-- Crafts

minetest.register_craft({
	output = "uc_misc:rack 8",
	recipe = {
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "ethereal:fire_dust", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"},
	}
})

technic.register_grinder_recipe({
	input = {"uc_misc:rack"},
	output = "uc_misc:sand",
	time = 6,
})

minetest.register_craft({
	output = "uc_misc:brick 4",
	recipe = {
		{"uc_misc:rack", "uc_misc:rack"},
		{"uc_misc:rack", "uc_misc:rack"},
	}
})

minetest.register_craft({
	output = "uc_misc:fence_nether_brick 6",
	recipe = {
		{"uc_misc:brick", "uc_misc:brick", "uc_misc:brick"},
		{"uc_misc:brick", "uc_misc:brick", "uc_misc:brick"},
	},
})

minetest.register_craft({
	output = "uc_misc:glowstone 9",
	recipe = {
		{"uc_misc:rack", "uc_misc:rack", "uc_misc:rack"},
		{"uc_misc:rack", "ethereal:glostone", "uc_misc:rack"},
		{"uc_misc:rack", "uc_misc:rack", "uc_misc:rack"},
	}
})

-- Aliases

minetest.register_alias("nether:rack", "uc_misc:rack")
minetest.register_alias("nether:sand", "uc_misc:sand")
minetest.register_alias("nether:glowstone", "uc_misc:glowstone")
minetest.register_alias("nether:brick", "uc_misc:brick")
minetest.register_alias("nether:fence_nether_brick", "uc_misc:fence_nether_brick")
