import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:iz_properties/bloc/house_log_bloc.dart';
import 'package:iz_properties/dashboard.dart';
import 'bloc/counter_bloc.dart';

/// Flutter code sample for [ElevatedButton].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<CounterBloc>(
        create: (context) => CounterBloc(),
      ),
      BlocProvider<HouseLogBloc>(
        create: (context) => HouseLogBloc(),
      ),
    ],
    child: MaterialApp(
      home: const LoginPage(),
      builder: EasyLoading.init(),
    ),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  late String name;
  var enabled = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onPressed = enabled
        ? () async {
            try {
              final credential =
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: usernameController.text,
                password: passwordController.text,
              );

              if (FirebaseAuth.instance.currentUser != null) {
                // user can login into the dashboard
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const DashboardPage())));
              }
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                print('No user found for that email.');
              } else if (e.code == 'wrong-password') {
                print('Wrong password provided for that user.');
              }
            } catch (e) {
              print(e);
            }
          }
        : null;
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      title: 'Button Types',
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 200),
                  Text('welcome to I.Z. Properties'),
                  TextFormField(
                    decoration: InputDecoration(labelText: "username"),
                    controller: usernameController,
                  ),
                  TextFormField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(labelText: "password"),
                    controller: passwordController,
                  ),
                  SizedBox(height: 20),
                  FilledButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black)),
                      onPressed: onPressed,
                      child: const Text('Enter')),
                ],
              )),
        ),
      ),
    );
  }
}

class LoginPage2 extends StatelessWidget {
  const LoginPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      title: 'Button Types',
      home: const Scaffold(
        body: LoginFormPage(),
      ),
    );
  }
}

class LoginFormPage extends StatelessWidget {
  const LoginFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          // Spacer(),
          // ButtonTypesGroup(enabled: true),
          // ButtonTypesGroup(enabled: false),
          // Spacer(),
        ],
      ),
    );
  }
}

class ButtonTypesGroup extends StatelessWidget {
  const ButtonTypesGroup({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onPressed = enabled ? () {} : null;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(onPressed: null, child: const Text('Elevateds')),
          FilledButton(onPressed: onPressed, child: const Text('Filled')),
          FilledButton.tonal(
              onPressed: onPressed, child: const Text('Filled Tonal')),
          OutlinedButton(onPressed: onPressed, child: const Text('Outlined')),
          TextButton(onPressed: onPressed, child: const Text('Text')),
        ],
      ),
    );
  }
}
