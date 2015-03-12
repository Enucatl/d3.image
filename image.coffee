---
---

class d3.chart.Image extends d3.chart.BaseChart

    constructor: ->
        @accessors = {} unless @accessors?
        @accessors.original_width = 0
        @accessors.original_height = 0
        @accessors.color_value = (d) -> d.name
        @accessors.color_scale = d3.scale.linear()
        super

    _draw: (element, data, i) ->
        # convenience accessors
        width = @width()
        height = @height()
        original_width = @width()
        original_height = @height()
        margin = @margin()
        color_value = @color_value()
        color_scale = @color_scale()

        #select the svg if it exists
        canvas = d3.select element
            .selectAll "canvas"
            .data [data]

        #otherwise create the skeletal chart
        g_enter = canvas.enter()
            .append "canvas"

        #update the dimensions
        canvas
            .attr "width", original_width
            .attr "height", original_height
            .style "width", width + "px" 
            .style "height", height + "px" 
            .style "margin-top", margin.top + "px" 
            .style "margin-left", margin.left + "px" 
            .style "margin-bottom", margin.bottom + "px" 
            .style "margin-right", margin.right + "px" 

        #fix color scale
        color_scale
            .range ["white", "black"]

        context = canvas.node()
            .getContext "2d"
        image = context.createImageData original_width, original_height 
        p = -1
        for pixel in data
            c = d3.rgb color_scale color_value pixel
            image.data[++p] = c.r;
            image.data[++p] = c.g;
            image.data[++p] = c.b;
            image.data[++p] = 255;
        context.imageSmoothingEnabled = false
        context.putImageData image, 0, 0
