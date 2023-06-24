import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master Exit Button Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSignupEnabled = true;
  bool _isTimerRunning = false;
  int _remainingTime = 3600; // 1 hour in seconds
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSignupState();
  }

  void _loadSignupState() async {
    _prefs = await SharedPreferences.getInstance();
    final int? disabledTimestamp = _prefs.getInt('signup_disabled_timestamp');

    if (disabledTimestamp != null) {
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      final int elapsedTime = (currentTime - disabledTimestamp) ~/ 1000;

      if (elapsedTime < _remainingTime) {
        setState(() {
          _isSignupEnabled = false;
          _remainingTime = _remainingTime - elapsedTime;
          _startTimer();
        });
      }
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });

    const oneSec = const Duration(seconds: 1);
    Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_remainingTime == 0) {
          timer.cancel();
          _enableSignup();
        } else {
          setState(() {
            _remainingTime--;
          });
        }
      },
    );
  }

  void _enableSignup() {
    setState(() {
      _isSignupEnabled = true;
      _isTimerRunning = false;
      _remainingTime = 3600;
    });
    _prefs.remove('signup_disabled_timestamp');
  }

  void _showPasscodePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String passcode = '';
        return AlertDialog(
          title: Text('Enter Passcode'),
          content: TextField(
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            onChanged: (value) {
              passcode = value;
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (passcode == '1234') {
                  Navigator.of(context).pop();
                  setState(() {
                    _isSignupEnabled = false;
                  });
                  _prefs.setInt(
                      'signup_disabled_timestamp',
                      DateTime.now()
                          .millisecondsSinceEpoch); // Store current timestamp
                  _startTimer();
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final secondsFormatted = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secondsFormatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Master Exit Button Demo'),
      ),
      body: Center(
        child: _isSignupEnabled
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showPasscodePopup,
              child: Text('Master Exit'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: Text('Go to Signup'),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Signup Page would appear in:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              _formatDuration(_remainingTime),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup Page'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Signup Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Other signup page components
          ],
        ),
      ),
    );
  }
}
