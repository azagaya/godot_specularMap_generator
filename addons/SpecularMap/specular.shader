shader_type canvas_item;
uniform sampler2D specularTexture;

uniform vec2 screen_size;
uniform float diffuse_intensity : hint_range(0,1) = 0.6;
uniform float specular_intensity : hint_range(0,1) = 0.6;
uniform float specular_scatter : hint_range(0,512) = 32;
uniform vec4 specular_color : hint_color = vec4(0.0);

void light(){
	vec4 spec_color = specular_color;
	if (spec_color == vec4(0.0))
		spec_color = LIGHT_COLOR;

	vec3 viewDir = normalize(vec3(screen_size/2.0,500.0)-FRAGCOORD.xyz);
	vec3 reflectDir = reflect(normalize(vec3(LIGHT_VEC,-LIGHT_HEIGHT)), NORMAL);
	vec4 specular_map = texture(specularTexture,UV);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), specular_scatter);

    vec3 specular =   specular_intensity * spec * spec_color.xyz * specular_map.x;

	LIGHT = vec4(vec3(specular),1.0)+diffuse_intensity*LIGHT;
}