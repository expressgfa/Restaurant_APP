import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  String? label, hint;
  bool? isObSecure, haveLabel, isReadOnly, havePrefix, haveSuffix, isExpands, autofocus;
  ValueChanged<String>? onChanged;
  Function()? onEditingComplete;
  Function(String)? onFieldSubmitted;
  FormFieldValidator<String>? validator;
  AutovalidateMode? autoValidateMode;
  TextEditingController? controller;
  TextInputType? keyboardType;
  double? marginBottom;
  int? maxLines;
  Widget? suffixIcon;
  Widget? prefixIcon;
  List<String> autoFillHints;
  TextInputAction? textInputAction;
  final FocusNode? focusNode;

  String? initialValue;
  MyTextField({
    Key? key,
    this.label,
    this.hint,
    this.validator,
    this.isObSecure = false,
    this.haveLabel = true,
    this.isReadOnly = false,
    this.haveSuffix = false,
    this.havePrefix = false,
    this.isExpands = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.marginBottom = 15.0,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.initialValue,
    this.autoFillHints = const [],
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.textInputAction,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        autovalidateMode: autoValidateMode,
        textAlignVertical: TextAlignVertical.center,
        readOnly: isReadOnly!,
        focusNode: focusNode,
        initialValue: initialValue,
        maxLines: maxLines!,
        obscureText: isObSecure!,
        expands: isExpands ?? false,
        obscuringCharacter: '•',
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
        keyboardType: keyboardType,
        cursorWidth: 1.0,
        autofillHints: autoFillHints,
        textInputAction: textInputAction ?? TextInputAction.next,
        autofocus: autofocus ?? false,
        style: const TextStyle(color: Colors.black54),
        decoration: InputDecoration(
          prefixIcon: prefixIcon ?? const SizedBox(),
          suffixIcon: haveSuffix!
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    suffixIcon!,
                  ],
                )
              : const SizedBox(),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black54,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: maxLines! > 1 ? 10 : 20),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: InputBorder.none,
          // focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 2.0)),
        ),
      ),
    );
  }
}
