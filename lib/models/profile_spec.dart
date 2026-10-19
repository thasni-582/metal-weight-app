class StandardProfileSpec {
  final double h; // Height in mm
  final double b; // Width / Base in mm
  final double tw; // Web thickness in mm
  final double tf; // Flange thickness in mm
  final double weight; // Weight in kg/m
  final double area; // Cross-sectional area in cm2

  const StandardProfileSpec({
    required this.h,
    required this.b,
    required this.tw,
    required this.tf,
    required this.weight,
    required this.area,
  });
}
