if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("ethereal", "ice", "default:ice", {
		description = "Ice",
		tiles = {"default_ice.png"},
		groups = {cracky = 3, puts_out_fire = 1, cools_lava = 1},
		sounds = default.node_sound_glass_defaults(),
	})
end

--//luatransform local meta = minetest.get_meta(pos) local node = minetest.get_node(pos) if node.name == "default:ice" then minetest.chat_send_all("ice at "..tostring(pos.x)..", "..tostring(pos.y)..", "..tostring(pos.z)) end
