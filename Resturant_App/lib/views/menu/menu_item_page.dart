import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/views/menu/menu_detail_page.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class MenuItemPage extends StatefulWidget {
  const MenuItemPage({Key? key}) : super(key: key);

  @override
  State<MenuItemPage> createState() => _MenuItemPageState();
}

class _MenuItemPageState extends State<MenuItemPage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      apiController.getMenuListData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Menu items".tr, haveIcon: true),
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
                future: apiController.getMenuListData(),
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
                  return Expanded(
                    child: ListView.builder(
                      itemCount: apiController.menuList.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => MenuDetailPage(
                                menuName: apiController.menuList[index].menuName ?? "",
                                menuId: apiController.menuList[index].menuId ?? ""));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: "${apiController.menuList[index].menuName}",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              const SizedBox(height: 2),
                              const Divider(),
                              const SizedBox(height: 8),
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
// Column(
//   crossAxisAlignment: CrossAxisAlignment.stretch,
//   children: [
//     Expanded(
//       child: ListView(
//         shrinkWrap: true,
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         physics: const BouncingScrollPhysics(),
//         children: [
//
//           FutureBuilder(
//               future: apiController.getMenuListData(),
//               builder: (BuildContext context, snapshot) {
//                 // if (!snapshot.hasData) {
//                 //   return Container(
//                 //     margin: const EdgeInsets.all(10),
//                 //     child: ListView.builder(
//                 //         itemCount: 15,
//                 //         itemBuilder: (BuildContext context, int index) {
//                 //           return Padding(
//                 //             padding: const EdgeInsets.all(3.0),
//                 //             child: FadeShimmer(
//                 //               height: 70,
//                 //               width: MediaQuery.of(context).size.width,
//                 //               radius: 4,
//                 //               highlightColor: Colors.green,
//                 //               baseColor: Colors.greenAccent,
//                 //               // highlightColor: const Color(0xffF9F9FB),
//                 //               // baseColor: const Color(0xffE6E8EB),
//                 //             ),
//                 //           );
//                 //         }),
//                 //   );
//                 // }
//                 return Obx(() {
//                   return Expanded(
//                     child: ListView.builder(
//                       itemCount: apiController.itemList.length,
//                       physics: const BouncingScrollPhysics(),
//                       itemBuilder: (BuildContext context, int index) {
//                         return GestureDetector(
//                           onTap: () {},
//                           child: Column(
//                             children: [
//                               // ListTile(
//                               //   leading: const CircleAvatar(
//                               //     backgroundColor: Colors.grey,
//                               //     child: Icon(
//                               //       Icons.shopping_bag,
//                               //       color: Colors.black54,
//                               //     ),
//                               //   ),
//                               //   title: MyText(
//                               //     text: apiController.itemList[index].itemName,
//                               //     fontSize: 14,
//                               //     fontWeight: FontWeight.w400,
//                               //   ),
//                               //   subtitle: MyText(
//                               //     text: "Missed",
//                               //     fontSize: 14,
//                               //     fontWeight: FontWeight.w400,
//                               //   ),
//                               //   trailing: MyText(
//                               //     text: "\$ 12.4",
//                               //     fontSize: 14,
//                               //     fontWeight: FontWeight.w400,
//                               //   ),
//                               // ),
//                               // const Divider(),
//
//                               const Divider(),
//                               MyText(
//                                 text: "Chines Flavour",
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 });
//               }),
//
//           //
//           // const SizedBox(height: 20),
//           // const Divider(),
//           // MyText(
//           //   text: "Chines Flavour",
//           //   fontSize: 14,
//           //   fontWeight: FontWeight.w400,
//           // ),
//           // const SizedBox(height: 10),
//           // const Divider(),
//           // MyText(
//           //   text: "Beverages",
//           //   fontSize: 14,
//           //   fontWeight: FontWeight.w400,
//           // ),
//           // const SizedBox(height: 10),
//           // const Divider(),
//           // MyText(
//           //   text: "Tea",
//           //   fontSize: 14,
//           //   fontWeight: FontWeight.w400,
//           // ),
//           // const SizedBox(height: 10),
//           // const Divider(),
//         ],
//       ),
//     ),
//   ],
// ),
