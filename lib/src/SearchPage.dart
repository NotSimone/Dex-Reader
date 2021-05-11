import 'package:flutter/material.dart';
import 'API.dart';
import 'MangaPage.dart';

class SearchPage extends SearchDelegate {
  List<String> recentList = [];

  @override
  // Widgets on the right side of search
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[IconButton(icon: Icon(Icons.close), onPressed: () => query = "")];
  }

  @override
  // Widgets on the left side of search
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  @override
  // Search results
  Widget buildResults(BuildContext context) {
    if (query == "") return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Enter a title to search")]));

    if (!recentList.contains(query)) recentList.add(query);

    // Perform search
    Future<List<MangaInfo>> searchResults = searchManga(query);

    return FutureBuilder(
        future: searchResults,
        builder: (BuildContext context, AsyncSnapshot<List<MangaInfo>> results) {
          // While we are waiting, show loading circle
          if (results.connectionState != ConnectionState.done) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator()]));
          } else {
            if (results.data.length == 0) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text("No results :(")]));
            return ListView.builder(
                itemCount: results.data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(results.data[index].title),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MangaPage(results.data[index]))),
                  );
                });
          }
        });
  }

  @override
  // History list
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
        itemCount: recentList.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text(recentList[index]),
              leading: Icon(Icons.history),
              onTap: () {
                query = recentList[index];
                showResults(context);
              });
        });
  }
}
