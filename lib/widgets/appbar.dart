import 'package:flutter/material.dart';

AppBar appBar(BuildContext context, String title, Icon icon) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
      child: CircleAvatar(
        backgroundImage: AssetImage("assets/img/eduValley.png"),
      ),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        title.contains('valley') || title.contains("Valley")
            ? SizedBox()
            : Text(
                'Valley',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
      ],
    ),
    centerTitle: true,
    actions: [
      Builder(
        builder: (context) => IconButton(
          icon: icon,
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
    ],
  );
}
