import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import '../utils/test_helpers.dart';

void main() {
  setUp(() {
    setupMockWebViewPlatform();
  });

  group('Responsive Layout Tests', () {
    /// Helper function to verify LoadingPage elements are displayed correctly
    Future<void> verifyLoadingPageElements(WidgetTester tester, Size deviceSize, String sizeName) async {
      // Arrange - Build widget with given size
      await tester.pumpWidget(
        responsiveTestableWidget(
          const LoadingPage(navigateAfterDelay: false),
          width: deviceSize.width,
          height: deviceSize.height,
        ),
      );

      // Assert - Check essential UI elements
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Verify centering
      expect(find.byType(Center), findsOneWidget);
    }

    // Define device sizes with names
    final deviceSizes = {
      'Mobile Small': DeviceSizes.mobileSmall,
      'Mobile Medium': DeviceSizes.mobileMedium,
      'Mobile Large': DeviceSizes.mobileLarge,
      'Tablet': DeviceSizes.tablet,
      'Desktop': DeviceSizes.desktop,
    };

    // Test on multiple device sizes
    deviceSizes.forEach((name, size) {
      testWidgets('LoadingPage renders correctly on $name', (WidgetTester tester) async {
        await verifyLoadingPageElements(tester, size, name);
      });
    });
  });
}
