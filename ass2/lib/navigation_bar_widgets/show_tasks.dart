import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../loading/get_vec.dart';

class ShowTasks extends StatefulWidget {
  final String vec1;
  final String name1;
  final Map<String, dynamic> tasks1;

  const ShowTasks(
      {super.key,
      required String this.vec1,
      required Map<String, dynamic> this.tasks1,
        required String this.name1});

  @override
  State<ShowTasks> createState() => _ShowTasksState();
}

class _ShowTasksState extends State<ShowTasks> {
  List<String> numToMonthes = [
    '0',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  Map<String, int> monthes = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };
  Map<String, int> daysInMonth = {
    'January': 31,
    'February': 29,
    'March': 31,
    'April': 30,
    'May': 31,
    'June': 30,
    'July': 31,
    'August': 31,
    'September': 30,
    'October': 31,
    'November': 30,
    'December': 31,
  };

  DateTime now = DateTime.now();
  bool flag = true;
  int _day = 0;
  int _month = 0;

  @override
  Widget build(BuildContext context) {

    String _vec = widget.vec1;
    Map<String, dynamic> _tasks = widget.tasks1;
    if (flag) {
      _day = now.day;
      _month = now.month;
    }
    int number = _convertDateToNum(_day, _month);
    String _currentDate = '$_day/$_month';
    Map<String, dynamic>? listOfTasks;
    String _selectedMonth = numToMonthes[_month];
    int _selectedDay = _day;
    if (_tasks[_currentDate] != null) {
      listOfTasks = _tasks[_currentDate] as Map<String, dynamic>;
    }

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          '${widget.name1}\'s Today\'s tasks',
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Center(
              child:Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                items: monthes.keys
                    .toList()
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style:TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 20)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMonth = newValue!;
                    _month = monthes[_selectedMonth]!;
                    _day = 1;
                    flag = false;
                  });
                },
                value: _selectedMonth,
              ),
              DropdownButton<int>(
                items: List.generate(daysInMonth[_selectedMonth]!, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text((index + 1).toString(),style:TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 20)),
                  );
                }),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedDay = newValue!;
                    _day = _selectedDay;
                    flag = false;
                  });
                },
                value: _selectedDay,
              ),
            ],
          )
          ),
          const Divider(
            color: Colors.black, // Optionally, set the color of the line
            thickness: 1, // Optionally, set the thickness of the line
          ),
          listOfTasks != null && listOfTasks.isNotEmpty
              ? AllTasks(
                  allTasks: GetAllTasks(listOfTasks),
                  number1: number,
                  vec1: _vec,
                  tasks1: _tasks
                )
              : const NoTasksToday(),
        ],
      )),
    );
  }
}

class NoTasksToday extends StatelessWidget {
  const NoTasksToday({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
       Text(
      'You\'ve got no tasks for the day',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Plus Jakarta Sans',
      ),
    ),
    ]);
  }
}

class TasksCheckbox extends StatefulWidget {
  final List<String> listOfTasks;
  final int number2;
  final String vec2;
  final Map<String, dynamic> tasks2;

  const TasksCheckbox(
      {super.key, required this.listOfTasks, required this.number2, required this.vec2, required this.tasks2});

  @override
  State<TasksCheckbox> createState() => _TasksCheckboxState();
}

class _TasksCheckboxState extends State<TasksCheckbox> {
  late List<bool> _isCheckedList;
  bool flag = true;

  @override
  void initState() {
    super.initState();
    _isCheckedList = List<bool>.filled(widget.listOfTasks.length, false);
  }

