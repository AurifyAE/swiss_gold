import 'package:flutter/material.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';

void showOrderStatusSnackBar({
  required BuildContext context,
  required bool isSuccess,
  required String message,
  int? duration,
}) {
  if (isSuccess) {
    customSnackBarSuccess(
      context: context,
      title: message,
      duration: duration ?? 3,
    );
  } else {
    customSnackBar(
      context: context,
      title: message,
      bgColor: Colors.red,
      titleColor: Colors.white,
      duration: duration ?? 3,
    );
  }
}