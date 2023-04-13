import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/views/print/add_printers_page.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class AutoPrintOrders extends StatelessWidget {
  const AutoPrintOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Auto-Print orders".tr, haveIcon: true),
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
                  text: "SELECT".tr,
                  fontSize: 18,
                  color: kGreyColor,
                  fontWeight: FontWeight.w400,
                ),
                const Divider(),
                const SizedBox(height: 10),
                MyText(
                  text: "Here printers name",
                  fontSize: 14,
                  color: kGreyColor,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 10),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    Get.to(() => AddPrintersPage());
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_forward),
                      const SizedBox(width: 5),
                      MyText(
                        text: "ADD PRINTERS(S)",
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
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
