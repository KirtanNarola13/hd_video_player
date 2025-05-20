import 'package:get/get.dart';
import 'package:hd_video_player/app/screens/gallery/bindings/gallery_binding.dart';
import 'package:hd_video_player/app/screens/gallery/views/allVideoView.dart';
import 'package:hd_video_player/app/screens/music/bindings/music_binding.dart';
import 'package:hd_video_player/app/screens/music/views/music_list_view.dart';
import 'package:hd_video_player/app/screens/playlist/bindings/playlist_binding.dart';
import 'package:hd_video_player/app/screens/playlist/views/playlist_screen.dart';
import 'package:hd_video_player/app/screens/settings/bindings/settings_binding.dart';
import 'package:hd_video_player/app/screens/settings/views/settings_view.dart';
import 'package:hd_video_player/app/screens/webview/bindings/webview_binding.dart';
import 'package:hd_video_player/app/screens/webview/views/webview_view.dart';

import '../screens/home/bindings/home_binding.dart';
import '../screens/home/view/home_view.dart';
import '../screens/splash_screen/bindings/splash_binding.dart';
import '../screens/splash_screen/view/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.ALLVIDEOS,
      page: () => AllVideosView(),
      binding: GalleryBinding(),
    ),
    GetPage(
      name: Routes.MUSIC,
      page: () => MusicView(),
      binding: MusicBinding(),
    ),
    GetPage(
      name: Routes.PLAYLIST,
      page: () => PlaylistScreen(),
      binding: PlaylistBinding(),
    ),
    GetPage(
      name: Routes.SETTING,
      page: () => SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.WEBVIEW,
      page: () => WebViewView(),
      binding: WebViewBinding(),
    ),
    // GetPage(
    //   name: Routes.GALLERYVIDEOS,
    //   page: () => GalleryVideoView(),
    //   binding: GalleryBinding(),
    // ),
  ];
}
