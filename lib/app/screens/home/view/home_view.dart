import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../assets.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/constant.dart';
import '../../gallery/views/folder_view.dart';
import '../controller/home_controller.dart';
import '../models/home_model.dart';
import '../widgets/home_menu_item.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "MX Player",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                Get.toNamed(Routes.SETTING);
              },
              child: SvgPicture.asset(
                Images.icSetting,
                width: screenWidth * 0.06,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.02),
          Center(
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              height: screenWidth * 0.3,
              width: screenWidth * 0.3,
              child: Hero(
                tag: "logo",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(Images.appIcon, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Container(
            alignment: Alignment.center,
            height: screenHeight * 0.13,
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenWidth * 0.015),
            decoration: BoxDecoration(
              color: AppColors.homeAppNameBoxColor,
              border: Border.all(color: Colors.black.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Image(image: AssetImage(Images.homeAppNameBG)),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "MX Player",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "Any Video or audio format can be played by all format media player",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: GridView.builder(
                itemCount: menuItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 3 : 2,
                  childAspectRatio: screenWidth / screenHeight * 0.5,
                  mainAxisExtent: screenHeight * 0.15,
                  crossAxisSpacing: screenWidth * 0.02,
                  mainAxisSpacing: screenHeight * 0.01,
                ),
                itemBuilder: (context, index) {
                  return HomeMenuItem(
                    title: menuItems[index]['title'],
                    bgImage: menuItems[index]['bgImage'],
                    icImage: menuItems[index]['icon'],
                    onTap: () async {
                      if (index == 0 || index == 1) {
                        checkGalleryPermission(index);
                      } else if (index == 2) {
                        Get.toNamed(Routes.PLAYLIST);
                      }
                    },
                  );
                },
              ),
            ),
          ),
          if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
            if (!controller.isAdLoaded.value) AdBannerWidget(),
        ],
      ),
    );
  }
}

bool isRequestingPermission = false;

Future<void> checkGalleryPermission(int index) async {
  if (isRequestingPermission) {
    print("⚠️ Permission request is already in progress.");
    return;
  }

  isRequestingPermission = true;

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isGrantedBefore = prefs.getBool("gallery_permission");

    // If permission is already granted before, directly open gallery
    if (isGrantedBefore == true) {
      print("✅ Permission already granted, opening gallery...");
      Get.to(() => FolderListScreen());
      isRequestingPermission = false;
      return;
    }

    // Show bottom sheet before asking permission
    bool userAccepted = await showPermissionBottomSheet();

    if (!userAccepted) {
      print("🚫 User declined permission request.");
      isRequestingPermission = false;
      return;
    }

    var permission = Platform.isIOS ? Permission.photos : Permission.storage;
    var status = await permission.request();

    if (status.isGranted) {
      print("✅ Permission granted, opening gallery...");

      // Store permission grant in SharedPreferences
      await prefs.setBool("gallery_permission", true);

      Get.to(() => FolderListScreen());
    } else if (status.isPermanentlyDenied) {
      print("🚨 Permanently denied, open settings...");
      // openAppSettings();
    } else {
      print("❌ Permission denied.");
    }
  } catch (e) {
    print("❗ Error while requesting permission: $e");
  } finally {
    isRequestingPermission = false;
  }
}

Future<bool> showPermissionBottomSheet() async {
  bool userAccepted = false;

  await Get.bottomSheet(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(Images.animVideoPermission, height: 120),
          const SizedBox(height: 15),
          const Text(
            "Allow Media Access",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "This app needs access to your media library to display and organize your media files.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () {
              userAccepted = true;
              Get.back();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Continue", // ✅ Updated button text
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    isDismissible: false, // ✅ Prevents dismissing without making a choice
  );

  return userAccepted;
}
