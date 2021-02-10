import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static String token = "";
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LoadingScreen(),
        '/login': (context) => LoginScreen(),
        '/post': (context) => PostScreen()
      },
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String txt = 'Connecting to server';
  void connectApp() async {
    Response conn =
        await post('http://127.0.0.1:3001/connect', body: {"id": "C1010100"});
    print(conn.body);
    Map data = jsonDecode(conn.body);
    if (data['status'] == 'ok') {
      Navigator.pushNamed(context, '/login');
    } else {
      setState(() {
        txt = 'connection failed';
      });
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    connectApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            txt,
            style: TextStyle(fontSize: 25.0),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();
  String txt = '';
  void LoginApp() async {
    Response login = await post('http://127.0.0.1:3001/login',
        body: {"username": user.text, "password": pass.text});
    print(login.body);
    Map data = jsonDecode(login.body);
    if (data['status'] == 'ok') {
      if (data['value'] == 'success') {
        setState(() {
          MyApp.token = data['token'];
          Navigator.pushNamed(context, '/post');
          print('login success');
          print(MyApp.token);
        });
      } else {
        setState(() {
          txt = "Incorrect Password";
        });
      }
    } else {
      setState(() {
        txt = "Enter valid input";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: user,
              decoration: InputDecoration(
                labelText: 'username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              controller: pass,
            ),
            SizedBox(
              height: 50.0,
            ),
            FlatButton(
              onPressed: () {
                LoginApp();
              },
              child: Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Text(
              txt,
              style: TextStyle(color: Colors.red, fontSize: 20.0),
            )
          ],
        ),
      ),
    );
  }
}

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Widget> allPosts = [];
  Map d;
  void showPosts() async {
    Response res =
        await post('http://127.0.01:3001/posts', body: {"token": MyApp.token});

    List data = jsonDecode(res.body);

    data.forEach((element) {
      d = element;
      onePost(element['title'], element['text']);
    });
    setState(() {
      allPosts;
    });
    return;
  }

  void onePost(String title, String text) {
    Widget a = Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 25.0),
          ),
          SizedBox(
            height: 3.0,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
    allPosts.add(a);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text("PostsApp"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            children: allPosts,
          ),
        ),
      ),
    );
  }
}
