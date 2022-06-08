import 'dart:convert';

import 'package:edu_valley/constants.dart';
import 'package:edu_valley/models/ad.dart';
import 'package:edu_valley/models/comment.dart';
import 'package:edu_valley/models/poster.dart';
import 'package:edu_valley/models/user.dart';
import 'package:edu_valley/services/api.dart';
import 'package:edu_valley/screens/ad/ad_profile_screen.dart';
import 'package:edu_valley/widgets/appbar.dart';
import 'package:edu_valley/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ValleyPage extends StatefulWidget {
  const ValleyPage({Key? key, this.userId}) : super(key: key);
  final int? userId;
  @override
  _ValleyPageState createState() => _ValleyPageState();
}

class _ValleyPageState extends State<ValleyPage> {
  int? get _userId {
    return widget.userId;
  }

  // String? comment;

  final _commentController = TextEditingController();

  List<dynamic>? _categories;
  String _selectedValue = "All";
  String _search = '';
  bool _sending = false;
  // String? _comment;
  int _adStarsCount = 0;
  int _adCommentsCount = 0;
  List<dynamic>? _userStarredAds;
  List<dynamic>? _userCommentedAds;
  final _formKey = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> get _dropdownItems {
    List<DropdownMenuItem<String>> menuItems = _categories == null
        ? [
            DropdownMenuItem(child: Text("All"), value: "All"),
          ]
        : [
            DropdownMenuItem(child: Text("All"), value: "All"),
            ..._categories!
                .map(
                  (category) => DropdownMenuItem(
                      child: Text(category), value: "$category"),
                )
                .toList()
          ];
    return menuItems;
  }

  _pluckCategories() async {
    final response = await http.get(Uri.parse(
      '${Network.url}/pluckCategories',
    ));
    setState(() {
      _categories = jsonDecode(response.body);
    });
  }

  // _starredFun(adId) async {
  //   final response = await http.get(Uri.parse(
  //     '${Network.url}/stars/get/$_userId/$adId',
  //   ));
  //   var body = jsonDecode(response.body);
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   await localStorage.setString('courseIds', json.encode(body));
  //   var starred = await jsonDecode(localStorage.getString('courseIds')!);
  //   if (starred == 1) {
  //     setState(() {
  //       _starred = true;
  //     });
  //   } else {
  //     setState(() {
  //       _starred = false;
  //     });
  //   }
  // }

  Future<int> _fetchAdStars(adId) async {
    //stars of ad
    final response =
        await http.get(Uri.parse('${Network.url}/stars/get/ad/$adId'));
    var body = jsonDecode(response.body);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    await localStorage.setString('adStars', json.encode(body));
    var adStars = await jsonDecode(localStorage.getString('adStars')!);
    if (adStars == 0) {
      _adStarsCount = 0;
    } else {
      _adStarsCount = adStars.length;
    }
    return _adStarsCount;
  }

  Future<int> _fetchAdComments(adId) async {
    //stars of ad
    final response =
        await http.get(Uri.parse('${Network.url}/comments/get/ad/$adId'));
    var body = jsonDecode(response.body);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    await localStorage.setString('adComments', json.encode(body));
    var adComments = await jsonDecode(localStorage.getString('adComments')!);
    if (adComments == 0) {
      _adCommentsCount = 0;
    } else {
      _adCommentsCount = adComments.length;
    }
    return _adCommentsCount;
  }

  _userStarredAdsFun() async {
    //stars of user
    var userStarsResponse = await http.get(
      Uri.parse('${Network.url}/stars/userStarredAds/$_userId'),
    );
    _userStarredAds = jsonDecode(userStarsResponse.body);
    print(_userStarredAds);
  }

  _userCommentedAdsFun() async {
    //stars of user
    var userCommentsResponse = await http.get(
      Uri.parse('${Network.url}/comments/userCommentedAds/$_userId'),
    );
    _userCommentedAds = jsonDecode(userCommentsResponse.body);
    print(_userCommentedAds);
  }

