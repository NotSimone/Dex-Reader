import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'API.dart';

class ViewerPage extends StatefulWidget {
  const ViewerPage(chapterInfo) : this.chapterInfo = chapterInfo;

  final ChapterInfo chapterInfo;

  @override
  _ViewerPageState createState() => _ViewerPageState(chapterInfo);
}

class _ViewerPageState extends State<ViewerPage> {
  _ViewerPageState(chapterInfo)
      : this.chapterInfo = chapterInfo,
        this.images = List.filled(chapterInfo.count, null),
        this.loaded = new Set(),
        this.currentPage = 0;

  final ChapterInfo chapterInfo;
  int currentPage;

  // Indicates we have finished loading URL
  Future<void> readyToLoad;
  // Images we have and those we requested a load for
  List<NetworkImage> images;
  Set<int> loaded;

  // Load the specified page
  void _loadPage(int page) {
    if (!this.loaded.contains(page) && page < this.chapterInfo.count) {
      this.images[page] = getPage(this.chapterInfo, true, page);
      precacheImage(this.images[page], context);
      this.loaded.add(page);
    }
  }

  @override
  void initState() {
    super.initState();
    this.readyToLoad = getChapterURL(this.chapterInfo).then((_) {
      this._loadPage(0);
      this._loadPage(1);
      this._loadPage(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("${this.chapterInfo.title}"), actions: [Center(child: Text("(${this.currentPage} / ${this.chapterInfo.count})", textAlign: TextAlign.center))]),
        body: FutureBuilder(
            future: this.readyToLoad,
            builder: (BuildContext context, AsyncSnapshot<void> results) {
              // While we are waiting, show loading circle
              if (results.connectionState != ConnectionState.done) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator()]));
              } else {
                return PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    if (this.loaded.contains(index)) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: this.images[index],
                        initialScale: PhotoViewComputedScale.contained,
                      );
                    } else {
                      throw Exception("Exception in ViewerPage: bad index");
                    }
                  },
                  itemCount: this.chapterInfo.count,
                  loadingBuilder: (context, event) => Container(
                      decoration: new BoxDecoration(color: Colors.black),
                      child: Center(
                        child: Container(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                          ),
                        ),
                      )),
                  onPageChanged: (index) {
                    setState(() => this.currentPage = index);
                    this._loadPage(index);
                    this._loadPage(index + 1);
                    this._loadPage(index + 2);
                  },
                );
              }
            }));
  }
}
