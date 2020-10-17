import 'dart:convert';

import 'package:buscador_gifs_app/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async{
    http.Response response;

    if(_search == null || _search.isEmpty){
      response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=f4DZdF2NY2juzo7ZTHYcMrrgYXihxV0d&limit=20&rating=g');

    } else {
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=f4DZdF2NY2juzo7ZTHYcMrrgYXihxV0d&q=$_search&limit=19&offset=$_offset&rating=g&lang=en");
    }
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      return map['data']['images']['original']['url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Image.network('https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Pesquise seu gif aqui',
                  labelStyle: TextStyle(color: Colors.cyan),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.cyan , fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
              future: _getGifs(),
                builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.00,
                      height: 200.00,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                        strokeWidth: 5.0,
                      ),
                    );
                    default:
                      if(snapshot.hasError) return Container();
                      else return  _createGifTable(context,snapshot);
                }
                },
          ))
        ],
      ),

    );
  }

  int getCount(List data){
    if(_search == null){
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0
        ),
        itemCount: getCount(snapshot.data['data']),
        itemBuilder: (context, index){
          if(_search == null || index < snapshot.data['data'].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']['fixed_height']['url'],
                height: 300.0,
                fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => GifPage(snapshot.data['data'][index]) ));
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.cyanAccent, size: 22.0),
                    Text('Carregar mais...',
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 22.0),)
                  ],
                ),
                onTap: (){
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        });
  }
}
