import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/views/widgets/my_text.dart';

class TimeTextField extends StatelessWidget {
  const TimeTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 90),
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          maxLines: 1,
          controller: apiController.timeController.value,
          validator: (validator) {
            if (apiController.timeController.value.text.trim().isNotEmpty &&
                (int.tryParse(apiController.timeController.value.text.trim()) != null) &&
                int.tryParse(apiController.timeController.value.text.trim()) != 0) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                apiController.isAcceptDisabled.value = false;
              });
              return null;
            } else if (apiController.timeController.value.text.trim().isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                apiController.isAcceptDisabled.value = true;
              });
              return null;
            } else if (int.tryParse(apiController.timeController.value.text.trim()) == null) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                apiController.isAcceptDisabled.value = true;
              });
              return null;
            } else if (int.tryParse(apiController.timeController.value.text.trim()) == 0) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                apiController.isAcceptDisabled.value = true;
              });
              return null;
            } else {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                apiController.isAcceptDisabled.value = true;
              });
              return null;
            }
          },
          onChanged: (value) {},
          keyboardType: TextInputType.number,
          cursorWidth: 1.0,
          textInputAction: TextInputAction.next,
          autofocus: false,
          style: const TextStyle(color: Colors.black54),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.access_time_outlined,
              color: Colors.black,
            ),
            suffixIcon: MyText(
              text: "min".tr,
              fontWeight: FontWeight.w700,
              paddingTop: 14,
            ),

            hintText: "25",
            hintStyle: const TextStyle(
              color: Colors.black54,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.orange, width: 2.0),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.orange, width: 2.0),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.orange, width: 2.0),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
            focusedErrorBorder: InputBorder.none,
            // focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 2.0)),
          ),
        ),
      ),
    );
  }
}
