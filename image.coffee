if not d3.chart?
    d3.chart = {}

d3.chart.image = ->
    pixel_height = 8
    pixel_width = 1
    margin = {top: 5, right: 0, bottom: 20, left: 20}
    dx = undefined
    dy = undefined
    color = d3.scale.linear()
    color_value = (d) -> d[0]
    dispatch = d3.dispatch "line_over", "line_out"

    chart = (selection) ->
        selection.each (data) ->

            data = data.map (d) -> d.map color_value

            #get the right key from the object
            dx = data[0].length
            dy = data.length

            height = pixel_height * dy
            width = pixel_width * dx

            #select the svg if it exists
            canvas = d3.select this
                .selectAll "canvas"
                .data [data]

            #otherwise create the skeletal chart
            g_enter = canvas.enter()
                .append "canvas"

            #update the dimensions
            canvas
                .attr "width", dx
                .attr "height", dy
                .style "width", width + "px" 
                .style "height", height + "px" 
                .style "margin-top", margin.top + "px" 
                .style "margin-left", margin.left + "px" 
                .style "margin-bottom", margin.bottom + "px" 
                .style "margin-right", margin.right + "px" 

            get_mouse_position = (event) ->
                rect = canvas.node().getBoundingClientRect()
                position = {
                    col: Math.floor (event.clientX - rect.left) / pixel_width
                    row: Math.floor (event.clientY - rect.top) / pixel_height
                }
                return position
            
            canvas.on "mousemove", ->
                position = get_mouse_position(d3.event)
                position.values = data[position.row]
                dispatch.line_over position

            #fix color scale
            flattened = data.reduce (a, b) -> a.concat b
            sorted = flattened.sort d3.ascending
            min_scale = d3.quantile sorted, 0.05
            max_scale = d3.quantile sorted, 0.95
            color
                .domain [min_scale, max_scale] 
                .nice()
                .range ["white", "black"]

            draw_image = (canvas) ->
                context = canvas
                    .node()
                    .getContext "2d"
                image = context.createImageData dx, dy 
                p = -1
                for row in data
                    for pixel in row
                        c = d3.rgb color pixel
                        image.data[++p] = c.r;
                        image.data[++p] = c.g;
                        image.data[++p] = c.b;
                        image.data[++p] = 255;
                context.imageSmoothingEnabled = false
                context.putImageData image, 0, 0

            canvas.call draw_image

    chart.pixel_width = (value) ->
        if not arguments.length
            return pixel_width
        pixel_width = value
        chart

    chart.pixel_height = (value) ->
        if not arguments.length
            return pixel_height
        pixel_height = value
        chart

    chart.key = (value) ->
        if not arguments.length
            return key
        key = value
        chart

    chart.color = (value) ->
        if not arguments.length
            return color
        color = value
        chart

    chart.height = ->
        return dy * pixel_height

    chart.width = ->
        return dx * pixel_width

    chart.color_value = (value) ->
        if not arguments.length
            return color_value
        color_value = value
        chart

    chart.margin = (value) ->
        if not arguments.length
            return margin
        margin = value
        chart

    chart.color_value = (value) ->
        if not arguments.length
            return color_value
        color_value = value
        chart

    d3.rebind chart, dispatch, "on"

    chart
