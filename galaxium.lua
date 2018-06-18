minetest.register_craftitem("uc_misc:unobtarium_ingot", {
	description = "Unobtarium Ingot",
	inventory_image = "unobtarium_ingot.png",
})

minetest.register_craftitem("uc_misc:galaxium_ingot", {
	description = "Galaxium Ingot",
	inventory_image = "galaxium_ingot.png",
})

minetest.register_craftitem("uc_misc:titanium_plate", {
	description = "Titanium Plate",
	inventory_image = "titanium_plate.png",
})

minetest.register_craftitem("uc_misc:amethyst_emblem", {
	description = "Amethyst Emblem",
	inventory_image = "emblem.png",
})

minetest.register_craftitem("uc_misc:stardust", {
	description = "Stardust",
	inventory_image = "stardust.png",
})

minetest.register_craftitem("uc_misc:crystal_dust", {
	description = "Crystal Dust",
	inventory_image = "crystal_dust.png",
})

minetest.register_craft({
	output = "uc_misc:amethyst_emblem",
	recipe = {
		{"","uc_misc:titanium_plate",""},
		{"uc_misc:titanium_plate","caverealms:glow_amethyst","uc_misc:titanium_plate"},
		{"","uc_misc:titanium_plate",""},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "uc_misc:stardust",
	recipe = {"uc_misc:crystal_dust", "ethereal:fire_dust", "cr_plus:crystal_shard"}
})

minetest.register_craft({
	output = "uc_misc:shield_galaxium",
	recipe = {
		{"uc_misc:galaxium_ingot", "uc_misc:amethyst_emblem", "uc_misc:galaxium_ingot"},
		{"uc_misc:galaxium_ingot", "uc_misc:stardust", "uc_misc:galaxium_ingot"},
		{"", "uc_misc:galaxium_ingot", ""},
	}
})

minetest.register_craft({
	output = "uc_misc:boots_galaxium",
	recipe = {
		{"uc_misc:galaxium_ingot", "", "uc_misc:galaxium_ingot"},
		{"uc_misc:galaxium_ingot", "uc_misc:stardust", "uc_misc:galaxium_ingot"},
	}
})

minetest.register_craft({
	output = "uc_misc:boots_galaxium",
	recipe = {
		{"uc_misc:galaxium_ingot", "uc_misc:stardust", "uc_misc:galaxium_ingot"},
		{"uc_misc:galaxium_ingot", "", "uc_misc:galaxium_ingot"},
	}
})

minetest.register_craft({
	output = "uc_misc:chestplate_stardust",
	recipe = {
		{"uc_misc:galaxium_ingot", "cr_plus:crystal_glass", "uc_misc:galaxium_ingot"},
		{"cr_plus:crystal_glass", "uc_misc:stardust", "cr_plus:crystal_glass"},
		{"uc_misc:galaxium_ingot", "cr_plus:crystal_glass", "uc_misc:galaxium_ingot"},
	}
})

technic.register_grinder_recipe({
	input = {"ethereal:crystal_spike"},
	output = "uc_misc:crystal_dust",
	time = 32,
})

technic.register_alloy_recipe({
	input = {"xtraores:rarium_ingot", "xtraores:unobtanium_ingot"},
	output = "uc_misc:unobtarium_ingot",
	time = 16,
})

technic.register_alloy_recipe({
	input = {"xtraores:geminitinum_ingot 3", "uc_misc:unobtarium_ingot"},
	output = "uc_misc:galaxium_ingot",
	time = 32,
})

technic.register_compressor_recipe({
	input = {"xtraores:titanium_ingot 4"},
	output = "uc_misc:titanium_plate"
})

armor:register_armor("uc_misc:shield_galaxium", {
	description = "Galaxium Shield",
	inventory_image = "inv_shield_galaxium.png",
	armor_groups = {fleshy=110},
	groups = {armor_shield=100, armor_heal=90, armor_fire=1, armor_use=10},
})

armor:register_armor("uc_misc:boots_galaxium", {
	description = "Galaxium Boots",
	inventory_image = "inv_boots_galaxium.png",
	groups = {armor_feet=1, physics_speed=1.25, physics_jump=0.55, physics_gravity=-0.1, armor_use=10},
})

armor:register_armor("uc_misc:chestplate_stardust", {
	description = "Stardust Orb",
	inventory_image = "stardust_orb.png",
	groups = {armor_torso=1, physics_gravity=-0.65, armor_use=10},
})

local materials = {
	"galaxium",
	"unobtarium",
}

for _, name in pairs(materials) do
	minetest.register_alias("uc_misc:"..name.."_bar", "uc_misc:"..name.."_ingot")
end