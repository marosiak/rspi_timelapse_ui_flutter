import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../responsive.dart';

class LoginPage extends StatefulWidget {
  LoginPage(
      {super.key, required this.title, required this.channel, this.errorMsg});

  String? errorMsg;
  final String title;
  final WebSocketChannel channel;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = TextEditingController();
  bool shouldRememberPassword = false;
  bool isLoading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedPassword = prefs.getString('password');
      if (savedPassword != null) {
        passwordController.text = savedPassword;
        login();
        isLoading = false;
      }
      isLoading = false;
    });
    super.initState();

  }

  @override
  Future<void> dispose() async {
    if (shouldRememberPassword) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('password', passwordController.text);
      });
    }
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
          child: isLoading ? Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 200,
            )) : Center(
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
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              shouldRememberPassword = !shouldRememberPassword;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  child: IgnorePointer(
                                    ignoring: true,
                                    child: Checkbox(
                                      focusNode: FocusNode(skipTraversal: true),
                                      value: shouldRememberPassword,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          shouldRememberPassword = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text("Keep me logged"),
                              ],
                            ),
                          ),
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
