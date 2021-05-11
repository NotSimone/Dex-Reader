import 'package:flutter/material.dart';
import 'SearchPage.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          //   icon: const Icon(Icons.menu),
          //   onPressed: () {},
          // ),
          title: Text("Main"),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
              ),
              onPressed: () {
                showSearch(context: context, delegate: SearchPage());
              },
            ),
            // PopupMenuButton<Text>(
            //   itemBuilder: (context) {
            //     return [
            //       PopupMenuItem(
            //         child: Text(
            //           "First popup item",
            //         ),
            //       ),
            //       PopupMenuItem(
            //         child: Text(
            //           "Second popup item",
            //         ),
            //       ),
            //       PopupMenuItem(
            //         child: Text(
            //           "Third popup item",
            //         ),
            //       ),
            //     ];
            //   },
            // )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Search for a manga on the top right to begin", style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center)],
          ),
        ));
  }
}
