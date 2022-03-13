import 'package:flutter/material.dart';

class Offline extends StatefulWidget {
  const Offline({Key? key, this.status}) : super(key: key);
  final String? status;
  @override
  State<Offline> createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  String? get _status {
    return widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: _status == 'ConnectivityResult.none'
          ? Colors.red[800]
          : Colors.yellow[800],
      height: 30,
      child: Text(
        _status == 'ConnectivityResult.none' ? 'offline' : 'on mobile data',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
