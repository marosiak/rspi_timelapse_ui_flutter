import 'package:flutter/cupertino.dart';

bool isPhone(BuildContext context) {
  return MediaQuery.of(context).size.width < 595;
}

bool isSmallPhone(BuildContext context) {
  return MediaQuery.of(context).size.width < 375;
}