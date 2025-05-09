shader_type canvas_item;
// Source: https://godotshaders.com/shader/gaussian-blur-2/
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture,repeat_disable, filter_nearest;
uniform float sigma: hint_range(0.0, 20.0) = 3.3; // Limited to 20 because of performance, if you want feel free to break it.

float gaussianDistribution(float x, float STD){ // STD stands for standard deviation
	return exp(-(x*x)/(2.*STD*STD))/(sqrt(2.*PI)*STD);
}

vec3 gaussianblur(sampler2D sampler, vec2 pos, vec2 pixel_size, float sigmaUsed, int radius){
    vec3 blurredPixel = vec3(0.0);
    float total_weight = 0.0;
	// Loop over the radius (tecnically its a square)
    for(int i = -radius ; i <= radius; i++){
        for(int j = -radius; j <= radius; j++){
			// Calculate the offset from the current pixel
			vec2 offset = vec2(float(i), float(j))*pixel_size;
			vec2 changedPos = pos + offset;

			// Calculate the weight based on the Gaussian distribution multiplying both dimentions (how far are X and Y form the center (pos))
			float weight = gaussianDistribution(float(i), sigmaUsed)*gaussianDistribution(float(j), sigmaUsed);
			// Add the weighted color value to the blurred pixel
			blurredPixel += texture(sampler, changedPos).rgb * weight;
			total_weight += weight;
        }
    }
	// Normalize the blurred pixel color by the total weight
	blurredPixel/=total_weight;
    return blurredPixel;
}
void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (sigma >= 0.01){
		vec3 PixelBlurred = gaussianblur(SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE, sigma, int(round(3.0 * sigma)));
    	// The radius is 3*Sigma because it is the point where the Gaussian weight is near zero.
    	COLOR = vec4(PixelBlurred, 1.0);
	}
}
