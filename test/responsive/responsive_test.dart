import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifebliss_app/presentation/pages/loading_page.dart';
import '../utils/test_helpers.dart';
import '../utils/test_mocks.dart';

void main() {
  setUp(() {
    setupMockWebViewPlatform();
  });
  
  group('Responsive Layout Tests', () {
    testWidgets('LoadingPage renders correctly on small mobile screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        responsiveTestableWidget(
          const LoadingPage(navigateAfterDelay: false),
          width: DeviceSizes.mobileSmall.width,
          height: DeviceSizes.mobileSmall.height,
        ),
      );
      
      // Verify essential elements are visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      
      // Check that elements are properly centered
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);
      
      // Verify LoadingPage contains expected elements on small screen
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('LoadingPage renders correctly on tablets', (WidgetTester tester) async {
      await tester.pumpWidget(
        responsiveTestableWidget(
          const LoadingPage(navigateAfterDelay: false),
          width: DeviceSizes.tablet.width,
          height: DeviceSizes.tablet.height,
        ),
      );
      
      // Verify essential elements are visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      
      // Check that elements are properly centered
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);
      
      // Verify LoadingPage contains expected elements on tablet
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
} 