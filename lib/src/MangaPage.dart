import 'package:flutter/material.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';

import 'API.dart';
import 'ViewerPage.dart';

class MangaPage extends StatefulWidget {
  MangaPage(MangaInfo mangaInfo) : this.mangaInfo = mangaInfo;

  final MangaInfo mangaInfo;

  @override
  _MangaPageState createState() => _MangaPageState(mangaInfo);
}

class _MangaPageState extends State<MangaPage> {
  _MangaPageState(MangaInfo mangaInfo)
      : this.mangaInfo = mangaInfo,
        this.chapters = [],
        this.totalChapters = 1,
        this.currIndex = 0,
        this._loadingMore = false;

  final MangaInfo mangaInfo;

  List<ChapterInfo> chapters;
  int totalChapters;
  int currIndex;
  bool _loadingMore;
  Future<void> _initLoad;

  Future<void> _getMoreChapters() async {
    Chapters chapterInfo = await getChapters(this.mangaInfo.id, this.currIndex);
    this.totalChapters = chapterInfo.totalChapters;
    this.chapters.addAll(chapterInfo.chapters);
    this.currIndex++;
  }

  @override
  void initState() {
    super.initState();
    this._initLoad = _getMoreChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(this.mangaInfo.title)),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Basic descriptors
              Padding(padding: EdgeInsets.fromLTRB(25, 40, 25, 0), child: Text("Description", style: Theme.of(context).textTheme.headline6)),
              Padding(padding: EdgeInsets.fromLTRB(25, 25, 25, 25), child: Text(mangaInfo.description, style: Theme.of(context).textTheme.bodyText2)),
              Divider(),
              Text("Last Volume: ${this.mangaInfo.lastVolume}", style: Theme.of(context).textTheme.bodyText1),
              Text("Last Chapter: ${this.mangaInfo.lastChapter}", style: Theme.of(context).textTheme.bodyText1),
              Text("Last Update: ${this.mangaInfo.lastUpdate}", style: Theme.of(context).textTheme.bodyText1),
              Divider(),
              Flexible(
                  child: FutureBuilder(
                      future: _initLoad,
                      builder: (BuildContext context, AsyncSnapshot<void> results) {
                        // Wait until first set of chapters is loaded
                        if (results.connectionState != ConnectionState.done) {
                          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator()]));
                        } else {
                          // As we scroll lower, load more chapters
                          return IncrementallyLoadingListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              hasMore: () => this.chapters.length < this.totalChapters,
                              itemCount: () => this.chapters.length,
                              loadMore: () => _getMoreChapters(),
                              onLoadMore: () => setState(() => _loadingMore = true),
                              onLoadMoreFinished: () => setState(() => _loadingMore = false),
                              loadMoreOffsetFromBottom: 2,
                              itemBuilder: (context, index) {
                                final chapter = this.chapters[index];
                                return ListTile(leading: Text("V${chapter.volume} C${chapter.chapter}"), title: Text("${chapter.title}"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewerPage(chapter))));
                              });
                        }
                      })),
              // Loading indicator
              if (_loadingMore) CircularProgressIndicator()
            ],
          ),
        ));
  }
}
