# Hang on, it's quite the mess...
$ ->
  interval     = 1
  end_date     = Date.today().add(1).days()
  start_date   = Date.today().add(- interval).months()
  jobs_path    = '/jobs/where/kind/'
  graph_height = 400
  chart        = null

  ##
  # Fetch jobs between start and end dates, then call the user's callback.
  #
  # @param {Date}     Start date
  # @param {Date}     End date
  # @param {Function} Called with an Array of every fetched Job.
  fetch_jobs = (start, end, kind, cb) ->
    pages       = 0
    jobs        = []
    after_date  = start.toString("yyyy-MM-dd")
    before_date = end.toString("yyyy-MM-dd")

    # Fetches paginated data from the API, calls callee's
    # cb function after all pages have been fetched.
    #
    # @param {Integer} page (default: 1)
    fetch_page = (page = 1) ->
      request_params =
        page:   page,
        before: before_date,
        after:  after_date
      path = jobs_path + kind + '?' + $.param(request_params)

      # Go fetch!
      $.ajax
        url: path,
        success: (data, state, req) ->
          Array.prototype.push.apply jobs, data
          total_pages = req.getResponseHeader 'X-Total-Pages'
          if page < total_pages
          	fetch_page page + 1
          else
          	cb jobs
        dataType: 'json'
    fetch_page()

  ##
  # Map/Reduce job count by day.
  #
  # @param  {Array}  job list as passed by to fetch_jobs callback
  # @return {Object} Hash mapping dates to their job count
  daily_count = (data, start, end) ->
    jobs = {}
    # Initialize job counts at 0 for each day.
    initialize_zero = (d) ->
      jobs[d.toString("yyyy-MM-dd")] = 0
      initialize_zero d.addDays(1) if d.isBefore end
    initialize_zero start

    # Finally, format data: jobs['yyyy-mm-dd'] = somevalue
    data.forEach (j) ->
      [x, c] = [ j[0].toString("yyyy-MM-dd"), j[1] ]
      jobs[x] += c
    jobs

  ##
  # Initialize charting area:
  #   - create chart zone
  #   - add horizontal lines
  init_chart = (node, h, w, x, y, data_size) ->
    chart ?= d3.select(node)
              .append("svg:svg")
                .attr("class", "chart")
                .attr("width", w * data_size - 1)
                .attr("height", h)

    # Pad left to draw horizontal lines
    d3.select(".content")
    .append("svg:svg")
      .attr("class", "chart")
      .attr("width", w * data_size - 1)
      .attr("height", h)
    .append("svg:g")
      .attr("transform", "translate(15,10)");

    # Horizontal lines
    chart.selectAll("line")
         .data(y.ticks(5))
       .enter().append("svg:line")
         .attr("x1", 0)
         .attr("x2", w * data_size - 1)
         .attr("y1", y)
         .attr("y2", y)
         .attr("stroke", "#ccc")
    chart
  
  ##
  # Draw a black line at chart's bottom.
  # @param chart a chart...
  draw_bottom_line = (chart, width, height) ->
    chart.append("svg:line")
        .attr("x1", 0)
        .attr("x2", width)
        .attr("y1", height)
        .attr("y2", height)
        .attr("stroke", "#000")
    
  ##
  # Draws a graph listing jobs by day.
  #
  # @param  {Array}   job list as passed by to fetch_jobs callback
  # @param  {Element} DOM node to start drawing
  # @param  {String}  Kind of jobs
  # @param  {Array}   job list to use as "padding"
  # @return {Object} Hash mapping dates to their job count
  draw_daily = (jobs, node, kind, prev_jobs = null) ->
    data   = ({time: k, value: jobs[k]} for k in Object.keys(jobs))
    values = (k['value'] for k in data)

    h      = graph_height
    w      = 25
    x = d3.scale.linear()
              .domain([0, 1])
              .range([0, w])
    y = d3.scale.linear()
              .domain([0, 800]) # can't use d3.max(values) sinces values changes!
              .rangeRound([0, h - 5])
    chart ?= init_chart(node, h, w, x, y, data.length)

    cumulated_value = (d, i) ->
      v = d.value
      y_coord = h - y(v) - .5
      if prev_jobs?
        prev_height = y prev_jobs[ Object.keys(prev_jobs)[i] ]
        y_coord -= prev_height
      y_coord

    # Draw bars
    chart.selectAll("rect." + kind)
         .data(data)
      .enter().append("svg:rect")
        .attr("class", kind)
        .attr("x", (d, i) -> x(i) - .5)
        .attr("y", (d, i) -> cumulated_value(d, i))
        .attr("width", w)
        .attr("title", (d, i) ->
          job_date = Object.keys(jobs)[i]
          job_date + " - " + jobs[job_date]
        )
        .attr("height", (d) -> y d.value)

    # Draw text
    chart.selectAll("text")
         .data(data)
       .enter().append("svg:text")
         .attr("x", (d, i) -> x(i) - .5)
         .attr("y", (d) -> h - y(d.value) + 12)
         .attr("dx", 3) # padding-left
         .text((x) -> x.value)
    # Bottom line
    draw_bottom_line chart, w * data.length, h - .5


  # ---------------------------------------------------------------------------
  # That your entry point!

  title = $('h1').text()
  $('h1').text title + ' between: ' + start_date.toString('dd/MM/yyyy') +
                       ' and ' + end_date.toString('dd/MM/yyyy') 

  console.log "Fetching jobs between " + start_date + " and " + end_date

  fetch_jobs start_date, end_date, 'print', (list) ->
    console.log "Fetched " + list.length + " jobs."
    jobs = daily_count(
            ([Date.parse(x.created_at), x.copy_num * x.doc_num] for x in list),
            start_date.clone(),
            end_date.clone())
    draw_daily jobs, ".graph", "print"

    fetch_jobs start_date, end_date, 'copy', (list) ->
      console.log "Fetched " + list.length + " jobs."
      prev_jobs = jobs
      jobs = daily_count(
              ([Date.parse(x.created_at), x.copy_num * x.doc_num] for x in list),
              start_date.clone(),
              end_date.clone())
      draw_daily jobs, ".graph", "copy", prev_jobs
