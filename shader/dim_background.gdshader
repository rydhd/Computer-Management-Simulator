shader_type canvas_item;

// The width of the taskboard (0.0 to 1.0)
uniform float board_width : hint_range(0.0, 1.0) = 0.55;
// Where the darkness starts from the top
uniform float top_margin : hint_range(0.0, 1.0) = 0.11;
uniform float darkness : hint_range(0.0, 1.0) = 0.7;
uniform float edge_softness : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec2 uv = UV;

    // 1. Calculate horizontal mask (Left and Right sides)
    float horiz_dist = abs(uv.x - 0.5);
    float horiz_mask = smoothstep(board_width * 0.5, (board_width * 0.5) + edge_softness, horiz_dist);

    // 2. Calculate vertical mask for the TOP only
    float top_mask = smoothstep(top_margin + edge_softness, top_margin, uv.y);

    // 3. Combine: We want darkness IF we are outside the horizontal width
    // AND below the top margin.
    float final_mask = horiz_mask;

    // This part ensures the area ABOVE the board is also dark
    if (uv.y < top_margin) {
        final_mask = 1.0;
    }

    COLOR = vec4(0.0, 0.0, 0.0, final_mask * darkness);
}