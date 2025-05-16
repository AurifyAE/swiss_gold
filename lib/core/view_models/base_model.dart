import 'package:flutter/material.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';

class BaseModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  setState(ViewState state) {
    _state = state;
    notifyListeners();
  }
}
