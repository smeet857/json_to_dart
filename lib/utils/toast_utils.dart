import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils{
  ToastUtils.__();

  static Future<bool?> show({required String msg,
    ToastGravity toastGravity = ToastGravity.SNACKBAR,
    Color? backgroundColor,
    Color? textColor,
    Toast toastLength = Toast.LENGTH_SHORT
  }) => Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: toastGravity,
    backgroundColor: Colors.black,
    textColor: textColor,
  );
}