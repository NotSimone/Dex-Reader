import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:flutter/foundation.dart" show kIsWeb;

String baseURL = "api.mangadex.org";

// Search for manga
Future<List<MangaInfo>> searchManga(String title) async {
  final queryParameters = {"title": title, "order[updatedAt]": "desc", "limit": "100"};

  // Web requests need to go through a CORS proxy
  Uri url = Uri.https(baseURL, "/manga", queryParameters);
  if (kIsWeb) url = Uri.https("cors.simonliveshere.workers.dev", "/proxy", {"url": url.toString()});

  final http.Response response = await http.get(url, headers: {"Access-Control-Allow-Origin": "*"});

  if (response.statusCode == 200) {
    List<dynamic> responseList = json.decode(response.body)["results"];

    List<MangaInfo> fetchedManga = [];
    responseList.forEach((var entry) => fetchedManga.add(new MangaInfo(entry["data"])));
    return fetchedManga;
  } else if (response.statusCode == 204) {
    return [];
  } else {
    throw Exception("Exception in searchManga");
  }
}

class MangaInfo {
  MangaInfo(var response)
      : this.id = response["id"],
        this.title = response["attributes"]["title"]["en"],
        this.description = response["attributes"]["description"]["en"],
        this.lastVolume = response["attributes"]["lastVolume"],
        this.lastChapter = response["attributes"]["lastChapter"],
        this.lastUpdate = response["attributes"]["updatedAt"];

  final String id;
  final String title;
  final String description;
  final String lastVolume;
  final String lastChapter;
  final String lastUpdate;
}

// List of chapters in a manga
Future<Chapters> getChapters(String mangaId, int offset) async {
  final queryParameters = {"order[chapter]": "desc", "order[volume]": "desc", "limit": "10", "locales[]": "en", "offset": (offset * 10).toString()};
  Uri url = Uri.https(baseURL, "/manga/$mangaId/feed", queryParameters);
  // Web requests need to go through a CORS proxy
  if (kIsWeb) url = Uri.https("cors.simonliveshere.workers.dev", "/proxy", {"url": url.toString()});
  final http.Response response = await http.get(url, headers: {"Access-Control-Allow-Origin": "*"});

  if (response.statusCode == 200) {
    var responseData = json.decode(response.body);
    List<dynamic> responseList = responseData["results"];

    List<ChapterInfo> fetchedChapters = [];
    responseList.forEach((var entry) => fetchedChapters.add(new ChapterInfo(entry["data"])));

    final chapterCount = responseData["total"];
    return Chapters(fetchedChapters, chapterCount);
  } else if (response.statusCode == 204) {
    return Chapters([], 0);
  } else {
    throw Exception("Exception in getChapters");
  }
}

class Chapters {
  Chapters(List<ChapterInfo> chapters, int totalChapters)
      : this.chapters = chapters,
        this.totalChapters = totalChapters;

  List<ChapterInfo> chapters;
  final int totalChapters;
}

class ChapterInfo {
  ChapterInfo(var response)
      : this.chapterId = response["id"],
        this.title = response["attributes"]["title"],
        this.volume = response["attributes"]["volume"],
        this.chapter = response["attributes"]["chapter"],
        this.hash = response["attributes"]["hash"],
        this.images = response["attributes"]["data"].cast<String>(),
        this.saverImages = response["attributes"]["dataSaver"].cast<String>(),
        this.updateDate = response["attributes"]["updatedAt"],
        this.count = response["attributes"]["data"].length,
        this.url = "";

  final String chapterId;
  final String title;
  final String volume;
  final String chapter;
  final String hash;
  final List<String> images;
  final List<String> saverImages;
  final String updateDate;
  final int count;
  String url;
}

// Get mangadex@home url
Future<void> getChapterURL(ChapterInfo chapterInfo) async {
  Uri url = Uri.https(baseURL, "/at-home/server/${chapterInfo.chapterId}");
  // Web requests need to go through a CORS proxy
  if (kIsWeb) url = Uri.https("cors.simonliveshere.workers.dev", "/proxy", {"url": url.toString()});
  final http.Response response = await http.get(url, headers: {"Access-Control-Allow-Origin": "*"});

  if (response.statusCode == 200) {
    var responseData = json.decode(response.body);

    // Remove https://
    chapterInfo.url = responseData["baseUrl"];
  } else {
    throw Exception("Exception in getChapterURL");
  }
}

// Get image
NetworkImage getPage(ChapterInfo chapterInfo, bool highQuality, int page) {
  if (page >= chapterInfo.count) throw Exception("Out of bounds in readPages");

  if (chapterInfo.url == "") throw Exception("Uninitialised chapter url endpoint");

  String url = "${chapterInfo.url}/${highQuality ? "data" : "data-saver"}/${chapterInfo.hash}/${highQuality ? chapterInfo.images[page] : chapterInfo.saverImages[page]}";

  // Web requests need to go through a CORS proxy
  if (kIsWeb) url = "https://cors.simonliveshere.workers.dev/proxy/?url=" + url;

  return NetworkImage(url, headers: {"Access-Control-Allow-Origin": "*"});
}
