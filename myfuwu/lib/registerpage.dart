import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late double height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    print(width);
    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Register Page')),
      body: Center(
        child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: ,)
            
            SizedBox(height: 5),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 
                SuffixIcon: 
                border:

              )
            )

            TextField(),
            TextField(),
            TextField(),
            Row(children: [
              Text('Remember Me')
              Checkbox(value: false, onChanged: (value) {})
            ],),
            ElevatedButton(onPressed: () {}, child: Text('Register')),
            Text('Already have an account? Login'),
            Text('Forgot Password'),


          ]
        )
      )),
    );
  }
}