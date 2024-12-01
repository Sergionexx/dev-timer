import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
            child: Text(
          widget.title,
        )),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 0, 0)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "00:00:00",
                style: TextStyle(
                    fontFamily: "Pixelify", color: Colors.white, fontSize: 60),
              ),
              Image.asset(
                'assets/gifs/CoffeCompleteWhite.gif',
                height: 425.0,
                width: 425.0,
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Star Day'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
