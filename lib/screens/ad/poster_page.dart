import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:edu_valley/models/poster.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class PosterPage extends StatefulWidget {
  const PosterPage({Key? key, this.posters}) : super(key: key);
  final List<Poster>? posters;
  @override
  _PosterPageState createState() => _PosterPageState();
}

class _PosterPageState extends State<PosterPage> {
  List<Poster>? get _posters {
    return widget.posters;
  }

  String _connectionStatus = 'ConnectivityResult.wifi';
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      setState(() {
        _connectionStatus = event.toString();
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 2,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: sky()),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _connectionStatus != 'ConnectivityResult.wifi'
                    ? Offline(status: _connectionStatus)
                    : SizedBox(),
                Column(
                  children: [
                    SizedBox(height: 15),
                    (() {
                      if (_posters == null) {
                        return Text('loading...');
                      } else if (_posters!.length == 0) {
                        return Container(
                          child: Center(
                            child: Text(
                              "No poster available.",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          height: MediaQuery.of(context).size.height * 0.2,
                        );
                      } else {
                        return Wrap(
                          children: _posters!
                              .map((book) => GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushNamed(
                                      "/book",
                                      arguments: book.url,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Stack(
                                        children: [
                                          Container(
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                              ),
                                            ),
                                            height: 100,
                                            width: 150,
                                          ),
                                          _posters!.length < 4
                                              ? Image.network(book.url)
                                              : Image.network(
                                                  book.url,
                                                  height: 100,
                                                  width: 150,
                                                  cacheHeight: 100,
                                                  cacheWidth: 150,
                                                  fit: BoxFit.cover,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      }
                    })(),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
