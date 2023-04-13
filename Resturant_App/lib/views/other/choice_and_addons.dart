import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class ChoiceAndAddonsPage extends StatelessWidget {
  const ChoiceAndAddonsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Choices & addons".tr, haveIcon: true),
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
                MyText(
                  text: "Groups".tr,
                  fontSize: 12,
                  color: kGreyColor,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 20),
                const Divider(),
                MyText(
                  text: "Crust",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 10),
                const Divider(),
                MyText(
                  text: "Extra Toppings (Small) ",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 10),
                const Divider(),
                MyText(
                  text: "Extra Toppings (Large)",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 10),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
