import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantrysaver/widgets/app_modal.dart';

void main() {
  testWidgets('shows a success modal with title and message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppModal.show(
                  context,
                  type: AppModalType.success,
                  title: 'Saved',
                  message: 'Your changes were saved successfully.',
                ),
                child: const Text('Open modal'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open modal'));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Your changes were saved successfully.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}
