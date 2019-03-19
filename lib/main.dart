//TODO:enable ad
//TODO:enable messaging

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample for material.AppBar.actions',
      theme: ThemeData(primarySwatch: Colors.amber, fontFamily: 'ConcertOne'),
      home: MainPage(),
    );
  }
}

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

bool _adShown;

class MainPage extends StatefulWidget {
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>[
      'flutterio',
      'beautiful apps',
      'shopping',
      'lifestyle',
      'cricket',
      'sports',
      'television',
      'Treatment ',
      'Software',
      'Marriage',
      'Classes',
      'Recovery',

    ],
    //contentUrl: 'https://flutter.io',
    childDirected: true,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  BannerAd myBanner;

  BannerAd createBannerAd() {
    return new BannerAd(
      adUnitId: "ca-app-pub-2643039652331613/9544265370",
      targetingInfo: targetingInfo,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          _adShown = true;
          setState(() {});
        } else if (event == MobileAdEvent.failedToLoad) {
          _adShown = false;
          setState(() {});
        }
      },
    );
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var dtNow = new DateTime.now();

  void _refreshData() {
    setState(() {
      dtNow = DateTime.now().toLocal();
    });
  }

  void initState() {
    _adShown = false;
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-2643039652331613~4945355443");
    myBanner = createBannerAd()
      ..load()
      ..show(anchorOffset: 0.0, anchorType: AnchorType.bottom);

    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
      },
    );
  }

  _displaySnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blueAccent,
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future buildAbout(context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Center(
            child: Card(
              color: Colors.white,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text("Version"),
                    subtitle: Text("1.1"),
                    trailing: FlatButton(
                      onPressed: () {
                        _launchURL(
                            "https://aithal-dev.webnode.in/app-listing/");
                      },
                      child: Text("Release Notes"),
                      color: Colors.cyan,
                    ),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.amazon),
                    title: Text("Credit"),
                    subtitle: Text(
                        "All items, their images, offer details, price and ratings are sourced from amazon.in site \n "),
                    //trailing: FlatButton(onPressed: (){_launchURL("https://aithal-dev.webnode.in/");}, child: Text("Release Notes"),color: Colors.cyan, ),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.dev),
                    title: Text("Developer"),
                    subtitle: Text("Aithal.Dev\n "),
                    trailing: FlatButton(
                      onPressed: () {
                        _launchURL("https://aithal-dev.webnode.in/");
                      },
                      child: Text("Contact"),
                      color: Colors.pinkAccent,
                    ),
                  ),
                  ListTile(
                    subtitle: Center(
                      child: Text(
                        "Press back button to go back to the application",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print("Adshow status $_adShown");
    var formatter = new DateFormat('dd-MM-yyyy hh:mm:ss');
    var dtFrmt = formatter.format(dtNow);

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.shopping_basket),
        title: Text('Amazon.in Top Deals',
            style: new TextStyle(
              inherit: false,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            )),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                  icon: Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () {
                    _refreshData;
                    _displaySnackBar(context, "List is up to date");
                  },
                ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'About', //TODO: Show a dialogue
            onPressed: () {
              // ...
              buildAbout(context);
              print("Button pressed");
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.date_range),
              title: Text(
                "Last Synced..",
                style: TextStyle(
                    fontFamily: "Concert One", fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "$dtFrmt",
                style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w100),
              ),
            ),
            StreamBuilder(
                stream: Firestore.instance.collection("amzItems").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text("Loading");
                  //setState(() {
                  dtNow = DateTime.now().toLocal();
                  //});
                  return cardsWidget(context, snapshot.data.documents[0], 0);
                }),
            StreamBuilder(
                stream: Firestore.instance.collection("amzItems").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data.documents.length < 2)
                    return const Text("Loading 2nd item...");
                  dtNow = DateTime.now().toLocal();
                  return cardsWidget(context, snapshot.data.documents[1], 1);
                }),
            StreamBuilder(
                stream: Firestore.instance.collection("amzItems").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data.documents.length < 3)
                    return const Text("Loading 3rd item...");
                  dtNow = DateTime.now().toLocal();
                  return cardsWidget(context, snapshot.data.documents[2], 2);
                }),
            StreamBuilder(
                stream: Firestore.instance.collection("amzItems").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data.documents.length < 4)
                    return const Text("Loading 4th item...");
                  dtNow = DateTime.now().toLocal();
                  return cardsWidget(context, snapshot.data.documents[3], 3);
                })
          ],
        ),
      ),
      persistentFooterButtons: _adShown
          ? <Widget>[
              new Container(
                height: 40.0,
              )
            ]
          : null,
    );
  }

  Widget cardsWidget(BuildContext context, DocumentSnapshot data, int lev) {
    //final record = Record.fromMap(data);
    var imgUrl = data.data['imgUrl'].toString();
    var itmUrl = data.data['itmUrl'].toString();
    var itName = data.data['name'].toString();
    var offer = data.data['offer'].toString();
    var price = data.data['price'].toString();
    var rating = data.data['rating'].toString();

    print(
        "The returned value is \n $itmUrl \n $imgUrl \n $itName \n $offer \n $price \n $rating");
    IconData _buildIcon() {
      if (lev == 0) return Icons.looks_one;
      if (lev == 1) return Icons.looks_two;
      if (lev == 2) return Icons.looks_3;
      if (lev == 3) return Icons.looks_4;
      return Icons.warning;
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Icon(
              _buildIcon(),
              size: 40.0,
              color: Colors.brown,
            ),
            trailing: Image.network(
              imgUrl,
              scale: 13.0,
            ),
            title: Text(
              itName,
              style: TextStyle(
                  inherit: false,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontSize: 20.0),
            ),
            subtitle: RichText(
              textAlign: TextAlign.start,
              //textDirection: TextDirection.ltr,
              text: TextSpan(
                text: '\n',
                style: TextStyle(
                    fontStyle: FontStyle.normal, color: Colors.redAccent),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Price:\t\t\t',
                      style: TextStyle(
                          inherit: false,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5)),
                  TextSpan(
                      text: '$price\n',
                      style: TextStyle(
                          inherit: false,
                          fontWeight: FontWeight.w300,
                          fontSize: 16.5)),
                  TextSpan(
                      text: 'Rating:\t',
                      style: TextStyle(
                          inherit: false,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5)),
                  TextSpan(
                      text: '$rating\n',
                      style: TextStyle(
                          inherit: false,
                          fontWeight: FontWeight.w300,
                          fontSize: 16.5)),
                  TextSpan(
                      text: 'Offer Details ',
                      style: TextStyle(
                          inherit: false,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5)),
                  TextSpan(
                      text: '$offer\n',
                      style: TextStyle(
                          inherit: false,
                          fontWeight: FontWeight.w300,
                          fontSize: 16.5)),
                ],
              ),
            ),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Icon(Icons.shopping_basket),
                  onPressed: () {
                    _launchURL("$itmUrl");
                  },
                ),
                FlatButton(
                  child: const Icon(Icons.share),
                  onPressed: () {
                    Share.share(
                        "Check out this item I found in amazon.in \n $itName \n $itmUrl");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
