import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "languages".tr, haveIcon: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: languageController.languageList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  horizontalTitleGap: 10,
                  onTap: () {
                    languageController.changedLanguage(languageController.languageList[index], index);
                  },
                  leading: Obx(() {
                    return Radio(
                      activeColor: Colors.green,
                      value: languageController.languageList[index],
                      groupValue: languageController.selectedLanguage.value,
                      onChanged: (value) {
                        languageController.changedLanguage(value.toString(), index);
                        log('${languageController.selectedLanguage.value} and value is: $value');
                      },
                    );
                  }),
                  title: MyText(
                    text: languageController.languageList[index],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
