import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Progress extends StatefulWidget {
  final String vec1;
  final String name1;

  const Progress({
    super.key,
    required this.vec1,
    required this.name1,
  });

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  int p = 0;
  double highestCorrectPercentage = 0.0;
  String highestScoreSongName = '';
  int highestCorrectValue = 0;
  String highestCorrectSongName = '';
  String bestSongName = '';
  double bestHardAccuracy = 0.0;
  double bestEasyAccuracy = 0.0;
  double correctPercentage = 0.0;
  String lastSongName = '';
  double lastEasyAccuracy = 0.0;
  double lastHardAccuracy = 0.0;
  List<_SongData> fetchedEasyData = [];
  List<_SongData> fetchedHardData = [];

  @override
  void initState() {
    super.initState();
    _fetchCorrectPercentage();
  }

  Future<void> _fetchCorrectPercentage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('songs')
          .snapshots()
          .listen((snapshot) {
        double highestScoreTemp = 0.0;
        int totalCorrectNotes = 0;
        int totalNumNotes = 0;
        String tempHighestScoreSongName = '';
        String tempBestSongName = '';
        double tempBestHardAccuracy = 0.0;
        double tempBestEasyAccuracy = 0.0;
        List<_SongData> easyData = [];
        List<_SongData> hardData = [];

        for (var doc in snapshot.docs) {
          final song = doc.data();
          final songName = doc.id;

          // Parse the values
          final easyAccuracyStr = song['presntage_easy'] ?? '0';
          final hardAccuracyStr = song['presntage_hard'] ?? '0';
          final easyAccuracy = double.tryParse(easyAccuracyStr) ?? 0.0;
          final hardAccuracy = double.tryParse(hardAccuracyStr) ?? 0.0;
          final correctStr = song['correct'] ?? '0';
          final correct = int.tryParse(correctStr) ?? 0;
          final notes = song['notes'] ?? '';
          final int songLength = notes.split(',').length;

          easyData.add(_SongData(songName, easyAccuracy));
          hardData.add(_SongData(songName, hardAccuracy));

          totalCorrectNotes += correct;
          totalNumNotes += songLength;

          if (correct > highestCorrectValue) {
            highestCorrectValue = correct;
            highestCorrectSongName = songName;
            correctPercentage = songLength > 0 ? correct / songLength : 0.0;
          }

          // Check if this is the last song and update its progress
          if (songName == lastSongName) {
            lastEasyAccuracy = easyAccuracy;
            lastHardAccuracy = hardAccuracy;
          }

          // Track the highest score and associated song name
          if (easyAccuracy > highestScoreTemp) {
            highestScoreTemp = easyAccuracy;
            tempHighestScoreSongName = songName;
          }
          if (hardAccuracy > highestScoreTemp) {
            highestScoreTemp = hardAccuracy;
            tempHighestScoreSongName = songName;
          }

          // Determine the best song based on hard accuracy, and easy accuracy as a tiebreaker
          if (hardAccuracy > tempBestHardAccuracy ||
              (hardAccuracy == tempBestHardAccuracy && easyAccuracy > tempBestEasyAccuracy)) {
            tempBestHardAccuracy = hardAccuracy;
            tempBestEasyAccuracy = easyAccuracy;
            tempBestSongName = songName;
          }
        }

        if (mounted) {
          setState(() {
            fetchedEasyData = easyData;
            fetchedHardData = hardData;
            p = (correctPercentage * 100).toInt();
            highestCorrectPercentage = highestScoreTemp;
            highestScoreSongName = tempHighestScoreSongName;
            bestSongName = tempBestSongName;
            bestHardAccuracy = tempBestHardAccuracy;
            bestEasyAccuracy = tempBestEasyAccuracy;
          });
        }
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>?;

        // Fetch the last song name
        lastSongName = data?['lastSong'] ?? '';

        // Fetch the specific last song document to get the correct values
        if (lastSongName.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('songs')
              .doc(lastSongName)
              .get()
              .then((lastSongSnapshot) {
            if (lastSongSnapshot.exists) {
              final lastSongData = lastSongSnapshot.data();
              if (lastSongData != null) {
                setState(() {
                  lastEasyAccuracy = double.tryParse(lastSongData['presntage_easy'] ?? '0') ?? 0.0;
                  lastHardAccuracy = double.tryParse(lastSongData['presntage_hard'] ?? '0') ?? 0.0;
                });
              }
            }
          }).catchError((error) {
            print("Error fetching last song data: $error");
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.name1}\'s Progress',
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (highestCorrectSongName.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Highest Correct Song: $highestCorrectSongName',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  CircularPercentIndicator(
                    radius: 100.0,
                    lineWidth: 15.0,
                    percent: correctPercentage,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$highestCorrectValue',
                          style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w900,
                              fontSize: 32),
                        ),
                        Text(
                          "${(correctPercentage * 100).toStringAsFixed(2)}%",
                          style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w900,
                              fontSize: 18),
                        ),
                      ],
                    ),
                    progressColor: const Color(0xFF4B39EF),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (highestCorrectPercentage > 0)
              Column(
                children: [
                  Text(
                    'Highest Score: ${highestCorrectPercentage.toStringAsFixed(2)}% ($highestScoreSongName)',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  CircularPercentIndicator(
                    radius: 75.0,
                    lineWidth: 10.0,
                    percent: highestCorrectPercentage / 100,
                    center: Text(
                      '${highestCorrectPercentage.toStringAsFixed(2)}%',
                      style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w900,
                          fontSize: 18),
                    ),
                    progressColor: Colors.green,
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (bestSongName.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Best Song: $bestSongName',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  CircularPercentIndicator(
                    radius: 75.0,
                    lineWidth: 10.0,
                    percent: bestHardAccuracy / 100,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hard: ${bestHardAccuracy.toStringAsFixed(2)}%',
                          style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w900,
                              fontSize: 18),
                        ),
                        Text(
                          'Easy: ${bestEasyAccuracy.toStringAsFixed(2)}%',
                          style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w900,
                              fontSize: 18),
                        ),
                      ],
                    ),
                    progressColor: Colors.orange,
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              'Progress of Last Song ($lastSongName):',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Easy: ${lastEasyAccuracy.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text(
              'Hard: ${lastHardAccuracy.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(
                minimum: 0,
                maximum: 110,
                labelFormat: '{value}%',
              ),
              title: const ChartTitle(text: 'Learning Progress Analysis'),
              legend: const Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<_SongData, String>>[
                ColumnSeries<_SongData, String>(
                  dataSource: fetchedEasyData,
                  xValueMapper: (_SongData songData, _) => songData.songName,
                  yValueMapper: (_SongData songData, _) => songData.accuracy,
                  name: 'Easy',
                  color: Colors.blue,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
                ColumnSeries<_SongData, String>(
                  dataSource: fetchedHardData,
                  xValueMapper: (_SongData songData, _) => songData.songName,
                  yValueMapper: (_SongData songData, _) => songData.accuracy,
                  name: 'Hard',
                  color: Colors.red,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SongData {
  _SongData(this.songName, this.accuracy);

  final String songName;
  final double accuracy;
}