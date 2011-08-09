# Hang on, it's quite the mess...
$ ->
  interval     = 1
  end_date     = Date.today().add(1).days()
  start_date   = Date.today().add(- interval).months()
  jobs_path    = '/jobs/where/kind/print'

  ##
  # Fetch jobs between start and end dates, then call the user's callback.
  #
  # @param {Date}     Start date
  # @param {Date}     End date
  # @param {Function} Called with an Array of every fetched Job.
  fetch_jobs = (start, end, cb) ->
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
      path = jobs_path + '?' + $.param(request_params)

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
  # Map/Reduce jobs by day.
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

    # Finally format data: jobs['yyyy-mm-dd'] = somevalue
    data.forEach (j) ->
      [x, c] = [ j[0].toString("yyyy-MM-dd"), j[1] ]
      jobs[x] += c
    jobs

  ##
  # Draws a graph listing jobs by day.
  #
  # @param  {Array}  job list as passed by to fetch_jobs callback
  # @return {Object} Hash mapping dates to their job count
  draw_daily = (jobs, node) ->
    data = ({time: k, value: jobs[k]} for k in Object.keys(jobs))
    values = (k['value'] for k in data)
    h = 300
    w = 25

    scale_x = d3.scale.linear()
             .domain([0, 1])
             .range([0, w])
    scale_y = d3.scale.linear()
              .domain([0, d3.max(values)])
              .rangeRound([0, h])

    chart = d3.select(node)
              .append("svg:svg")
                .attr("class", "chart")
                .attr("width", w * data.length - 1)
                .attr("height", h)

    # Pad left to draw horizontal lines
    d3.select(".content")
    .append("svg:svg")
      .attr("class", "chart")
      .attr("width", w * data.length - 1)
      .attr("height", h)
    .append("svg:g")
      .attr("transform", "translate(15,10)");

    # Horizontal lines
    chart.selectAll("line")
         .data(scale_y.ticks(5))
       .enter().append("svg:line")
         .attr("x1", 0)
         .attr("x2", w * data.length - 1)
         .attr("y1", scale_y)
         .attr("y2", scale_y)
         .attr("stroke", "#ccc")

    #chart.selectAll("text.rule")
    #    .data(scale_y.ticks(5))
    #    .sort((a, b) -> b <=> a)
    #  .enter().append("svg:text")
    #    .attr("class", "rule")
    #    .attr("x", 0)
    #    .attr("y", scale_y)
    #    .attr("dx", 3)
    #    .text(String)

    # Draw bars
    chart.selectAll("rect").data(data)
      .enter().append("svg:rect")
        .attr("x", (d, i) -> scale_x(i) - .5)
        .attr("y", (d) -> h - scale_y(d.value) - .5)
        .attr('width', w)
        .attr('height', (d) -> scale_y(d.value))

    # Bottom line
    chart.append("svg:line")
        .attr("x1", 0)
        .attr("x2", w * data.length)
        .attr("y1", h - .5)
        .attr("y2", h - .5)
        .attr("stroke", "#000")

    # Draw text
    chart.selectAll("text")
         .data(data)
       .enter().append("svg:text")
         .attr("x", (d, i) -> scale_x(i) - .5)
         .attr("y", (d) -> h - scale_y(d.value) + 12)
         .attr("dx", 3) # padding-left
         .text((x) -> x.value)




  # ---------------------------------------------------------------------------
  # That your entry point!

  title = $('h1').text()
  $('h1').text title + ' between: ' + start_date.toString('dd/MM/yyyy') +
                       ' and ' + end_date.toString('dd/MM/yyyy') 

  console.log "Fetching jobs between " + start_date + " and " + end_date

  fetch_jobs start_date, end_date, (list) ->
    console.log "Fetched " + list.length + " jobs."

    jobs = daily_count ([Date.parse(x.created_at), x.copy_num * x.doc_num] for x in list), start_date, end_date
    draw_daily jobs, ".graph"
