import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/generated/assets.dart';
import 'package:resturantapp/views/widgets/my_button.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class BlueToothSearching extends StatelessWidget {
  const BlueToothSearching({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Bluetooth", haveIcon: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 25),
                Image.asset(
                  Assets.imagesBlueToothImage,
                  width: Get.width,
                ),
                SizedBox(height: Get.height * 0.13),
                MyButton(
                  onTap: () {},
                  title: "START SEARCH",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
