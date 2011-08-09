(function() {
  $(function() {
    var chart, daily_count, draw_bottom_line, draw_daily, end_date, fetch_jobs, graph_height, init_chart, interval, jobs_path, start_date, title;
    interval = 1;
    end_date = Date.today().add(1).days();
    start_date = Date.today().add(-interval).months();
    jobs_path = '/jobs/where/kind/';
    graph_height = 400;
    chart = null;
    fetch_jobs = function(start, end, kind, cb) {
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
        path = jobs_path + kind + '?' + $.param(request_params);
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
    init_chart = function(node, h, w, x, y, data_size) {
            if (chart != null) {
        chart;
      } else {
        chart = d3.select(node).append("svg:svg").attr("class", "chart").attr("width", w * data_size - 1).attr("height", h);
      };
      d3.select(".content").append("svg:svg").attr("class", "chart").attr("width", w * data_size - 1).attr("height", h).append("svg:g").attr("transform", "translate(15,10)");
      chart.selectAll("line").data(y.ticks(5)).enter().append("svg:line").attr("x1", 0).attr("x2", w * data_size - 1).attr("y1", y).attr("y2", y).attr("stroke", "#ccc");
      return chart;
    };
    draw_bottom_line = function(chart, width, height) {
      return chart.append("svg:line").attr("x1", 0).attr("x2", width).attr("y1", height).attr("y2", height).attr("stroke", "#000");
    };
    draw_daily = function(jobs, node, kind, prev_jobs) {
      var cumulated_value, data, h, k, values, w, x, y;
      if (prev_jobs == null) {
        prev_jobs = null;
      }
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
      h = graph_height;
      w = 25;
      x = d3.scale.linear().domain([0, 1]).range([0, w]);
      y = d3.scale.linear().domain([0, 800]).rangeRound([0, h - 5]);
            if (chart != null) {
        chart;
      } else {
        chart = init_chart(node, h, w, x, y, data.length);
      };
      cumulated_value = function(d, i) {
        var prev_height, v, y_coord;
        v = d.value;
        y_coord = h - y(v) - .5;
        if (prev_jobs != null) {
          prev_height = y(prev_jobs[Object.keys(prev_jobs)[i]]);
          y_coord -= prev_height;
        }
        return y_coord;
      };
      chart.selectAll("rect." + kind).data(data).enter().append("svg:rect").attr("class", kind).attr("x", function(d, i) {
        return x(i) - .5;
      }).attr("y", function(d, i) {
        return cumulated_value(d, i);
      }).attr("width", w).attr("title", function(d, i) {
        var job_date;
        job_date = Object.keys(jobs)[i];
        return job_date + " - " + jobs[job_date];
      }).attr("height", function(d) {
        return y(d.value);
      });
      chart.selectAll("text").data(data).enter().append("svg:text").attr("x", function(d, i) {
        return x(i) - .5;
      }).attr("y", function(d) {
        return h - y(d.value) + 12;
      }).attr("dx", 3).text(function(x) {
        return x.value;
      });
      return draw_bottom_line(chart, w * data.length, h - .5);
    };
    title = $('h1').text();
    $('h1').text(title + ' between: ' + start_date.toString('dd/MM/yyyy') + ' and ' + end_date.toString('dd/MM/yyyy'));
    console.log("Fetching jobs between " + start_date + " and " + end_date);
    return fetch_jobs(start_date, end_date, 'print', function(list) {
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
      })(), start_date.clone(), end_date.clone());
      draw_daily(jobs, ".graph", "print");
      return fetch_jobs(start_date, end_date, 'copy', function(list) {
        var prev_jobs, x;
        console.log("Fetched " + list.length + " jobs.");
        prev_jobs = jobs;
        jobs = daily_count((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = list.length; _i < _len; _i++) {
            x = list[_i];
            _results.push([Date.parse(x.created_at), x.copy_num * x.doc_num]);
          }
          return _results;
        })(), start_date.clone(), end_date.clone());
        return draw_daily(jobs, ".graph", "copy", prev_jobs);
      });
    });
  });
}).call(this);
