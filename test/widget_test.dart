import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:metal_weight/core/providers/app_settings_provider.dart';
import 'package:metal_weight/main.dart';
import 'package:metal_weight/screens/calculator/calculation_screen.dart';

void main() {
  testWidgets('App launches to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Milen Trading'), findsOneWidget);
  });

  testWidgets('CalculationScreen renders UB Beam 838 x 292 x 176 with 175.90 kg/m and 2110.80 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'UB (Universal Beam)',
      size: '838 x 292 x 176',
      thickness: '',
      variant: 'UB',
      lengthInM: 12.0,
      quantity: 1,
      weightPerM: 175.90,
      sectionArea: 224.00,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: CalculationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('175.90 kg/m'), findsWidgets);
    expect(find.text('2110.80 kg'), findsWidgets);
    expect(find.text('224.00 cm²'), findsWidgets);
  });

  testWidgets('CalculationScreen renders UC Column 152 x 152 x 23 with 23.00 kg/m and 138.00 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'UC (Universal Columns)',
      size: '152 x 152 x 23',
      thickness: '',
      variant: 'UC',
      lengthInM: 6.0,
      quantity: 1,
      weightPerM: 23.00,
      sectionArea: 29.20,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: CalculationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('23.00 kg/m'), findsWidgets);
    expect(find.text('138.00 kg'), findsWidgets);
    expect(find.text('29.20 cm²'), findsWidgets);
  });

  testWidgets('CalculationScreen renders W-Beam W 8 x 8 x 31 with 46.10 kg/m and 461.00 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'W-Beam (Wide Flange)',
      size: 'W 8 x 8 x 31 (203 x 203 x 46.1)',
      thickness: '',
      variant: 'W-Beam',
      lengthInM: 10.0,
      quantity: 1,
      weightPerM: 46.10,
      sectionArea: 58.73,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: CalculationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('46.10 kg/m'), findsWidgets);
    expect(find.text('461.00 kg'), findsWidgets);
    expect(find.text('58.73 cm²'), findsWidgets);
  });

  testWidgets('CalculationScreen renders Equal Angle 50x5 with 3.77 kg/m, 4.80 cm², 45.24 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'Equal Angle',
      size: '50',
      thickness: '5',
      variant: '20 to 60',
      lengthInM: 6.0,
      quantity: 2,
      weightPerM: 3.77,
      sectionArea: 4.80,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: CalculationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3.77 kg/m'), findsWidgets);
    expect(find.text('45.24 kg'), findsWidgets);
    expect(find.text('4.80 cm²'), findsWidgets);
  });

  testWidgets('CalculationScreen renders Unequal Angle 60x40x5 with 3.76 kg/m, 4.79 cm², 22.56 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'Unequal Angle',
      size: '60x40',
      thickness: '5',
      variant: 'UNEQUAL',
      lengthInM: 6.0,
      quantity: 1,
      weightPerM: 3.76,
      sectionArea: 4.79,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: CalculationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3.76 kg/m'), findsWidgets);
    expect(find.text('22.56 kg'), findsWidgets);
    expect(find.text('4.79 cm²'), findsWidgets);
  });

  testWidgets('CalculationScreen renders SS Angle 50x5 with 3.84 kg/m, 4.80 cm², 23.05 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Stainless Steel',
      shape: 'SS Angle (Stainless Steel)',
      size: '50',
      thickness: '5',
      variant: 'SS 304/316',
      lengthInM: 6.0,
      quantity: 1,
      weightPerM: 3.84,
      sectionArea: 4.80,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: CalculationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3.84 kg/m'), findsWidgets);
    expect(find.text('23.05 kg'), findsWidgets);
    expect(find.text('4.80 cm²'), findsWidgets);
  });

  testWidgets('CalculationScreen renders Aluminum Angle 50x5 with 1.30 kg/m, 4.80 cm², 7.78 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Aluminum',
      shape: 'Aluminum Angle',
      size: '50',
      thickness: '5',
      variant: '6063-T6',
      lengthInM: 6.0,
      quantity: 1,
      weightPerM: 1.30,
      sectionArea: 4.80,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: CalculationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1.30 kg/m'), findsWidgets);
    expect(find.text('7.78 kg'), findsWidgets);
    expect(find.text('4.80 cm²'), findsWidgets);
  });
}