  @override
  Widget build(BuildContext context) {
    if(!flag){
      flag = true;
    }else{
      _isCheckedList = List<bool>.filled(widget.listOfTasks.length, false);
    }
    return Column(children: [
      Column(
        children: List.generate(
          widget.listOfTasks.length,
          (index) => CheckboxListTile(
            title: Text(widget.listOfTasks[index],
                style: const TextStyle(
                    color: Color(0xFF101213),
                    fontSize: 20.0,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500)),
            value: _isCheckedList[index],
            activeColor: Color(0xFF4B39EF),
            onChanged: (value) {
              setState(() {
                _isCheckedList[index] = value!;
                flag = false;
              });
            },
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () async {
          if(widget.number2 < _convertDateToNum(DateTime.now().day, DateTime.now().month)){
            _showErrorMessage(context, "Error: This day has already passed, this action is not available.");
          }
          else{
          //update vec
          int count = _isCheckedList.where((element) => element).length;
          List<String> zerosList = widget.vec2.split('');
          zerosList[widget.number2 - 1] =
              (int.parse(widget.vec2[widget.number2 - 1]) - count).toString();
          String new_vec = zerosList.join('');
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'vec': new_vec});
          //update tasks
          Map<String, dynamic> _tasks = widget.tasks2;
          List<int> ind = [];
          int day = _convertNumToDate(widget.number2)[1];
          int month = _convertNumToDate(widget.number2)[0];
          String date = '$day/$month';
          for(int i = 0; i < _isCheckedList.length; i++){
            if(_isCheckedList[i]){
              ind.add(i);
            }
          }
          for(int i = 0; i < ind.length;i++){
              _tasks[date][widget.listOfTasks[i]] = true;
          }
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'tasks': _tasks});
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => GetVec()));
          }
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.black26;
              }
              return Color(0xFF4B39EF);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)))),
        child: const Text(
          'Submit',
          style: TextStyle(
              color: Color(0xFFF1F4F8),
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      )
    ]);
  }
}

List<List<String>> GetAllTasks(Map<String, dynamic> tasks) {
  List<String> unfinished = [];
  List<String> finished = [];
  tasks.forEach((key, value) {
    bool tmp = value as bool;
    if (!tmp) {
      unfinished.add(key);
    } else {
      finished.add(key);
    }
  });
  return [unfinished, finished];
}

class DoneTasks extends StatefulWidget {
  final List<String> listOfTasks;

  const DoneTasks({super.key, required this.listOfTasks});

  @override
  State<DoneTasks> createState() => _DoneTasksState();
}

class _DoneTasksState extends State<DoneTasks> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: List.generate(
            widget.listOfTasks.length,
            (index) => Padding(
                padding: EdgeInsets.fromLTRB(15, 5, 0, 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.listOfTasks[index],
                      style: const TextStyle(
                        color: Color(0xFFAAAEB0),
                        fontSize: 20.0,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough,
                      )),
                ))));
  }
}

class AllTasks extends StatefulWidget {
  final List<List<String>> allTasks;
  final int number1;
  final String vec1;
  final Map<String, dynamic> tasks1;

  const AllTasks({super.key, required this.allTasks,required this.number1, required this.vec1, required this.tasks1});

  @override
  State<AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks> {
  @override
  Widget build(BuildContext context) {
    double percent = widget.allTasks[1].length/(widget.allTasks[1].length + widget.allTasks[0].length);
    int p = (percent*100).toInt();
    return Column(
      children: [
        Center(
            child: CircularPercentIndicator(
              radius: 55.0,
              lineWidth: 10.0,
              percent: percent,
              center: Text("${p}%", style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w900,
                  fontSize: 18
              ),),
              progressColor: Color(0xFF4B39EF),
            )
        ),
        TasksCheckbox(
          listOfTasks: widget.allTasks[0],
            number2: widget.number1,
            vec2: widget.vec1,
            tasks2: widget.tasks1
        ),
        const Divider(
          color: Color(0xFFAAAEB0), // Optionally, set the color of the line
          thickness: 1, // Optionally, set the thickness of the line
        ),
        const Text(
          'Completed',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFFAAAEB0),
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        DoneTasks(listOfTasks: widget.allTasks[1])
      ],
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

List<int> _convertNumToDate(int number) {
  List<int> monthes = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  int day = 1;
  int month = 1;
  int i = 0;
  while(number > 0){
    if(number > monthes[i]) {
      number = number - monthes[i];
      i++;
      month++;
    }
    else{
      day = number;
      return [month,day];
    }
  }
  return [month,day];
}

double getPercent(Map<String, dynamic> tasks){
  int size = tasks.length;
  int count = 0;
  tasks.forEach((key, value) {
    if(value){
      count++;
    }
  });
  return count/size;
}

void _showErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(

      content: Text(message),
      duration: Duration(seconds: 3),
    ),
  );
}