  @override
  void initState() {
    _userStarredAdsFun();
    _userCommentedAdsFun();
    _pluckCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, "Fun ", menu),
      endDrawer: CustomDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: sky()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Category:",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 25),
                  DropdownButton(
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    value: _selectedValue,
                    items: _dropdownItems,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedValue = newValue!;
                        newValue == "All" ? _search = '' : _search = newValue;
                      });
                    },
                  ),
                ],
              ),
              FutureBuilder<List<Ad>>(
                future: _search == ''
                    ? fetchAds(http.Client())
                    : searchAds(http.Client(), _search),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SizedBox(
                      // height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            Text(
                              'It feels lonely here... \nWanna create some fun?',
                              // '${snapshot.error}',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!
                          .map(
                            (ad) => GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdProfileScreen(
                                    adId: ad.id,
                                    name: ad.name,
                                    site: ad.site,
                                  ),
                                ),
                              ),
                              child: Container(
                                width: 350,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: const Offset(
                                        2,
                                        3,
                                      ), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<Poster>(
                                      future: fetchFirstPoster(ad.id),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    snapshot.data!.url,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return SizedBox()
                                              // Text('${snapshot.error}')
                                              ;
                                        }
                                        // By default, show a loading spinner.
                                        return Container();
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(width: 10),
                                            TextButton.icon(
                                              onPressed: () => _star(ad.id),
                                              icon: Icon(
                                                Icons.star,
                                                size: 30,
                                                color:
                                                    _userStarredAds != null &&
                                                            _userStarredAds!
                                                                .contains(ad.id)
                                                        ? Colors.yellow[800]
                                                        : Colors.grey,
                                              ),
                                              label: FutureBuilder(
                                                future: _fetchAdStars(ad.id),
                                                initialData: 0,
                                                builder: (BuildContext context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                      // '${snapshot.error}',
                                                      'error',
                                                    );
                                                  } else if (snapshot.hasData) {
                                                    return Text(
                                                      '${snapshot.data}',
                                                    );
                                                  } else {
                                                    return SizedBox(
                                                      height: 15,
                                                      width: 15,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Center(
                                          child: Text(
                                            ad.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            TextButton.icon(
                                              onPressed: () =>
                                                  _commentSection(ad.id),
                                              icon: Icon(
                                                Icons.comment,
                                                size: 30,
                                                color:
                                                    _userCommentedAds != null &&
                                                            _userCommentedAds!
                                                                .contains(ad.id)
                                                        ? Colors.greenAccent
                                                        : Colors.grey,
                                              ),
                                              label: FutureBuilder(
                                                future: _fetchAdComments(ad.id),
                                                // initialData: 0,
                                                builder: (BuildContext context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                      // '${snapshot.error}',
                                                      'error',
                                                    );
                                                  } else if (snapshot.hasData) {
                                                    return Text(
                                                      '${snapshot.data}',
                                                    );
                                                  } else {
                                                    return SizedBox(
                                                      height: 15,
                                                      width: 15,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10)
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  } else {
                    return Container(
                      color: Theme.of(context).primaryColor,
                      height: MediaQuery.of(context).size.height,
                      child: splashScreen,
                    );
                  }
                },
              ),
              SizedBox(height: 50),
              Divider(
                height: 20,
                thickness: 2,
                indent: 100,
                endIndent: 100,
                color: Colors.grey,
              ),
              Text(
                "To the users... \neduValley values the talents✨ \nof the students.\n We would like to bring your talent \nto the audience in this valley.\nNever afraid to contact us \nto display your talents \nor creative videos here.😉",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              Divider(
                height: 20,
                thickness: 2,
                indent: 100,
                endIndent: 100,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                "To the advertisers... \neduValley provides \nthe next level ✨ advertising,\n check Mindvalley for example.",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              Divider(
                height: 20,
                thickness: 2,
                indent: 100,
                endIndent: 100,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                "To advertise \nyour amazing product✨ here,\n don't forget to contact 😉...",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              urlButton(
                context,
                'https://www.facebook.com/EduValley-104744954899008',
                "eduValley",
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  _star(int adId) async {
    var data = {'ad_id': "$adId", 'user_id': "$_userId"};
    await http.post(
      Uri.parse('${Network.url}/stars/star'),
      body: data,
    );
    _userStarredAdsFun();
    setState(() {});
  }

  _commentSection(int adId) {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter commentState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  gradient: sky(),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(25.0),
                    topRight: const Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Form(
                        key: _formKey,
                        child: ListTile(
                          horizontalTitleGap: 15,
                          leading: Icon(
                            Icons.comment,
                            size: 40,
                          ),
                          title: TextFormField(
                            controller: _commentController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Write a comment...',
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              // print(_commentController.text.runtimeType);
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _sending = true;
                                });
                                var data = {
                                  'content': _commentController.text,
                                  'ad_id': "$adId",
                                  'user_id': "$_userId"
                                };
                                await http.post(
                                  Uri.parse('${Network.url}/comments/create'),
                                  body: data,
                                );
                                _commentController.clear();
                                _userCommentedAdsFun();
                                setState(() {
                                  _sending = false;
                                });
                                Navigator.pop(context);
                              } else {
                                print('Comment is null');
                              }
                            },
                            // print(
                            //     'comment added'),
                            child: Icon(
                              Icons.send_rounded,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    FutureBuilder<List<Comment>>(
                      future: fetchComments(
                        http.Client(),
                        adId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        } else if (snapshot.hasData) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                  children: snapshot.data!
                                      .map((comment) => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FutureBuilder<List<User>>(
                                                  future: fetchCommentOwner(
                                                      http.Client(),
                                                      comment.userId),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                          "${snapshot.error}");
                                                    } else if (snapshot
                                                        .hasData) {
                                                      return Column(
                                                        children: snapshot.data!
                                                            .map(
                                                                (owner) => Text(
                                                                      owner.name
                                                                          .toUpperCase(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                    ))
                                                            .toList(),
                                                      );
                                                    } else {
                                                      return LinearProgressIndicator();
                                                    }
                                                  }),
                                              PopupMenuButton(
                                                elevation: 40,
                                                color: Colors.black54,
                                                itemBuilder: (context) {
                                                  return <PopupMenuItem>[
                                                    // PopupMenuItem(
                                                    //   child: TextButton.icon(
                                                    //     onPressed: () =>
                                                    //         print('Edit'),
                                                    //     icon: Icon(Icons.edit),
                                                    //     label: Text(
                                                    //       'Edit',
                                                    //       style: TextStyle(
                                                    //         color: Colors.white,
                                                    //         fontWeight:
                                                    //             FontWeight.bold,
                                                    //         fontSize: 18,
                                                    //       ),
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    PopupMenuItem(
                                                      child: TextButton.icon(
                                                        onPressed: () async {
                                                          var res =
                                                              await http.delete(
                                                            Uri.parse(
                                                                "${Network.url}/comments/delete/${comment.id}"),
                                                          );
                                                          print(res.body);
                                                          // Navigator.pop(
                                                          //     context);
                                                        },
                                                        icon:
                                                            Icon(Icons.delete),
                                                        label: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                child: Text(
                                                  comment.content,
                                                  // "Seigi wa kanarazu katsu alsdfjalsdfjasl;dfalskjl;askdfjl;sadkfjl;asdkfjl;sadfjka;slfdjkasdl;fkjsaldf;kjasd;lfkjasl;dfkjasdl;fkjasd;flkjasdfl;kjsadfl;kjasl;fkjasdlfkjasdlfkjsadl;fkjasdl;fkjasdlfkjasdfl;kjsdafl;kjasdfl;kjasdfl;kjasdflk;asjdfl;sadfkjfdkjas;lfkjdasl;dkfjasl;dkfjsadl;kfjsdflkjasldk;fjsadfl;ksdl;fkjsadl;fkjasdlfkjasdlfjkasdl;fkjasdflkjsdfkladjflk;j",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ),
                                              Divider(
                                                height: 20,
                                                color: Colors.black45,
                                              ),
                                            ],
                                          ))
                                      .toList()),
                            ),
                          );
                        } else {
                          return LinearProgressIndicator();
                        }
                      },
                    )
                  ],
                ),
              );
            },
          );
        });
  }
}
