if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("ethereal", "ice", "default:ice", {
		description = "Ice",
		tiles = {"default_ice.png"},
		groups = {cracky = 3, puts_out_fire = 1, cools_lava = 1},
		sounds = default.node_sound_glass_defaults(),
	})
end
