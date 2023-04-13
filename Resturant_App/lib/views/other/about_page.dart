import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "About", haveIcon: true),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 25),
                const SizedBox(height: 30),
                const Divider(),
                MyText(
                  text: "A Terms and Conditions agreement outlines the rules that your website or mobile app users must follow."
                          " They usually cover topics such restricted behavior, payment terms, acceptable use,"
                          " and more that we cover below.Read on to learn more about terms and conditions agreements, "
                          "why you should have one, and how to implement one using our sample terms and conditions template."
                      .tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                const Divider(),
                const SizedBox(height: 15),
                MyText(
                  text: "Don't be shy. Let us know how we're doing.".tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    SizedBox(
                      width: 165,
                      child: GestureDetector(
                        onTap: () {
                          print("Something pressed");
                          launchUrl(
                            Uri.parse(
                              'mailto:expressgfa@gmail.com?subject=Feedback (Restaurant App) &body='
                              'Hi Support team \n  Message :\n',
                            ),
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 20,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: MyText(
                              text: "SEND FEEDBACK".tr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
