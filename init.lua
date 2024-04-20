local files = {
	"galaxium",
	"duck",
	"nether",
	"magic",
	"misc",
	"rebreather",
}

for _, file in ipairs(files) do
	dofile(("%s/%s.lua"):format(minetest.get_modpath("uc_misc"), file))
end

