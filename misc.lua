--[[ Locked Bookshelf ]]--
local bookshelf_formspec =
	"size[8,7;]" ..
	default.gui_bg ..
	default.gui_bg_img ..
	default.gui_slots ..
	"list[context;books;0,0.3;8,2;]" ..
	"list[current_player;main;0,2.85;8,1;]" ..
	"list[current_player;main;0,4.08;8,3;8]" ..
	"listring[context;books]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0,2.85)

local function update_bookshelf(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local invlist = inv:get_list("books")

	local formspec = bookshelf_formspec
	-- Inventory slots overlay
	local bx, by = 0, 0.3
	local n_written, n_empty = 0, 0
	for i = 1, 16 do
		if i == 9 then
			bx = 0
			by = by + 1
		end
		local stack = invlist[i]
		if stack:is_empty() then
			formspec = formspec ..
				"image[" .. bx .. "," .. by .. ";1,1;default_bookshelf_slot.png]"
		else
			local metatable = stack:get_meta():to_table() or {}
			if metatable.fields and metatable.fields.text then
				n_written = n_written + stack:get_count()
			else
				n_empty = n_empty + stack:get_count()
			end
		end
		bx = bx + 1
	end
	meta:set_string("formspec", formspec)
	if n_written + n_empty == 0 then
		meta:set_string("infotext", "Empty Bookshelf (Owned by "..meta:get_string("owner")..")")
	else
		meta:set_string("infotext", "Bookshelf (" .. n_written ..
			" written, " .. n_empty .. " empty books, owned by "..meta:get_string("owner")..")")
	end
end

minetest.register_node("uc_misc:bookshelf_locked", {
	description = "Locked Bookshelf",
	tiles = {"default_wood.png^metal_rim.png", "default_wood.png^metal_rim.png", "default_wood.png^metal_rim.png",
		"default_wood.png^metal_rim.png", "default_bookshelf.png^metal_rim.png", "default_bookshelf.png^metal_rim.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("books", 8 * 2)
		meta:set_string("owner", placer:get_player_name())
		update_bookshelf(pos)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local inv = minetest.get_meta(pos):get_inventory()
		return owner == player:get_player_name() and inv:is_empty("books")
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if owner == player:get_player_name() then
			return count
		end
		return 0
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if owner == player:get_player_name() then
			if minetest.get_item_group(stack:get_name(), "book") ~= 0 then
				return stack:get_count()
			end
		end
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if owner == player:get_player_name() then
			if minetest.get_item_group(stack:get_name(), "book") ~= 0 then
				return stack:get_count()
			end
		end
		return 0
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" puts stuff to bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "books", drops)
		drops[#drops+1] = "default:bookshelf"
		minetest.remove_node(pos)
		return drops
	end,
})

minetest.register_craft({
	output = "uc_misc:bookshelf_locked",
	type = "shapeless",
	recipe = {"default:bookshelf", "default:steel_ingot"}
})

--[[ Undercore-themed Things ]]--

-- This is for the dragon statue(s) at spawn
minetest.register_node("uc_misc:wing", {
	description = "Dragon Wing",
	tiles = {"default_stone.png"},
	groups = {cracky = 3, stone = 1, not_in_creative_inventory = 1},
	drawtype = "mesh",
	walkable = false,
	mesh = "wing.obj",
	paramtype2 = "facedir",
})

-- Mystic-themed travelnet
if minetest.get_modpath("travelnet") then
	minetest.override_item("travelnet:travelnet", {
		description = "Travelnet",
		tiles = {
			{
				image = "travelnet_travelnet_front.png",  -- backward view
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 32,
					length = 1.5
				},
			},
			"travelnet_travelnet_back.png", -- front view
			"travelnet_travelnet_side.png", -- sides :)
			"default_stone_block.png",  -- view from top
			{
				image = "travelnet_portal.png",  -- view from bottom
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 1
				},
			},
		},
		light_source = 6,
	})
end

-- Dark dirt with grass
minetest.register_node("uc_misc:dirt_with_lush_grass", {
	description = "Dirt with Lush Grass",
	tiles = {
		"grass_lush_top.png",
		"default_dirt.png",
		"grass_lush_side.png"
	},
	is_ground_content = true,
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	})
})
