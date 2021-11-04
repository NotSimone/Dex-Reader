# Dex Reader

## Now that mangadex is working pretty well we dont really need this anymore :)

Basic MangaDex reader built on the new MangaDex v5 api with Flutter.

Note: Both this app and the api it is built on are pretty buggy and are liable to break without warning.

To build: Make sure you have flutter >v2 sdk.
- For Android: Make sure you have the Android SDK installed and run `flutter build apk`.
- For Web: Run `flutter build web --web-renderer html`.
- For Windows: Check your requirements [here](https://flutter.dev/desktop#additional-windows-requirements). Then run `flutter build windows`.

Unfortunately because of CORS this won't work as a web app without some more tweaking :(.

<img src="screenshots/MangaInfo.png" alt="MangaInfo" width="250"/>

<img src="screenshots/Viewer.png" alt="Viewer" width="250"/>
