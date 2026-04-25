shader_type canvas_item;

uniform float progress = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 center = UV - vec2(0.5, 0.5);
	float angle = atan(center.x, center.y);
	
	float normalized;
	
	
	if (progress >= 0.0){
		normalized = 1.0 - ((angle + PI) / TAU);
	}
	else{//マイナスなら左回り
		normalized = ((angle + PI) / TAU);
	}
	
	if (abs(progress) > normalized && length(center) <= 0.5){
		if (progress >= 0.0){
			if (abs(progress) - 1.0 > normalized){//1超えてたら青
				COLOR = vec4(0,0,1,1);
			}
			else{
				COLOR = vec4(1,1,1,0.2);
			}
			
		}
		else{//マイナスなら赤
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
