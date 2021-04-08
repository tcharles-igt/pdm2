import 'package:pdm2/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var _pesquisar;
  var _offset = 0;

  Future<Map> _getGif() async {
    var response;

    if(_pesquisar != null){
      response = await http.get('https://api.giphy.com/v1/gifs/search?api_key=uLb3qs2R6uGlpOlA3NIabuhHW7px7KIT&q=$_pesquisar&limit=14&offset=$_offset&rating=g&lang=en');
    }else{
      response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=uLb3qs2R6uGlpOlA3NIabuhHW7px7KIT&limit=19&rating=g&offset=$_offset');
    }

    return json.decode(response.body);
  }

  // ##################################################
  // # _createGifTable ################################
  // ##################################################

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: snapshot.data["data"].length + 1,
      itemBuilder: (context, index){
        if(index == snapshot.data["data"].length){
          return GestureDetector(
            child: Center(
              child: Text("Carregar mais...", style: TextStyle(color: Colors.white),),
            ),
            onTap: (){
              setState(() {
                _offset += 19;
              });
            },
          );
        }else{
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push((context), MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data["data"][index])
              ));
            },
          );
        }
      },
    );
  }

  // ##################################################
  // # build ##########################################
  // ##################################################

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Buscar...",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _pesquisar= text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGif(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      return _createGifTable(context, snapshot);
                  }
                }
            ),
          ),
        ],
      ),
    );
  }
}