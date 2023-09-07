shader_type canvas_item;

// Uniforms
uniform sampler2D cloudNoise : repeat_enable; // Cloud noise texture
uniform vec2 cloudScroll = vec2(0.1, 0.1); // Cloud scrolling speed
uniform vec4 cloud_color : source_color; // Cloud color
uniform float cloud_threshold : hint_range(0.0, 1.0) = 0.5; // Cloud threshold
uniform float overall_alpha : hint_range(0.0, 1.0) = 1.0; // Overall alpha
uniform float cloud_speed : hint_range(0.0, 2.0) = 1.0; // Cloud speed

void fragment() {
    // Cloud effect
    float cloudDepth = texture(cloudNoise, UV + cloudScroll * TIME * cloud_speed).r; // Use cloud_speed here
    float cloudAlpha = smoothstep(cloud_threshold - 0.1, cloud_threshold + 0.1, cloudDepth);

    // Pre-multiply alpha for cloud color
    vec4 premultipliedCloudColor = vec4(cloud_color.rgb * cloudAlpha, cloudAlpha);

    // Multiply the overall alpha
    premultipliedCloudColor *= overall_alpha;

    COLOR = premultipliedCloudColor;
}
