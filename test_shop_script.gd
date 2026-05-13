extends SceneTree

func _init():
	var shop_script = load("res://Scripts/shop_screen.gd")
	print("shop_script: ", shop_script)
	var shop = shop_script.new()
	print("shop created")
	print("all_weapons before _ready: ", shop.all_weapons.size())
	shop._ready()
	print("all_weapons after _ready: ", shop.all_weapons.size())
	print("shop_pool after _ready: ", shop.shop_pool.size())
	quit()
