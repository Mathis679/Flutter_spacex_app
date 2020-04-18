import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spacexapp/Launch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<List<Launch>> futureLaunch;
  List<Launch> datas = new List();
  ScrollController _scrollController = new ScrollController();


  void showSimpleCustomDialog(BuildContext context, String text, String url) {
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          height: 300.0,
          width: 300.0,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
          Padding(
          padding: EdgeInsets.all(15.0),
          child: _notNullText(text) ? Text(
            text,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ):
          Text(
            "No data",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _notNullText(url) ?
              RaisedButton(
                color: Colors.blue,
                onPressed: () {

                  _launchURL(url);
                  //Navigator.of(context).pop();
                },child: Text(
                'Read More',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              ):Text('Not anymore info'),


                ],
            ),
        ),
              ],
          ),
        ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _notNullText(String text) {
    if (text != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    final title = 'SpaceX launches';

    Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
      datas = snapshot.data;
      return new ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        controller: _scrollController,
        itemCount: datas.length,
        itemBuilder: (BuildContext context, int index) {
          return new Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    showSimpleCustomDialog(context, datas[index].details, datas[index].links.article_link);
                  });
                },
                child: Row(
                    children: [
                      Container(
                          width: 75,
                          height: 75,
                          margin: EdgeInsets.fromLTRB(10, 10, 50, 10),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child:datas[index].links.mission_patch != null ? Image.network(datas[index].links.mission_patch,
                                width: 75, height: 75, fit: BoxFit.contain,) : Container()
                              )),


                      Flexible(
                          child: Text(datas[index].mission_name,


                          style: GoogleFonts.lato(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold,),
                          ),
                      )
                    ]),
              ),
              
              new Divider(
                height: 2.0,
                color: Colors.white,
              ),
            ],
          );
        },
      );
    }

    var futureBuilder = new FutureBuilder(
      future: futureLaunch,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Container(
                height: double.infinity,
                width: double.infinity,child:Center(child: Text('loading...'),));

          default:
            if (snapshot.hasError)
              return new Container(
                  height: double.infinity,
                  width: double.infinity,child:Center(child: Text('Error: ${snapshot.error}'),));
            else
              return createListView(context, snapshot);
        }
      },
    );



    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        ),
        body:
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.tealAccent, Colors.cyan, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                  )
              ),
              child: futureBuilder,
            ),

      ),
    );
  }

  Future<List<Launch>> fetchLaunch(String offset) async {
    final response = await http.get('https://api.spacexdata.com/v3/launches?limit=10&offset='+offset);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(json.decode(response.body));
      Iterable l = json.decode(response.body);
      List<Launch> list = l.map((i)=> Launch.fromJson(i)).toList();
      setState(() {
        datas.addAll(list);
      });

      return list;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }



  @override
  void initState() {
    super.initState();
    futureLaunch = fetchLaunch("0");
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        //bottom page
        fetchLaunch(datas.length.toString());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

}
