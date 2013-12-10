// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  var chart;

  function loadChart(chart, url) {
    d3.json(url, function(data) {
      d3.select('#completed-jobs-chart svg')
        .datum(data)
        .transition().duration(500).call(chart);
    });
  }

  $("#completed-jobs-chart-type li").click(function() {
    $(this).parent().find("li").removeClass("active");
    $(this).addClass("active");

    loadChart(chart, $(this).data('url'));
  });

  nv.addGraph(function() {
    chart = nv.models.multiBarChart()
      .x(function(d) { return d[0] })
      .y(function(d) { return d[1] })
      .clipEdge(true);

    chart.xAxis
      .ticks(d3.time.hour, 24 * 7)
      .tickFormat(function(d) { return d3.time.format('%x')(new Date(d)) });

    chart.yAxis.tickFormat(d3.format(',.1f'));

    var url = $("#completed-jobs-chart-type li.active").data('url');
    loadChart(chart, url);

    nv.utils.windowResize(chart.update);

    return chart;
  });
});