import 'dart:developer' as dev;
import 'dart:math';

double calculatePurityPower(dynamic purity) {
    String purityStr = purity.toString().replaceAll(RegExp(r'\.0$'), '');

    if (purityStr.contains('.')) {
      purityStr = purityStr.replaceAll(RegExp(r'0+$'), '');

      purityStr = purityStr.replaceAll(RegExp(r'\.$'), '');
    }

    int digitCount = purityStr.replaceAll('.', '').length;
    double powerOfTen = pow(10, digitCount).toDouble();
    double result = double.parse(purityStr) / powerOfTen;

    if (purityStr == '9999' || purityStr == '999.9') {
      return 0.9999;
    } else if (purityStr == '999' || purityStr == '99.9') {
      return 0.999;
    } else if (purityStr == '916' || purityStr == '91.6') {
      return 0.916;
    } else if (purityStr == '750' || purityStr == '75.0') {
      return 0.750;
    } else if (purityStr == '585' || purityStr == '58.5') {
      return 0.585;
    } else if (purityStr == '375' || purityStr == '37.5') {
      return 0.375;
    }

    dev.log(
        '🧮 Standardized purity calculation: purity=$purity → cleaned=$purityStr, digits=$digitCount, power=$powerOfTen, result=$result');
    return result;
  }