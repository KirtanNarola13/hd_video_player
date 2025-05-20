import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../assets.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              height: Get.width * 0.5,
              width: Get.width * 0.5,

              // color: Colors.red,
              child: Hero(
                tag: "logo",
                transitionOnUserGestures: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Smooth transition
                  child: Image.asset(
                    Images.appIcon,
                    fit: BoxFit.cover,
                    width: 150,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: Get.width * 0.6, // Adjust width based on screen
              child: FittedBox(
                fit:
                    BoxFit
                        .scaleDown, // Ensures text shrinks but does not overflow
                child: Text(
                  "HD Video Player",
                  style: TextStyle(
                    fontSize: 20, // Base font size, will scale down if needed
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
