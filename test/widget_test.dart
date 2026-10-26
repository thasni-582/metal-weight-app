import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:metal_weight/core/constants/standard_data.dart';
import 'package:metal_weight/core/providers/app_settings_provider.dart';
import 'package:metal_weight/main.dart';
import 'package:metal_weight/screens/calculator/calculation_screen.dart';
import 'package:metal_weight/screens/home/widgets/section_diagram_2d.dart';

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
      variant: 'EQUAL',
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

  testWidgets('U-Channel (JIS) and UPN Channel sizes and blueprint headers verify correctly', (WidgetTester tester) async {
    // Assert JIS channels only up to 150x75H
    expect(StandardData.jisChannels.keys.toList(), equals(['75x40', '100x50', '125x65', '150x75', '150x75H']));
    // Assert UPN channels maximum size is 300
    expect(StandardData.upnChannels.keys.contains('300'), isTrue);
    expect(StandardData.upnChannels.keys.contains('320'), isFalse);
    expect(StandardData.upnChannels.keys.contains('350'), isFalse);
    expect(StandardData.upnChannels.keys.contains('400'), isFalse);

    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'U-Channel (JIS)',
      size: '150x75H',
      thickness: '',
      variant: 'U Channel',
      lengthInM: 12.0,
      quantity: 1,
      weightPerM: 24.00,
      sectionArea: 30.59,
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

    expect(find.text('24.00 kg/m'), findsWidgets);
    expect(find.text('288.00 kg'), findsWidgets);
    expect(find.text('30.59 cm²'), findsWidgets);
    expect(find.text('U CHANNEL'), findsOneWidget);
  });

  testWidgets('CalculationScreen renders IPE-AA Beam 160 with 12.30 kg/m and 15.68 cm²', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'IPE-AA Beam',
      size: '160',
      thickness: '',
      variant: 'IPE-AA',
      lengthInM: 12.0,
      quantity: 1,
      weightPerM: 12.30,
      sectionArea: 15.68,
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

    expect(find.text('12.30 kg/m'), findsWidgets);
    expect(find.text('147.60 kg'), findsWidgets);
    expect(find.text('15.68 cm²'), findsWidgets);
  });

  testWidgets('CalculationScreen renders HR Checkered Sheet 8mm 1x1m with 68.00 kg/m² and 68.00 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'HR Chequered Sheet',
      shape: 'HR Checkered Sheet',
      size: '8.0',
      thickness: '',
      variant: '',
      lengthInM: 1.0,
      quantity: 1,
      weightPerM: 68.00,
      sectionArea: 80.0,
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

    expect(find.text('68.00 kg/m²'), findsWidgets);

    final widthField = find.widgetWithText(TextField, '500');
    if (widthField.evaluate().isNotEmpty) {
      await tester.enterText(widthField, '1000');
      await tester.pumpAndSettle();
    }
    expect(find.text('68.00 kg'), findsWidgets);
  });

  testWidgets('CalculationScreen renders SS Checkered Sheet 8mm 1x1m with 66.40 kg/m² and 66.40 kg', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'SS Chequered Sheet',
      shape: 'Stainless Steel Checkered Sheet',
      size: '8.0',
      thickness: '',
      variant: '',
      lengthInM: 1.0,
      quantity: 1,
      weightPerM: 66.40,
      sectionArea: 80.0,
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

    expect(find.text('66.40 kg/m²'), findsWidgets);

    final widthField = find.widgetWithText(TextField, '500');
    if (widthField.evaluate().isNotEmpty) {
      await tester.enterText(widthField, '1000');
      await tester.pumpAndSettle();
    }
    expect(find.text('66.40 kg'), findsWidgets);
  });

  testWidgets('Section2DDiagramWidget renders MS ROUND BAR for MS Round Bar shape', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Section2DDiagramWidget(
              shapeType: 'MS Round Bar',
              selectedSize: '32',
              selectedThickness: '',
              availableSizes: ['32'],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MS ROUND BAR'), findsOneWidget);
  });

  testWidgets('CalculationScreen and Section2DDiagramWidget render full client HEA Beam 1000 with 272.00 kg/m', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Section2DDiagramWidget(
              shapeType: 'HEA Beam',
              selectedSize: '1000',
              selectedThickness: '',
              availableSizes: ['1000'],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HEA BEAM'), findsOneWidget);

    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'HEA Beam',
      size: '1000',
      thickness: '',
      variant: 'HEA',
      lengthInM: 12.0,
      quantity: 1,
      weightPerM: 272.00,
      sectionArea: 346.80,
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

    expect(find.text('272.00 kg/m'), findsWidgets);
    expect(find.text('3264.00 kg'), findsWidgets);
  });

  testWidgets('CalculationScreen and Section2DDiagramWidget render full client HEB Beam 1000 with 314.00 kg/m', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Section2DDiagramWidget(
              shapeType: 'HEB Beam',
              selectedSize: '1000',
              selectedThickness: '',
              availableSizes: ['1000'],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HEB BEAM'), findsOneWidget);

    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'HEB Beam',
      size: '1000',
      thickness: '',
      variant: 'HEB',
      lengthInM: 12.0,
      quantity: 1,
      weightPerM: 314.00,
      sectionArea: 400.00,
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

    expect(find.text('314.00 kg/m'), findsWidgets);
    expect(find.text('3768.00 kg'), findsWidgets);
  });

  testWidgets('CalculationScreen and Section2DDiagramWidget render client W-Beam W 4 x 4 x 13 with 19.30 kg/m', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Section2DDiagramWidget(
              shapeType: 'W-Beam (Wide Flange)',
              selectedSize: 'W 4 x 4 x 13 (102 x 102 x 19.3)',
              selectedThickness: '',
              availableSizes: ['W 4 x 4 x 13 (102 x 102 x 19.3)'],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('W-BEAM'), findsOneWidget);

    final settings = AppSettingsProvider();
    settings.syncProfileFromHome(
      material: 'Steel',
      shape: 'W-Beam (Wide Flange)',
      size: 'W 4 x 4 x 13 (102 x 102 x 19.3)',
      thickness: '',
      variant: 'W-Beam',
      lengthInM: 12.0,
      quantity: 1,
      weightPerM: 19.30,
      sectionArea: 24.70,
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

    expect(find.text('19.30 kg/m'), findsWidgets);
    expect(find.text('231.60 kg'), findsWidgets);
    expect(find.text('24.70 cm²'), findsWidgets);
  });
}
