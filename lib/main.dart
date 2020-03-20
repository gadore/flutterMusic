import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<MusicItem>> fetchMusicList(http.Client client) async {
  var url = 'http://server.gadore.me:2333/music';
  var urlString =
      "{\"url\":\"http://music.163.com/playlist/72210253/68328243/?userid=68328243\"}";
  var response = await client
      .post(url, body: urlString, headers: {"Accept": "application/json"});
  return compute(parseMusic, response.body);
}

List<MusicItem> parseMusic(String responseBody) {
  var parsed = jsonDecode(responseBody)["data"];
  var list = new List<MusicItem>();
  for (var jObj in parsed) {
    var m = new MusicItem();
    m.id = jObj["id"].toString();
    m.name = jObj["name"].toString();
    list.add(m);
  }
  return list;
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
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

class MusicItem {
  String id;
  String name;
  MusicItem({this.id,this.name});
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<MusicItem>>(
        future: fetchMusicList(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? MusicList(songs: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MusicList extends StatelessWidget {
  final List<MusicItem> songs;
  MusicList({Key key, this.songs}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context,index){
        return new ListTile(
          title: new Text('${songs[index].name}')
        );
    },);
  }
}
