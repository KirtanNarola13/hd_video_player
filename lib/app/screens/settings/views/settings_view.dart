import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../assets.dart';
import '../../../utils/constant.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Settings"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: ListView(
                children: [
                  _buildListTile(
                    title: "Terms & Conditions",
                    icon: Images.icTermsAndConditions,
                    onTap: controller.openTerms,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  _buildListTile(
                    title: "Share App",
                    icon: Images.icShareApp,
                    onTap: controller.shareApp,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  _buildListTile(
                    title: "Rate this App",
                    icon: Images.icRateApp,
                    onTap: controller.rateUs,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  if (Constants.remoteConfig?.getBool("show_about_mx_player") ??
                      false)
                    _buildListTile(
                      title: "About MX Player",
                      icon: Images.icAboutApp,
                      onTap: controller.openAbout,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                ],
              ),
            ),
          ),
          if (Constants.remoteConfig?.getBool("Ios_Ads_Enable") ?? false)
            if (!controller.isAdLoaded.value) AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String icon,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
    Color color = Colors.black,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      height: screenHeight * 0.07,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.05,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon,
                  width: screenWidth * 0.07,
                  height: screenWidth * 0.07,
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: screenWidth * 0.05,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
