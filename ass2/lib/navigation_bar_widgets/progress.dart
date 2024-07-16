import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Progress extends StatefulWidget {
  final String vec1;
  final String name1;

  const Progress(
      {super.key,
        required String this.vec1,
        required String this.name1
      });

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  int _number = 0;
  double percent = 0.0;
  int p = 0;
  List<_TasksData> data = [];

  @override
  void initState() {
    super.initState();
    _number = _convertDateToNum(DateTime.now().day,DateTime.now().month);
    percent = _getPercent(_number,widget.vec1);
    p = (percent*100).toInt();
    data = graphData(widget.vec1);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.name1}\'s Progress',
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircularPercentIndicator(
                radius: 55.0,
                lineWidth: 10.0,
                percent: percent,
                center: Text("${p}%", style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w900,
                  fontSize: 18
                ),),
                progressColor: Color(0xFF4B39EF),
              ),
            SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(
                minimum: 0,
                maximum: 110,
                labelFormat: '{value}%',
              ),
            // Chart title
            title: const ChartTitle(text: 'Yearly progress analysis'),
            // Enable legend
            legend: const Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<_TasksData, String>>[
              LineSeries<_TasksData, String>(
                  color: Color(0xFF4B39EF),
                  dataSource: data,
                  xValueMapper: (_TasksData tasks, _) => tasks.year,
                  yValueMapper: (_TasksData tasks, _) => tasks.tasks,
                  name: 'Tasks',
                  // Enable data label
                  dataLabelSettings: DataLabelSettings(isVisible: true))
          ],
        ),
      ]),
    )
    );
  }


  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(

        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

}

int _convertDateToNum(int day, int month) {
  List<int> monthes = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  int counter = 0;
  for (int i = 0; i < month - 1; i++) {
    counter = counter + monthes[i];
  }
  counter = counter + day;
  return counter;
}

double _getPercent(int number, String vec){
  if(number == 0){
    return 0;
  }
  int count = 0;
  for(int i = 0; i < number; i++){
    if(vec[i] == '0'){
      count++;
    }
  }
  return (count/number);
}

class _TasksData {
  _TasksData(this.year, this.tasks);

  final String year;
  final double tasks;
}


List<_TasksData> graphData(String vec){
  List<_TasksData> data = [];
  List<String> numToMonthes = ['0', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  List<int> monthes = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  int number = 0;
  int count = 0;
  int month = DateTime.now().month;
  int day = DateTime.now().day;
  for(int i = 1; i < month; i++){
    number += monthes[i];
    count = 0;
    for(int j = number-monthes[i]; j < number; j++){
      if(vec[j] == '0'){
        count++;
      }
    }
    data.add(_TasksData(numToMonthes[i], ((count/monthes[i])*100).round().toDouble()));
  }
  count = 0;
  for(int j = number; j < number+day; j++){
    if(vec[j] == '0'){
      count++;
    }
  }
  data.add(_TasksData(numToMonthes[month], ((count/day)*100).round().toDouble()));
  return data;
}
