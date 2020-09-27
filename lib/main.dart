import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:wiflut/models/wiki_item.dart';
import 'package:wiflut/services/wiki_service.dart';


void main() {
  runApp(WiFlut());
}

enum PageState{
  LOADING,
  MAIN,
  ARTICLE
}
class WiFlut extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFlut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF555555)
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {




  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color _shadedColor;
  Color _color =  Color(0xFF555555);
  TextEditingController _txtQuery = new TextEditingController();
  PageState _state = PageState.LOADING;
  WikiItem _item;
  List<WikiItem> _randomItems;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadRandomArticle();
  }



  @override
  Widget build(BuildContext context) {
    _shadedColor = TinyColor(_color).lighten(30).color;
    return Scaffold(

      body: AnimatedContainer(

        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [_shadedColor, _color],
            center: Alignment.topCenter,
            radius: 2,
          ),
        ),
        duration: Duration(milliseconds: 200),
        child: _getPage(),
      ),

    );
  }


  _loadingView(){
    return Center(
      child: Container(

        width: 128,
        height: 128,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 20),
            ]
        ),
        child: SpinKitDoubleBounce(
          color: Colors.black,
          size: 64,
        ),
      ),
    );
  }
  _fullPage(){

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                    _item.image,
                  ),
                  fit: BoxFit.cover
              )
          ),

        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 1, sigmaX: 1),
          child: Container(
            width: MediaQuery.of(context).size.width/2,
            color: Colors.black.withOpacity(0.6),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: Text(_item.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40, top: 20, right: 40),
                    child: Text(_item.description, style: TextStyle(color: Colors.white, fontSize: 14),),
                  ),

                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,

              ),
              child: Icon(
                MdiIcons.wikipedia,
                color: Color(0xFF555555),
                size: 36,
              ),
            ),
            onTap: (){
              _loadRandomArticle();
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFF333333),
                ),
                width: 260,
                height: 30,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12,),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            )
          ],
        ),
       Align(
         alignment: Alignment.bottomRight,
         child: Container(

           width: MediaQuery.of(context).size.width/2+150,
           height: 200,
           child: _randomViews(),
         ),
       )

      ],
    );
  }
  _randomViews(){
    if(_randomItems==null||_randomItems.length==0){
      return SpinKitWave(color: Colors.black.withOpacity(0.7),);
    }else{
      return ListView.builder(
        itemCount: _randomItems.length,
        scrollDirection: Axis.horizontal,

        itemBuilder: (context, index){
          WikiItem item = _randomItems[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 35),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: index%2==0?Colors.white.withOpacity(0.7):Color(0xBB333333),
              ),
              padding: EdgeInsets.all(15),
              width: 280,
              height: 120,
              child: Center(
                child: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, color: index%2==0?Color(0xFF333333):Colors.white),),
              ),

            ),
          );
        },
      );
    }

  }
  _getPage(){
    switch(_state){
      case PageState.LOADING:
      case PageState.ARTICLE:
        return _loadingView();
      case PageState.MAIN:
        return _fullPage();
    }
    return ;
  }

  _loadRandomArticles() async{
    setState(() {
      _randomItems = new List();
    });
    _randomItems = await WikiService.instance.getRandomArticles();
    setState(() {

    });
  }
  _loadRandomArticle() async{
    setState(() {
      _state = PageState.LOADING;
    });
    _item = await  WikiService.instance.getRandom();
    _loadRandomArticles();
    setState(() {
      _state = PageState.MAIN;
    });
  }
  _performSearch() async{
    List<WikiItem> results = await WikiService.instance.search(_txtQuery.text);
    results.forEach((element) {
      print(element.title);
    });
  }
}
