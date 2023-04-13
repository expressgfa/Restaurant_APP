import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/data/local_hive_database.dart';
import 'package:resturantapp/model/site_data_model/site_model.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  SiteInfo siteData = SiteInfo();

  @override
  void initState() {
    // TODO: implement initState
    var siteInfo = LocalHiveDatabase.getSiteData();
    if (siteInfo == null) {
      apiController.getSiteInfo().then((value) {
        setState(() {
          siteData = apiController.siteData;
        });
      });
    } else {
      setState(() {
        siteData = siteInfo;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Profile".tr, haveIcon: true),
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
                  text: "Manager",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 30),
                Wrap(
                  children: [
                    const Icon(
                      Icons.call,
                      color: kGreyColor3,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    MyText(
                      text: siteData.phone,
                      fontSize: 14,
                      color: kGreyColor2,
                      fontWeight: FontWeight.w500,
                      paddingBottom: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: kGreyColor3,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: MyText(
                        text: siteData.pickupAddress,
                        fontSize: 14,
                        color: kGreyColor2,
                        fontWeight: FontWeight.w500,
                        paddingBottom: 5,
                        paddingTop: 7,
                        maxLines: 3,
                        overFlow2: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Divider(),
                const SizedBox(height: 15),
                MyText(
                  text: "Account detailed can ony be modified by web interface".tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
