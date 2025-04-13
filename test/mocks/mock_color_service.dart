import 'package:lifebliss_app/domain/services/color_service.dart';

/// Mock implementation of ColorService for testing
class MockColorService extends ColorService {
  bool getRandomColorHexCalled = false;

  @override
  String getRandomColorHex({int maxAttempts = 3}) {
    getRandomColorHexCalled = true;
    return '#FF0000'; // Always return red for testing
  }
}
