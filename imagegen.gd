# Copyright (c) 2023 by Marcus Sacco (https://codepen.io/marcussacco/pen/JROWWK)

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


class_name ImageGen extends Node

static func poke_out(w: int = 11, h: int = 11, grain: float = 11, blockout: float = randf()) -> Image:
	var start_fill : Color = Color(randf(), randf(), randf())
	var color_range : int = 5
	var pos_x : int = 0
	var pos_y : int = 0
	var image : Image = Image.create(w, h, false, Image.FORMAT_RGBA8)

	for y in range(grain):
		for x in range(grain):
			if blockout < 0.4:
				image.fill_rect(Rect2(pos_x, pos_y, w / grain, h / grain), start_fill)
				image.fill_rect(Rect2(w - pos_x - w / grain, pos_y, w / grain, h / grain), start_fill)
				@warning_ignore("narrowing_conversion")
				pos_x += w / grain
			else:
				var div: float = 255
				if randi() % 2:
					div *= -1
				start_fill.r += color_range / div
				start_fill.g += color_range / div
				start_fill.b += color_range / div
				@warning_ignore("narrowing_conversion")
				pos_x += w / grain
			blockout = randf()
		@warning_ignore("narrowing_conversion")
		pos_y += h / grain
		pos_x = 0

	return image
