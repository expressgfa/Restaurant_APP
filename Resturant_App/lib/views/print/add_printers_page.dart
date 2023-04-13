import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/views/print/bluetooth_searching.dart';
import 'package:resturantapp/views/print/network_searching.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class AddPrintersPage extends StatelessWidget {
  const AddPrintersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Add printers(s)", haveIcon: true),
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
                  text: "CHOOSE HOW THIS DEVICE WILL CONNECT TO PRINTER",
                  fontSize: 14,
                  color: kGreyColor,
                  fontWeight: FontWeight.w400,
                ),
                const Divider(),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Get.to(() => NetworkSearching());
                  },
                  child: MyText(
                    text: "Network Cable or WiFi",
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    Get.to(() => BlueToothSearching());
                  },
                  child: MyText(
                    text: "Bluetooth",
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
