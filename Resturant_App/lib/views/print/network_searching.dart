import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/generated/assets.dart';
import 'package:resturantapp/views/widgets/my_button.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class NetworkSearching extends StatelessWidget {
  const NetworkSearching({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Network Cable or WiFi", haveIcon: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 25),
                Image.asset(
                  Assets.imagesNetworkImage,
                ),
                SizedBox(height: Get.height * 0.24),
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
