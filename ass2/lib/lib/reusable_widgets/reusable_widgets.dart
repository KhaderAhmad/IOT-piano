import 'package:flutter/material.dart';

Widget reusableTextField(String text, IconData icon, bool isPasswordType, TextEditingController controller, bool hasError) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      controller: controller,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType,
      autocorrect: !isPasswordType,
      cursorColor: const Color(0xFF101213),
      style: const TextStyle(color: Color(0xFF101213), fontSize: 14.0, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500), // Updated text style
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF57636C)), // Icon color
        labelText: text,
        labelStyle: const TextStyle(color: Color(0xFF57636C), fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500), // Label color and style
        filled: true,
        fillColor: const Color(0xFFF1F4F8), // Background color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none, // Remove border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none, // Remove border color when focused
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red), // Remove border color when error
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red), // Remove border color when error and focused
        ),
        errorText: hasError ? 'Invalid ${text}' : null,
      ),
      keyboardType: isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,

    ),

  );
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap){
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if(states.contains(MaterialState.pressed)){
            return Colors.black26;
          }
          return Color(0xFF4B39EF);
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)))),
      child: Text(
        isLogin ? 'LOG IN' : 'SIGN UP',
        style: const TextStyle(
          color: Color(0xFFF1F4F8),fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 16
        ),
      ),
    ),
  );
}

