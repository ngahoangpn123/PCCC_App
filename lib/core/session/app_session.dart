import 'package:flutter/foundation.dart';

/// Lưu cơ sở đang được chọn. Màn hình nào cần biết thì lắng nghe thay đổi.
///
/// TODO (khi có database): mọi truy vấn lọc theo [currentFacilityId]
/// để dữ liệu, thông báo, nhiệm vụ đổi theo cơ sở đang chọn.
class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  String currentFacilityId = 'f1';
  String currentFacilityName = 'Trung tâm Thương mại Hòa Bình';

  void switchFacility(String id, String name) {
    currentFacilityId = id;
    currentFacilityName = name;
    notifyListeners();
  }
}
