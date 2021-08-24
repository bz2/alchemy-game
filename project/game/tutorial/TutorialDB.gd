extends Node

const TUTORIAL = {
	"first_battle": [
		{"position": Vector2(40,40), "dimension": Vector2(1680,915), 
		 "text_side": "bottom", "text": "TUT_FB_1"},
		{"position": Vector2(830,80), "dimension": Vector2(880,800), 
		 "text_side": "bottom", "text": "TUT_FB_2",
		 "text_width": 900},
		{"position": Vector2(250,680), "dimension": Vector2(290,220), 
		 "text_side": "right", "text": "TUT_FB_3",
		"text_width": 440},
		{"position": Vector2(250,400), "dimension": Vector2(295,295), 
		 "text_side": "top", "text": "TUT_FB_4"},
		{"position": Vector2(795,800), "dimension": Vector2(200,100), 
		 "text_side": "bottom", "text": "TUT_FB_5",
		"text_width": 500},
	],
	"recipe_book": [
		{"position": Vector2(40,100), "dimension": Vector2(990,1005), 
		 "text_side": "right", "text": "TUT_RB_1"},
		{"position": Vector2(780,240), "dimension": Vector2(300,550), 
		 "text_side": "right", "text": "TUT_RB_2",
		"text_width": 500},
		{"position": Vector2(538,110), "dimension": Vector2(220,100), 
		 "text_side": "right", "text": "TUT_RB_3",
		"text_width": 420},
		{"position": Vector2(381,480), "dimension": Vector2(314,120), 
		 "text_side": "bottom", "text": "TUT_RB_4",
		"text_width": 610},
		{"position": Vector2(340,180), "dimension": Vector2(420,410), 
		 "text_side": "bottom", "text": "TUT_RB_5",
		"text_width": 540},
	],
	"clicked_recipe": [
		{"position": Vector2(250,400), "dimension": Vector2(295,295), 
		 "text_side": "right", "text": "TUT_CR_1"},
		{"position": Vector2(250,400), "dimension": Vector2(295,295), 
		 "text_side": "right", "text": "TUT_CR_2",
		"text_width": 450},
		{"position": Vector2(200,400), "dimension": Vector2(395,500), 
		 "text_side": "right", "text": "TUT_CR_3",
		"text_width": 955},
		{"position": Vector2(280,840), "dimension": Vector2(260,180), 
		 "text_side": "right", "text": "TUT_CR_4",
		"text_width": 420},
		{"position": Vector2(800,900), "dimension": Vector2(260,120), 
		 "text_side": "top", "text": "TUT_CR_5",
		"text_width": 850},
		{"position": Vector2(250,680), "dimension": Vector2(290,220),
		 "text_side": "top", "text": "TUT_CR_6",
		"text_width": 420},
		{"position": Vector2(250,680), "dimension": Vector2(290,220),
		 "text_side": "top", "text": "TUT_CR_7",
		"text_width": 420},
		{"position": Vector2(800,800), "dimension": Vector2(200,100), 
		 "text_side": "top", "text": "TUT_CR_8",
		"text_width": 500},
		{"position": Vector2(40,40), "dimension": Vector2(1680,915), 
		 "text_side": "bottom", "text": "TUT_CR_9",
		 "text_width": 900},
		{"position": Vector2(40,40), "dimension": Vector2(1680,915), 
		 "text_side": "bottom", "text": "TUT_CR_10",
		 "text_width": 900},
	],
	"map": [
		{"position": Vector2(140,340), "dimension": Vector2(1680,615),
		 "text_side": "bottom", "text": "TUT_MAP_1"},
		{"position": Vector2(620,400), "dimension": Vector2(700,500), 
		 "text_side": "top", "text": "TUT_MAP_2", "text_width": 1200},
		{"position": Vector2(420,400), "dimension": Vector2(700,500),
		 "text_side": "right", "text": "TUT_MAP_3",
		"text_width": 425, "image": "res://game/tutorial/boss-icon.png", "image_scale": 2},
		{"position": Vector2(140,340), "dimension": Vector2(1680,515),
		 "text_side": "bottom", "text": "TUT_MAP_4", "text_width": 1500},
		
	]
}


func get(name):
	assert(TUTORIAL.has(name), "Not a valid tutorial name: " + str(name))
	return TUTORIAL[name]
