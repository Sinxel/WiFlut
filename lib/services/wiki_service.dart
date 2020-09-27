import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:wiflut/models/wiki_item.dart';

class WikiService{
  WikiService._instantiate();

  static final WikiService instance = WikiService._instantiate();
  String baseUrl = "https://en.wikipedia.org/w/api.php";

  Future<List<WikiItem>> search(String query) async{
    Dio dio = new Dio();
    var params = {
      "action" : "query",
      "list" : "search",
      "format" : "json",
      "srsearch" : query
    };
    try{
      var response = await dio.get(baseUrl, queryParameters: params);
      List<dynamic> results = response.data["query"]["search"];
      List<WikiItem> items = new List();
      results.forEach((element) {
        WikiItem item = new WikiItem();
        item.title = element["title"];
        item.description = element["description"];
        items.add(item);
      });
      return items;
    }catch(e){
      print(e);
      return null;
    }


  }


  Future<List<WikiItem>> getRandomArticles({int limit=10}) async{
    List<WikiItem> items = new List();
    Dio dio = new Dio();
    var params = {
      "action": "query",
      "format": "json",
      "list": "random",
      "rnnamespace" : "0",
      "prop":"pageimages|extracts",
      "exintro":"true",
      "explaintext":"true",
      "exsectionformat":"plain",
      "rnlimit": limit
    };
    try{
      var response = await dio.get(baseUrl, queryParameters: params);
      List<dynamic> results = response.data["query"]["random"];
      results.forEach((element) {
        WikiItem item = new WikiItem();
        item.title = element["title"];
        items.add(item);
      });
      return items;

    }catch(e){
      print(e);
      return null;
    }
  }
  Future<WikiItem> getRandom() async{
    WikiItem item;
    Dio dio = new Dio();
    var params = {
      "action": "query",
      "format": "json",
      "list": "random",
      "rnnamespace" : "0",
      "rnlimit": "20"
    };
    try{
      var response = await dio.get(baseUrl, queryParameters: params);
      List<dynamic> results = response.data["query"]['random'];
      for(int i=0; i<results.length; i++){

        Map<String, dynamic> result = results[i];
        item = await getShortArticle(result['title']);
        if(item!=null) return item;
      }
      return await getRandom();

    }catch(e){
      print(e);
      return null;
    }
  }

  getShortArticle(String title) async{
    Dio dio = new Dio();
    var params = {
      "action" : "query",
      "titles" : title,
      "format" : "json",
      "prop":"pageimages|extracts",
      "exintro":"true",
      "piprop" : "original",
      "explaintext":"true",
      "exsectionformat":"plain"
    };
    var response = await dio.get(baseUrl, queryParameters: params);
    Map<String, dynamic> pages = response.data["query"]["pages"];
    String key = pages.keys.first;
    Map<String, dynamic> page = pages[key];
    if(page.keys.contains("original")){
      String imageUrl = page["original"]["source"];
      if(imageUrl.toLowerCase().endsWith("svg")) return null;
      WikiItem item = new WikiItem();
      item.title = page["title"];
      item.description = page["extract"];
      item.image = page["original"]["source"];
      return item;
    }else{
      return null;
    }

  }




}