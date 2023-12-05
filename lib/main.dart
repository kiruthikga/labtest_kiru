import 'package:flutter/material.dart';
import 'Controller/sqlite_db.dart';
import 'Model/bmi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BMICalculator(),
    );
  }
}

class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorState createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiValueController = TextEditingController();
  final TextEditingController bmimessageController = TextEditingController();
  String gendergrp = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  // for question c
  void initData() async {
    List<Map<String, dynamic>> data = await SQLiteDB().queryAll(BMI.SQLiteTable);
    if (data.isNotEmpty) {
      Map<String, dynamic> lastEntry = data.last;
      fullNameController.text = lastEntry['username'];
      heightController.text = lastEntry['height'].toString();
      weightController.text = lastEntry['weight'].toString();
      gendergrp = lastEntry['gender'];
      calculateBMI();
    }
  }

  void _addbmi() async {
    String username = fullNameController.text.trim();
    String weight = weightController.text.trim();
    String height = heightController.text.trim();
    String gender = gendergrp.trim();

    if (username.isNotEmpty && weight.isNotEmpty && height.isNotEmpty && gender.isNotEmpty) {
      try {
          double parsedWeight = double.parse(weight);
          double parsedHeight = double.parse(height);

          calculateBMI();
          String bmiStatus = bmimessageController.text.trim();
          BMI bmi = BMI(username, parsedWeight, parsedHeight, gender, bmiStatus);
          await bmi.save();
      } catch (e) {
        print("Error parsing double: $e");
      }
    } else {
      print("Invalid input data");
    }
  }

  void calculateBMI() {
    try {
      String height = heightController.text.trim();
      String weight = weightController.text.trim();

      double heightInMeters = double.parse(height) / 100;
      double weightInKg = double.parse(weight);
      double bmi = weightInKg / (heightInMeters * heightInMeters);

      bmiValueController.text = bmi.toStringAsFixed(2);

      if (gendergrp == 'Male') {
        if (bmi < 18.5) {
          bmimessageController.text = 'Underweight. Careful during strong wind!';
        } else if (bmi >= 18.5 && bmi <= 24.9) {
          bmimessageController.text = 'That’s ideal! Please maintain';
        } else if (bmi >= 25.0 && bmi <= 29.9) {
          bmimessageController.text = 'Overweight! Work out please';
        } else if (bmi >= 30.0) {
          bmimessageController.text = 'Whoa Obese! Dangerous mate!';
        } else {
          bmimessageController.text = 'Bmi Not found';
        }
      } else if (gendergrp == 'Female') {
        if (bmi < 16) {
          bmimessageController.text = 'Underweight. Careful during strong wind!';
        } else if (bmi >= 16 && bmi <= 22) {
          bmimessageController.text = 'That’s ideal! Please maintain';
        } else if (bmi >= 22 && bmi <= 27) {
          bmimessageController.text = 'Overweight! Work out please';
        } else if (bmi >= 30.0) {
          bmimessageController.text = 'Whoa Obese! Dangerous mate!';
        } else {
          bmimessageController.text = 'Bmi Not found';
        }
      }
    } catch (e) {
      print("Error calculating BMI: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Your Fullname',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'Height in cm',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight in kg',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: bmiValueController,
                readOnly: true,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'BMI Value',
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Radio(
                        value: 'Male',
                        groupValue: gendergrp,
                        onChanged: (String? value) {
                          setState(() {
                            gendergrp = value!;
                          });},),
                      Text('Male'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'Female',
                        groupValue: gendergrp,
                        onChanged: (String? value) {
                          setState(() {
                            gendergrp = value!;
                          });},),
                      Text('Female'),
                    ],
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: _addbmi,
              child: Text('Calculate BMI and Save'),
            ),
            Padding(
            padding: const EdgeInsets.all(16.0),
                child: Text(
                  bmimessageController.text,
                  style: TextStyle(fontWeight: FontWeight.bold),
           )
            )
          ],
        ),
      ),
    );
  }
}
