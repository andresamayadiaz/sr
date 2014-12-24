$(function(){

  // 
  var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  var d1 = [];
  for (var i = 0; i <= 11; i += 1) {
    d1.push([i, parseInt((Math.floor(Math.random() * (1 + 20 - 10))) + 10)]);
  }
  $("#flot-1ine").length && $.plot($("#flot-1ine"), [{
          data: d1
      }], 
      {
        series: {
            lines: {
                show: true,
                lineWidth: 2,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 0.0
                    }, {
                        opacity: 0.2
                    }]
                }
            },
            points: {
                radius: 5,
                show: true
            },
            grow: {
              active: true,
              steps: 50
            },
            shadowSize: 2
        },
        grid: {
            hoverable: true,
            clickable: true,
            tickColor: "#f0f0f0",
            borderWidth: 1,
            color: '#f0f0f0'
        },
        colors: ["#65bd77"],
        xaxis:{
        },
        yaxis: {
          ticks: 5
        },
        tooltip: true,
        tooltipOpts: {
          content: "chart: %x.1 is %y.4",
          defaultTheme: false,
          shifts: {
            x: 0,
            y: 20
          }
        }
      }
  );
  
  var d2 = [];
  for (var i = 0; i <= 6; i += 1) {
    d2.push([i, parseInt((Math.floor(Math.random() * (1 + 30 - 10))) + 10)]);
  }
  var d3 = [];
  for (var i = 0; i <= 6; i += 1) {
    d3.push([i, parseInt((Math.floor(Math.random() * (1 + 30 - 10))) + 10)]);
  }
  $("#flot-chart-1").length && $.plot($("#flot-chart-1"), [{
          data: d2,
          label: "Unique Visits"
      }, {
          data: d3,
          label: "Page Views"
      }], 
      {
        series: {
            lines: {
                show: true,
                lineWidth: 1,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 0.2
                    }, {
                        opacity: 0.1
                    }]
                }
            },
            points: {
                show: true
            },
            shadowSize: 2
        },
        grid: {
            hoverable: true,
            clickable: true,
            tickColor: "#f0f0f0",
            borderWidth: 0
        },
        colors: ["#dddddd","#89cb4e"],
        xaxis: {
            ticks: 15,
            tickDecimals: 0
        },
        yaxis: {
            ticks: 10,
            tickDecimals: 0
        },
        tooltip: true,
        tooltipOpts: {
          content: "'%s' of %x.1 is %y.4",
          defaultTheme: false,
          shifts: {
            x: 0,
            y: 20
          }
        }
      }
  );


  $("#flot-chart-2").length && $.plot($("#flot-chart-2"), [{
          data: d2,
          label: "Unique Visits"
      }, {
          data: d3,
          label: "Page Views"
      }], 
      {
        series: {
            lines: {
                show: true,
                lineWidth: 1,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 0.2
                    }, {
                        opacity: 0.1
                    }]
                }
            },
            points: {
                show: true
            },
            shadowSize: 2
        },
        grid: {
            hoverable: true,
            clickable: true,
            tickColor: "#f0f0f0",
            borderWidth: 0
        },
        colors: ["#dddddd","#89cb4e"],
        xaxis: {
            ticks: 15,
            tickDecimals: 0
        },
        yaxis: {
            ticks: 10,
            tickDecimals: 0
        },
        tooltip: true,
        tooltipOpts: {
          content: "'%s' of %x.1 is %y.4",
          defaultTheme: false,
          shifts: {
            x: 0,
            y: 20
          }
        }
      }
  );

  // bar
  var d1_1 = [
    [10, 120],
    [20, 70],
    [30, 100],
    [40, 60],
    [50, 35]
  ];

  var d1_2 = [
    [10, 80],
    [20, 60],
    [30, 30],
    [40, 35],
    [50, 30]
  ];

  var d1_3 = [
    [10, 80],
    [20, 40],
    [30, 30],
    [40, 20],
    [50, 10]
  ];

  var data1 = [
    {
        label: "Product 1",
        data: d1_1,
        bars: {
            show: true,
            fill: true,
            lineWidth: 1,
            order: 1,
            fillColor:  "#6783b7"
        },
        color: "#6783b7"
    },
    {
        label: "Product 2",
        data: d1_2,
        bars: {
            show: true,
            fill: true,
            lineWidth: 1,
            order: 2,
            fillColor:  "#4fcdb7"
        },
        color: "#4fcdb7"
    },
    {
        label: "Product 3",
        data: d1_3,
        bars: {
            show: true,
            fill: true,
            lineWidth: 1,
            order: 3,
            fillColor:  "#8dd168"
        },
        color: "#8dd168"
    }
  ];

  var d2_1 = [
    [90, 10],
    [70, 20],
    [50, 30]
  ];

  var d2_2 = [
    [80, 10],
    [60, 20],
    [40, 30]
  ];

  var d2_3 = [
    [120, 10],
    [50, 20],
    [30, 30]
  ];

  var data2 = [
    {
        label: "Product 1",
        data: d2_1,
        bars: {
            horizontal: true,
            show: true,
            fill: true,
            lineWidth: 1,
            order: 1,
            fillColor:  "#6783b7"
        },
        color: "#6783b7"
    },
    {
        label: "Product 2",
        data: d2_2,
        bars: {
            horizontal: true,
            show: true,
            fill: true,
            lineWidth: 1,
            order: 2,
            fillColor:  "#4fcdb7"
        },
        color: "#4fcdb7"
    },
    {
        label: "Product 3",
        data: d2_3,
        bars: {
            horizontal: true,
            show: true,
            fill: true,
            lineWidth: 1,
            order: 3,
            fillColor:  "#8dd168"
        },
        color: "#8dd168"
    }
  ];

  $("#client-bar").length && $.plot($("#client-bar"), data1, {
      xaxis: {
          
      },
      yaxis: {
          
      },
      grid: {
          hoverable: true,
          clickable: false,
          borderWidth: 0
      },
      legend: {
          labelBoxBorderColor: "none",
          position: "left"
      },
      series: {
          shadowSize: 1
      },
      tooltip: true,
  });

  $("#supplier-bar").length && $.plot($("#supplier-bar"), data1, {
      xaxis: {
          
      },
      yaxis: {
          
      },
      grid: {
          hoverable: true,
          clickable: false,
          borderWidth: 0
      },
      legend: {
          labelBoxBorderColor: "none",
          position: "left"
      },
      series: {
          shadowSize: 1
      },
      tooltip: true,
  });

});
