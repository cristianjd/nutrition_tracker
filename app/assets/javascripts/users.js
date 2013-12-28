charts = {};

charts.extractData = function(field) {
	return $('#data').data(field);
};

charts.currentNutrients = function() {return charts.extractData('current-nutrients');};

charts.goalNutrients = function() {return charts.extractData('goal-nutrients');};

charts.foodLogged = function() {return charts.currentNutrients()['calories'] !== 0.0 };

charts.generateBarChart = function() {
    var nutrients = ['calories', 'protein', 'carbohydrate', 'fat'];
    var nutrientPercentage = [];
    var colors = ['#0d233a', '#910000', '#2f7ed8', '#492970'];
    for (var n = 0; n< 4; n++) {
        nutrientPercentage[n] = (charts.currentNutrients()[nutrients[n]] / charts.goalNutrients()[nutrients[n]])*100.0;
        if (nutrientPercentage[n] >= 100.0) {
            colors[n] = '#8bbc21';
        }
        if (nutrientPercentage[n] > 125.0) {
            nutrientPercentage[n] = 125.0
        }
    }
    $('#bar-chart').highcharts({
        chart: {
            type: 'bar'
        },
        colors: colors,
        xAxis: {
            categories: ['Calories', 'Protein', 'Carbohydrate', 'Fat'],
            labels : {
                enabled: false
            },
            lineColor: 'transparent',
            lineWidth: 0,
            minorGridLineWidth: 0,
            tickColor: 'transparent'
        },
        yAxis: {
            labels: {
                enabled: false
            },
            title: {
                text: null
            },
            tickInterval: 100,
            min: 0,
            max: 125,
            endOnTick: false            
        },
        title: {
            text: null
        },
        plotOptions: {
            series: {
                colorByPoint: true
            },
            bar: {
                pointWidth: 50
            }
        },
        legend: {
            enabled: false
        },
        credits: {
            enabled: false
        },
        tooltip: {
            enabled: false
        },
        series: [{
            data: nutrientPercentage
        }]
    });
};

charts.generateCurrentPieChart = function() {
    $('#current-pie-chart').highcharts({
        colors: [
            '#910000',
            '#2f7ed8',
            '#492970'
        ],
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: null
        },
        tooltip: {
            enabled: false
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                dataLabels: {
                    enabled: true,
                    color: '#000000',
                    connectorColor: '#000000',
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                }
            }
        },
        credits: {
            enabled: false
        },
        series: [{
            type: 'pie',
            name: 'Macronutrient Ratios',
            data: [
                ['Protein', charts.currentNutrients()['protein']*4.0],
                ['Carbohydrate', charts.currentNutrients()['carbohydrate']*4.0],
                ['Fat', charts.currentNutrients()['fat']*9.0]
            ]
        }]
    });    
};

charts.generateGoalPieChart = function() {
    $('#goal-pie-chart').highcharts({
        colors: [
            '#910000',
            '#2f7ed8',
            '#492970'
        ],
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: null
        },
        tooltip: {
            enabled: false
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                dataLabels: {
                    enabled: true,
                    color: '#000000',
                    connectorColor: '#000000',
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                }
            }
        },
        credits: {
            enabled: false
        },
        series: [{
            type: 'pie',
            name: 'Macronutrient Ratios',
            data: [
                ['Protein', charts.goalNutrients()['protein']*4.0],
                ['Carbohydrate', charts.goalNutrients()['carbohydrate']*4.0],
                ['Fat', charts.goalNutrients()['fat']*9.0]
            ]
        }]
    });
};

charts.tableElement = function(index) { return $('#progress-table tr').eq(index); };

charts.barChartElement = function(index) { return $('#bar-chart').highcharts().series[0].data[index]; };

charts.currentPieChartElement = function(index) {
    if (charts.foodLogged()) {
        return $('#current-pie-chart').highcharts().series[0].data[index-1];
    }
};

charts.goalPieChartElement = function(index) { return $('#goal-pie-chart').highcharts().series[0].data[index-1]; };

charts.elementsArray = function(index) {
    return [charts.tableElement(index),
            charts.barChartElement(index),
            charts.currentPieChartElement(index),
            charts.goalPieChartElement(index)];
};

charts.hover = function(index, highlight) {
    var hoverState = highlight ? 'hover' : '';
    var tableRow = charts.elementsArray(index)[0];
    if (highlight) {
        tableRow.addClass('hovered');
    }
    else {
        tableRow.removeClass('hovered');
    }
    for (var n = 1; n < 4; n++) {
        var chartElement = charts.elementsArray(index)[n];
        if ( chartElement ) {
            chartElement.setState(hoverState);
        }
    }
};

charts.setup = function () {
    charts.generateBarChart();
    charts.generateGoalPieChart();
    if (charts.foodLogged()) {
        charts.generateCurrentPieChart();
    }

    $('#progress-table tr, #bar-chart .highcharts-tracker rect').hover(
        function () {
            charts.hover($(this).index(), true)
        }, function () {
            charts.hover($(this).index(), false)
        }
    );

    $("#current-pie-chart .highcharts-tracker path, #goal-pie-chart .highcharts-tracker path").not("path[fill='none']").hover(
        function () {
            charts.hover($(this).index() - 2, true)
        }, function () {
            charts.hover($(this).index() - 2, false)
        }
    );

    $('#calendar').datepicker({
        onRender: function (date) {
            return date.valueOf() > (new Date()).valueOf() ? 'disabled' : '';
        }
    }).on('changeDate', function (e) {
            $(this).datepicker('hide');
        });
};

$(function() {
    if ($('body.users.nutrition').length) {
        charts.setup();
    }
});

