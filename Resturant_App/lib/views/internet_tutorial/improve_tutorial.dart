import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/generated/assets.dart';
import 'package:resturantapp/views/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImproveTutorial extends StatefulWidget {
  const ImproveTutorial({Key? key}) : super(key: key);

  @override
  State<ImproveTutorial> createState() => _ImproveTutorialState();
}

class _ImproveTutorialState extends State<ImproveTutorial> with SingleTickerProviderStateMixin {
  int currentPage = 0;
  final PageController _pageController = PageController();

  List pageImages = [Assets.imagesAppOnForeground, Assets.imagesCharging, Assets.imagesDedicatedDevice];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: Get.height,
            width: Get.width,
            padding: const EdgeInsets.only(bottom: 105),
            child: PageView.builder(
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              controller: _pageController,
              itemCount: 3,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Image.asset(
                          pageImages[index],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmoothPageIndicator(
                  controller: _pageController, // PageController
                  count: 3,
                  effect: WormEffect(
                    activeDotColor: Colors.blue,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 10.0,
                    dotColor: kInputTextColor.withOpacity(0.50),
                  ), // your preferred effect
                  onDotClicked: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 48,
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.orange,
                    boxShadow: [
                      BoxShadow(
                        color: kSecondaryColor.withOpacity(0.05),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: kSecondaryColor.withOpacity(0.05),
                      highlightColor: kSecondaryColor.withOpacity(0.05),
                      onTap: currentPage == 0
                          ? () {
                              _pageController.animateToPage(1, duration: const Duration(seconds: 1), curve: Curves.ease);
                            }
                          : currentPage == 1
                              ? () {
                                  _pageController.animateToPage(2, duration: const Duration(seconds: 1), curve: Curves.ease);
                                }
                              : () {
                                  log("2");
                                  Get.offAll(() => const BottomNavBar());
                                },
                      borderRadius: BorderRadius.circular(50),
                      child: Center(
                        child: MyText(
                          text: currentPage == 0
                              ? "next".tr.toUpperCase()
                              : currentPage == 1
                                  ? "next".tr.toUpperCase()
                                  : "ok, got it !".tr.toUpperCase(),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          // color: kWhiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
