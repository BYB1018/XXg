extends Sprite2D

func _ready():
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	var tex = ImageTexture.create_from_image(image)
	self.texture = tex 
