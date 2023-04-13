import 'dart:developer';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class MenuDetailPage extends StatefulWidget {
  final String menuId;
  final String menuName;
  const MenuDetailPage({Key? key, required this.menuId, required this.menuName}) : super(key: key);

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  RxString selectedOption = "Available".obs;
  List<String> optionList = [
    "Available",
    "Until tomorrow",
    "Until..",
    "Undetermined",
  ];

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      apiController.getItemListData(widget.menuId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: widget.menuName, haveIcon: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            MyText(
              text: "Categories".tr,
              fontSize: 12,
              color: kGreyColor,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(height: 25),
            FutureBuilder(
                future: apiController.getItemListData(widget.menuId),
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: 15,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: FadeShimmer(
                                height: 70,
                                width: MediaQuery.of(context).size.width,
                                radius: 4,
                                highlightColor: const Color(0xffF9F9FB),
                                baseColor: const Color(0xffE6E8EB),
                              ),
                            );
                          }),
                    );
                  }
                  log("in else means the data came in ${snapshot.data}");
                  return Expanded(
                    child: ListView.builder(
                      itemCount: apiController.itemList.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          //+COMMENTED
                          //+COMMENTED
                          //+COMMENTED
                          //+COMMENTED
                          // onTap: () {
                          //   log("on tap");
                          //   Get.bottomSheet(
                          //     StatefulBuilder(
                          //       builder: (context, setState) {
                          //         return Container(
                          //           padding: EdgeInsets.symmetric(horizontal: 10),
                          //           width: double.maxFinite,
                          //           decoration: const BoxDecoration(
                          //             color: Colors.white,
                          //             borderRadius: BorderRadius.only(
                          //               topLeft: Radius.circular(10),
                          //               topRight: Radius.circular(10),
                          //             ),
                          //           ),
                          //           child: Padding(
                          //             padding: const EdgeInsets.symmetric(),
                          //             child: Column(
                          //               crossAxisAlignment: CrossAxisAlignment.start,
                          //               mainAxisSize: MainAxisSize.min,
                          //               children: [
                          //                 const SizedBox(height: 30),
                          //                 MyText(
                          //                   text: "Out of stock".tr,
                          //                   fontSize: 12,
                          //                   fontWeight: FontWeight.w500,
                          //                   color: kGreyColor,
                          //                   paddingLeft: 14,
                          //                 ),
                          //                 const SizedBox(height: 15),
                          //                 SizedBox(
                          //                   width: (MediaQuery.of(context).size.width / 2) - 20,
                          //                   child: Wrap(
                          //                     crossAxisAlignment: WrapCrossAlignment.center,
                          //                     alignment: WrapAlignment.center,
                          //                     children: List.generate(4, (index) {
                          //                       return Container(
                          //                         color: Colors.white,
                          //                         width: (MediaQuery.of(context).size.width / 2) - 20,
                          //                         child: Row(
                          //                           mainAxisAlignment: MainAxisAlignment.start,
                          //                           children: [
                          //                             Obx(() {
                          //                               return Radio(
                          //                                 activeColor: Colors.green,
                          //                                 value: optionList[index],
                          //                                 groupValue: selectedOption.value,
                          //                                 onChanged: (value) {
                          //                                   selectedOption.value = value ?? "";
                          //                                 },
                          //                               );
                          //                             }),
                          //                             MyText(
                          //                               overFlow: TextOverflow.ellipsis,
                          //                               text: optionList[index],
                          //                               fontSize: 14,
                          //                               fontWeight: FontWeight.w400,
                          //                             ),
                          //                           ],
                          //                         ),
                          //                       );
                          //                     }),
                          //                   ),
                          //                 ),
                          //                 const SizedBox(height: 30),
                          //               ],
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //     ),
                          //   );
                          // },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: "${apiController.itemList[index].itemName}",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              const SizedBox(height: 5),
                              MyText(
                                text: "${apiController.itemList[index].status}",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              const Divider(),
                              const SizedBox(height: 12),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
