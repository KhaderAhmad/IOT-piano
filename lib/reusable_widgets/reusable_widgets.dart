import 'package:flutter/material.dart';

Widget reusableTextField(String hintText, IconData icon, bool isPasswordType,
    TextEditingController controller, bool isError) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      labelText: hintText,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(width: 0, style: BorderStyle.none),
      ),
      errorText: isError ? 'Invalid Input' : null,
    ),
    keyboardType:
        isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,
    textInputAction: TextInputAction.done,
  );
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'LOG IN' : 'SIGN UP',
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)))),
    ),
  );
}

Widget floatingQuestionMark(BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      _showInfoDialog(context);
    },
    child: Icon(Icons.help_outline),
    backgroundColor: Colors.blue,
  );
}

void _showInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('About the Project'),
        content: SingleChildScrollView( // This allows the content to scroll if it's too large
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app is designed to help you learn and manage your music tasks. '
                'You can record, play, and track your progress through various songs. '
                'Navigate through the different sections using the menu, and enjoy learning!\n\n'
                'Here\'s how to use the app:',
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 16),
                  SizedBox(width: 10),
                  Expanded( // This ensures the text wraps inside the available space
                    child: Text(
                      'Press the Start button (green) to begin the mode.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.red, size: 16),
                  SizedBox(width: 10),
                  Expanded( // This ensures the text wraps inside the available space
                    child: Text(
                      'Press the Exit button (red) to stop the mode.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
