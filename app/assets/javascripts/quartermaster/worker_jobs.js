// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  nv.addGraph(function() {
    var chart = nv.models.pieChart()
      .showLegend(false)
      .x(function(d) { return d[0] })
      .y(function(d) { return d[1] });

    d3.json("/quartermaster/counts", function(data) {
      d3.select("#worker-jobs-pie-chart svg")
        .datum(data)
        .transition().duration(1200)
        .call(chart);
    });

    return chart;
  });
});

$(function() {
  $(".nav-pills-active li").click(function() {
    $(this).parent().find(".active").removeClass("active");
    $(this).addClass("active");
  });

  $("#completed-jobs-chart-type li").click(function() {
    loadChart(chart, $(this).data('url'));
  });

  function loadTable(url) {
    $.get(url).done(function(data) {
      $("#recent-jobs-table tbody").html(data);
    });
  };

  $("#recent-jobs-type li").click(function() {
    loadTable($(this).data('url'));
  });
});

$(function() {
  var chart;

  function loadChart(chart, url) {
    // This should change based on the graph type.
    chart.xAxis
      .ticks(d3.time.hour, 24 * 7)
      .tickFormat(function(d) {
        if (url.match(/minutely/)) {
          return d3.time.format('%I:%M%p')(new Date(d))
        }

        if (url.match(/hourly/)) {
          return d3.time.format('%x')(new Date(d))
        }

        if (url.match(/daily/)) {
          return d3.time.format('%x')(new Date(d))
        }
      });

    chart.tooltip(function(key, y, e, graph) {
      var datetime;

      if (url.match(/daily/)) {
        datetime = d3.time.format("%x")(new Date(graph.point[0]));
      }

      if (url.match(/hourly/)) {
        datetime = d3.time.format("%x - %I:%M%p")(new Date(graph.point[0]));
      }

      if (url.match(/minutely/)) {
        datetime = d3.time.format("%I:%M%p")(new Date(graph.point[0]));
      }

      return "<div style='text-align: center;'>" +
        "<b>" + key + "</b>" + "<p>" + e + " at " + datetime + "</p>" +
        "</div>"
      ;
    })

    d3.json(url, function(data) {
      d3.select('#completed-jobs-chart svg')
        .datum(data)
        .transition()
        .duration(500)
        .call(chart);
    });
  }

  nv.addGraph(function() {
    chart = nv.models.multiBarChart()
      .showLegend(false)
      .x(function(d) { return d[0] })
      .y(function(d) { return d[1] })
      .clipEdge(true);

    chart.yAxis.tickFormat(d3.format(',.1f'));

    var url = $("#completed-jobs-chart-type li.active").data('url');
    loadChart(chart, url);

    nv.utils.windowResize(chart.update);

    return chart;
  });
});
