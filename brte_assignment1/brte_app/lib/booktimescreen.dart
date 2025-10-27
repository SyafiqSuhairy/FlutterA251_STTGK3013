import 'package:flutter/material.dart';

class BookTimeScreen extends StatefulWidget {
  const BookTimeScreen({super.key});

  @override
  State<BookTimeScreen> createState() => _BookTimeScreenState();
}

class _BookTimeScreenState extends State<BookTimeScreen> {
  
  String readingSpeed = 'Average'; 
  TextEditingController pagesController = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  double resultInDays = 0.0;
  FocusNode pagesFocusNode = FocusNode();

  final Map<String, double> readingSpeedMap = {
    'Slow': 20.0,
    'Average': 30.0,
    'Fast': 40.0,
  };

  // (1) The Layout Structure ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Time Estimator', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue, 
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SECTION 1: INPUTS
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.lightBlue[50], 
                ),
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row 1: Inputs for Reading Speed (Dropdown) 
                    Row(
                      children: [
                        SizedBox(width: 100, child: Text('Reading Speed')),
                        DropdownButton<String>(
                          value: readingSpeed,
                          items: <String>['Slow', 'Average', 'Fast']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              readingSpeed = newValue!;
                            });
                          },
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        SizedBox(width: 100), 
                        Text(
                          "(${readingSpeedMap[readingSpeed]} pages/hr)",
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 5), 

                    // Row 2: Inputs for Total Pages 
                    Row(
                      children: [
                        SizedBox(width: 100, child: Text('Total Pages')),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            focusNode: pagesFocusNode,
                            controller: pagesController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'e.g., 350',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),

                    // Row 3: Inputs for Hours per Day
                    Row(
                      children: [
                        SizedBox(width: 100, child: Text('Hours per Day')),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: hoursController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'e.g., 2.5',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15), 

                    // Row 4: Buttons Calculate & Button Reset
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed:
                              calculateTime, 
                          child: Text('Calculate'),
                        ),
                        ElevatedButton(
                          onPressed: resetForm, 
                          child: Text('Reset'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300]), 
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // SECTION 2: OUTPUT
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[800]!),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                width: 350, 
                child: Center(
                  child: Text(
                    'Estimated Time: $resultInDays Days',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900]),
                  ),
                ),
              ),
              SizedBox(height: 16), 
            ],
          ),
        ),
      ),
    );
  }

  // (2) Calculate Button Function ----------------------------------------------------
  void calculateTime() {
    final String pagesInput = pagesController.text;
    final String hoursInput = hoursController.text;

    // Get values, using tryParse to handle empty/invalid inputs (as per assignment)
    double? totalPages = double.tryParse(pagesInput);
    double? hoursPerDay = double.tryParse(hoursInput);

    if (pagesInput.isEmpty || hoursInput.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please fill in all fields'),
        backgroundColor: Colors.red, 
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        resultInDays = 0.0;
      });
      return;
    }

    if (totalPages == null || hoursPerDay == null) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please enter valid numbers (e.g., 300 or 2.5)'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        resultInDays = 0.0; 
      });
      return;
    }
    
    double pagesPerHour = readingSpeedMap[readingSpeed] ?? 30.0; 
    double totalDays = 0.0;

    // Check for valid inputs to avoid division by zero
    if (totalPages > 0 && hoursPerDay > 0 && pagesPerHour > 0) {
      double totalHours = totalPages / pagesPerHour;
      totalDays = totalHours / hoursPerDay;
    }

    // Update the state to show the result
    setState(() {
      // Format to 2 decimal places
      resultInDays = double.parse(totalDays.toStringAsFixed(2));
    });
  }

  // (3) Reset Button Function ----------------------------------------------------
  void resetForm() {
    setState(() {
      pagesController.clear();
      hoursController.clear();
      readingSpeed = 'Average';
      resultInDays = 0.0;

      // Set focus back to the first field
      FocusScope.of(context).requestFocus(pagesFocusNode);
    });
  }
}