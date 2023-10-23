import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/html.dart';

import '../responsive.dart';

class LoginPage extends StatefulWidget {
  LoginPage(
      {super.key, required this.title, required this.channel, this.errorMsg});

  String? errorMsg;
  final String title;
  final HtmlWebSocketChannel channel;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    widget.channel.sink
        .add('{"action": "AUTH", "value": "${passwordController.text}"}');
  }

  void loginSubmit(String input) {
    login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Padding(
          padding: isPhone(context)
              ? const EdgeInsets.all(8.0)
              : const EdgeInsets.all(18.0),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          Icon(
                            Icons.local_police,
                            size: 35,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Timelapse Auth",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(
                          "Enter password in order to get access into timelapse web panel",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          obscureText: true,
                          autofocus: true,
                          onSubmitted: loginSubmit,
                          controller: passwordController,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Password',
                              errorText: widget.errorMsg),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: login,
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18, // Ustaw rozmiar czcionki na 24
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
