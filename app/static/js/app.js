(function() {
  $(function() {
    var daily_count, draw_daily, end_date, fetch_jobs, interval, jobs_path, start_date, title;
    interval = 30;
    end_date = Date.today().add(1).days();
    start_date = Date.today().add(-interval).days();
    jobs_path = '/jobs/where/kind/print';
    fetch_jobs = function(start, end, cb) {
      var after_date, before_date, fetch_page, jobs, pages;
      pages = 0;
      jobs = [];
      after_date = start.toString("yyyy-MM-dd");
      before_date = end.toString("yyyy-MM-dd");
      fetch_page = function(page) {
        var path, request_params;
        if (page == null) {
          page = 1;
        }
        request_params = {
          page: page,
          before: before_date,
          after: after_date
        };
        path = jobs_path + '?' + $.param(request_params);
        return $.ajax({
          url: path,
          success: function(data, state, req) {
            var total_pages;
            Array.prototype.push.apply(jobs, data);
            total_pages = req.getResponseHeader('X-Total-Pages');
            if (page < total_pages) {
              return fetch_page(page + 1);
            } else {
              return cb(jobs);
            }
          },
          dataType: 'json'
        });
      };
      return fetch_page();
    };
    daily_count = function(data, start, end) {
      var initialize_zero, jobs;
      jobs = {};
      initialize_zero = function(d) {
        jobs[d.toString("yyyy-MM-dd")] = 0;
        if (d.isBefore(end)) {
          return initialize_zero(d.addDays(1));
        }
      };
      initialize_zero(start);
      data.forEach(function(j) {
        var c, x, _ref;
        _ref = [j[0].toString("yyyy-MM-dd"), j[1]], x = _ref[0], c = _ref[1];
        return jobs[x] += c;
      });
      return jobs;
    };
    draw_daily = function(jobs, node) {
      var chart, data, h, k, scale_x, scale_y, values, w;
      data = (function() {
        var _i, _len, _ref, _results;
        _ref = Object.keys(jobs);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          k = _ref[_i];
          _results.push({
            time: k,
            value: jobs[k]
          });
        }
        return _results;
      })();
      values = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          k = data[_i];
          _results.push(k['value']);
        }
        return _results;
      })();
      h = 300;
      w = 25;
      scale_x = d3.scale.linear().domain([0, 1]).range([0, w]);
      scale_y = d3.scale.linear().domain([0, d3.max(values)]).rangeRound([0, h]);
      chart = d3.select(node).append("svg:svg").attr("class", "chart").attr("width", w * data.length - 1).attr("height", h);
      d3.select(".content").append("svg:svg").attr("class", "chart").attr("width", w * data.length - 1).attr("height", h).append("svg:g").attr("transform", "translate(15,10)");
      chart.selectAll("line").data(scale_y.ticks(5)).enter().append("svg:line").attr("x1", 0).attr("x2", w * data.length - 1).attr("y1", scale_y).attr("y2", scale_y).attr("stroke", "#ccc");
      chart.selectAll("rect").data(data).enter().append("svg:rect").attr("x", function(d, i) {
        return scale_x(i) - .5;
      }).attr("y", function(d) {
        return h - scale_y(d.value) - .5;
      }).attr('width', w).attr('height', function(d) {
        return scale_y(d.value);
      });
      chart.append("svg:line").attr("x1", 0).attr("x2", w * data.length).attr("y1", h - .5).attr("y2", h - .5).attr("stroke", "#000");
      return chart.selectAll("text").data(data).enter().append("svg:text").attr("x", function(d, i) {
        return scale_x(i) - .5;
      }).attr("y", function(d) {
        return h - scale_y(d.value) + 12;
      }).attr("dx", 3).text(function(x) {
        return x.value;
      });
    };
    title = $('h1').text();
    $('h1').text(title + ' between: ' + start_date.toString('dd/MM/yyyy') + ' and ' + end_date.toString('dd/MM/yyyy'));
    console.log("Fetching jobs between " + start_date + " and " + end_date);
    return fetch_jobs(start_date, end_date, function(list) {
      var jobs, x;
      console.log("Fetched " + list.length + " jobs.");
      jobs = daily_count((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          x = list[_i];
          _results.push([Date.parse(x.created_at), x.copy_num * x.doc_num]);
        }
        return _results;
      })(), start_date, end_date);
      return draw_daily(jobs, ".graph");
    });
  });
}).call(this);
