import 'package:flutter/material.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class CustomTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: UIColor.gold,
      scaffoldBackgroundColor: UIColor.bg,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: UIColor.bg,
        unselectedIconTheme: IconThemeData(color: UIColor.white),
        selectedItemColor: UIColor.gold,
        unselectedItemColor: UIColor.kPrimaryTextColor,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: UIColor.bg,
      ),
      useMaterial3: true,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: UIColor.bg,
        
        dayBackgroundColor: WidgetStatePropertyAll(UIColor.black),
        todayBorder: BorderSide.none,
        todayBackgroundColor: WidgetStatePropertyAll(Colors.transparent),
        
       
        dayStyle: TextStyle(color: UIColor.gold),
        dayForegroundColor: WidgetStatePropertyAll(UIColor.gold),
        todayForegroundColor: WidgetStatePropertyAll(UIColor.gold),

        cancelButtonStyle: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStatePropertyAll(UIColor.gold),
        ),
        headerBackgroundColor: UIColor.black, // Header background color
        headerForegroundColor:
            UIColor.gold, // Header text color (e.g., "Select date")
        rangePickerHeaderForegroundColor: UIColor.gold,
        rangePickerBackgroundColor: UIColor.gold,
        dividerColor: UIColor.gold,
        yearStyle: TextStyle(
          color: UIColor.white,
        ),
        yearBackgroundColor:
            WidgetStatePropertyAll(UIColor.black), // Year dialog background
        yearOverlayColor: WidgetStatePropertyAll(UIColor.gold),
        yearForegroundColor:
            WidgetStatePropertyAll(UIColor.gold), // Text color for year list
        weekdayStyle: TextStyle(
          color: UIColor
              .gold, // Change this to the color you want for weekdays (M, T, W, etc.)
        ),
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
