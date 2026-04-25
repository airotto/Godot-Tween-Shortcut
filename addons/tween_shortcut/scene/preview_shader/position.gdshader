shader_type canvas_item;

uniform float progress = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (UV.x <= abs(progress)){
		if (progress >= 0.0){
			if (progress > 1.0 && 1.0 - UV.x < progress - 1.0){//1超えてたら青
				COLOR = vec4(0,0,1,1);
			}
			else{
				COLOR = vec4(1,1,1,0.2);
			}
		}
		else{
			COLOR = vec4(1,0,0,1);
		}
	}
	else{
		COLOR = vec4(0,0,0,0);
	}
	
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
