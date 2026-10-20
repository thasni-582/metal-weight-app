import 'package:metal_weight/models/profile_spec.dart';

class StandardData {
  StandardData._();

  // Equal Angles data strictly from maiak-m.bg: size -> { thickness: kg/m }
  static const Map<String, Map<String, double>> equalAngles = {
    '20': {'3': 0.88, '4': 1.15},
    '25': {'3': 1.12, '4': 1.45},
    '30': {'3': 1.36, '4': 1.78, '5': 2.18},
    '35': {'3': 1.60, '4': 2.09, '5': 2.57},
    '40': {'3': 1.85, '4': 2.42, '5': 2.97},
    '45': {'3': 2.08, '4': 2.74, '5': 3.38},
    '50': {'3': 2.32, '4': 3.06, '5': 3.77, '6': 4.47, '7': 5.15},
    '55': {'4': 3.38, '5': 4.18, '6': 4.95},
    '60': {'4': 3.70, '5': 4.57, '6': 5.42, '7': 6.26, '8': 7.09},
    '63': {'4': 3.90, '5': 4.81, '6': 5.72, '7': 6.61, '8': 7.48},
    '65': {'5': 4.97, '6': 5.91, '7': 6.83, '8': 7.73},
    '70': {'5': 5.38, '6': 6.38, '7': 7.38, '8': 8.37},
    '75': {'5': 5.80, '6': 6.85, '7': 7.94, '8': 8.99, '9': 10.07},
    '80': {'6': 7.34, '7': 8.51, '8': 9.63, '9': 10.80, '10': 11.90},
    '90': {'6': 8.33, '7': 9.61, '8': 10.90, '9': 12.20, '10': 13.40},
    '100': {'7': 10.79, '8': 12.20, '9': 13.60, '10': 15.00, '12': 17.80},
    '110': {'7': 11.89, '8': 13.50, '9': 15.00, '10': 16.60, '12': 19.70},
    '120': {'8': 14.70, '9': 16.50, '10': 18.20, '12': 21.60, '13': 23.30},
    '125': {'8': 15.46, '9': 17.30, '10': 19.10},
    '130': {'8': 15.99, '9': 17.90, '10': 19.79, '12': 23.60, '13': 25.37, '14': 27.20, '15': 29.00},
    '140': {'9': 19.41, '10': 21.45, '12': 25.50, '13': 27.50},
    '150': {'10': 23.00, '12': 27.30, '13': 29.50, '14': 31.60, '15': 33.80, '16': 35.90, '18': 40.10, '20': 44.20},
    '160': {'10': 24.67, '12': 29.35, '13': 31.60, '14': 34.20, '15': 36.20, '16': 38.52, '18': 43.00, '20': 47.40},
    '180': {'12': 33.12, '13': 35.70, '14': 38.30, '15': 40.90, '16': 43.50, '18': 48.60, '20': 53.70},
    '200': {'14': 42.80, '15': 45.60, '16': 48.50, '18': 54.30, '20': 59.90},
  };

  // Unequal Angles data strictly from maiak-m.bg: size (AxB) -> { thickness: kg/m }
  static const Map<String, Map<String, double>> unequalAngles = {
    '30x20': {'3': 1.12, '4': 1.46},
    '40x20': {'3': 1.35, '4': 1.77},
    '40x25': {'4': 1.93},
    '45x30': {'3': 1.72, '4': 2.25, '5': 2.77},
    '50x30': {'4': 2.41, '5': 2.96},
    '60x30': {'5': 3.36},
    '60x40': {'5': 3.76, '6': 4.46, '7': 5.14},
    '60x50': {'5': 4.15, '6': 4.93, '8': 6.43, '10': 7.88},
    '65x50': {'5': 4.35},
    '70x50': {'6': 5.41},
    '75x50': {'5': 4.74, '6': 5.65, '8': 7.39, '9': 8.23, '10': 9.05},
    '75x55': {'5': 4.95, '7': 6.80, '9': 8.59},
    '75x60': {'5': 5.14, '6': 6.11, '8': 8.01, '10': 9.85},
    '80x40': {'6': 5.41, '8': 7.07, '10': 8.67},
    '80x60': {'7': 7.36},
    '90x60': {'6': 6.82, '8': 8.96, '10': 11.04},
    '90x75': {'6': 7.55, '8': 9.93, '10': 12.23},
    '100x50': {'6': 6.84, '8': 8.97, '10': 11.10, '12': 13.06},
    '100x65': {'7': 8.77, '8': 9.94, '9': 11.10, '10': 12.30},
    '100x75': {'6': 8.04, '7': 9.32, '8': 10.60, '9': 11.80, '10': 13.00, '12': 15.40},
    '100x90': {'6': 8.77, '8': 11.53, '10': 14.23, '12': 16.87},
    '120x80': {'8': 12.20, '10': 15.00, '12': 17.80},
    '125x75': {'8': 12.20, '10': 15.00, '12': 17.80},
    '125x80': {'8': 12.58, '10': 15.47, '12': 18.34, '15': 22.47},
    '125x90': {'8': 13.12, '10': 16.21, '12': 19.24, '15': 23.65},
    '130x65': {'8': 11.90, '10': 14.60, '12': 17.30},
    '130x75': {'8': 12.47, '10': 15.41, '12': 18.28, '15': 22.47},
    '130x90': {'10': 16.60, '12': 19.70},
    '150x75': {'9': 15.40, '10': 17.00, '12': 20.20, '15': 24.80},
    '150x90': {'10': 18.20, '12': 21.60, '15': 26.60},
    '150x100': {'10': 19.00, '12': 22.50},
    '180x90': {'10': 20.60, '12': 24.50},
    '200x100': {'10': 23.00, '12': 27.30, '15': 33.75},
    '200x150': {'12': 32.00, '15': 39.60},
  };

  // Standard Channels UPN from DIN 1026-1 & maiak-m.bg
  static const Map<String, StandardProfileSpec> upnChannels = {
    '50': StandardProfileSpec(h: 50, b: 38, tw: 5.0, tf: 7.0, weight: 5.59, area: 7.12),
    '60': StandardProfileSpec(h: 60, b: 30, tw: 6.0, tf: 6.0, weight: 5.07, area: 6.46),
    '65': StandardProfileSpec(h: 65, b: 42, tw: 5.5, tf: 7.5, weight: 7.09, area: 9.03),
    '80': StandardProfileSpec(h: 80, b: 45, tw: 6.0, tf: 8.0, weight: 8.64, area: 11.00),
    '100': StandardProfileSpec(h: 100, b: 50, tw: 6.0, tf: 8.5, weight: 10.60, area: 13.50),
    '120': StandardProfileSpec(h: 120, b: 55, tw: 7.0, tf: 9.0, weight: 13.40, area: 17.00),
    '140': StandardProfileSpec(h: 140, b: 60, tw: 7.0, tf: 10.0, weight: 16.00, area: 20.40),
    '160': StandardProfileSpec(h: 160, b: 65, tw: 7.5, tf: 10.5, weight: 18.80, area: 24.00),
    '180': StandardProfileSpec(h: 180, b: 70, tw: 8.0, tf: 11.0, weight: 22.00, area: 28.00),
    '200': StandardProfileSpec(h: 200, b: 75, tw: 8.5, tf: 11.5, weight: 25.30, area: 32.20),
    '220': StandardProfileSpec(h: 220, b: 80, tw: 9.0, tf: 12.5, weight: 29.40, area: 37.40),
    '240': StandardProfileSpec(h: 240, b: 85, tw: 9.5, tf: 13.0, weight: 33.20, area: 42.30),
    '260': StandardProfileSpec(h: 260, b: 90, tw: 10.0, tf: 14.0, weight: 37.90, area: 48.30),
    '280': StandardProfileSpec(h: 280, b: 95, tw: 10.0, tf: 15.0, weight: 41.80, area: 53.30),
    '300': StandardProfileSpec(h: 300, b: 100, tw: 10.0, tf: 16.0, weight: 46.20, area: 58.80),
    '320': StandardProfileSpec(h: 320, b: 100, tw: 14.0, tf: 17.5, weight: 59.50, area: 75.80),
    '350': StandardProfileSpec(h: 350, b: 100, tw: 14.0, tf: 16.0, weight: 60.60, area: 77.30),
    '380': StandardProfileSpec(h: 380, b: 102, tw: 13.5, tf: 16.0, weight: 63.10, area: 80.40),
    '400': StandardProfileSpec(h: 400, b: 110, tw: 14.0, tf: 18.0, weight: 71.80, area: 91.50),
  };

  // Standard Channels UPE (DIN 1026-2)
  static const Map<String, StandardProfileSpec> upeChannels = {
    '80': StandardProfileSpec(h: 80, b: 40, tw: 4.5, tf: 7.4, weight: 7.10, area: 8.98),
    '100': StandardProfileSpec(h: 100, b: 55, tw: 4.5, tf: 7.5, weight: 9.82, area: 12.50),
    '120': StandardProfileSpec(h: 120, b: 60, tw: 5.0, tf: 8.0, weight: 12.10, area: 15.40),
    '140': StandardProfileSpec(h: 140, b: 65, tw: 5.0, tf: 9.0, weight: 14.50, area: 18.40),
    '160': StandardProfileSpec(h: 160, b: 70, tw: 5.5, tf: 9.5, weight: 17.00, area: 21.70),
    '180': StandardProfileSpec(h: 180, b: 75, tw: 5.5, tf: 10.5, weight: 19.70, area: 25.10),
    '200': StandardProfileSpec(h: 200, b: 80, tw: 6.0, tf: 11.0, weight: 22.80, area: 29.00),
    '220': StandardProfileSpec(h: 220, b: 85, tw: 6.5, tf: 12.0, weight: 26.60, area: 33.90),
    '240': StandardProfileSpec(h: 240, b: 90, tw: 7.0, tf: 12.5, weight: 30.20, area: 38.50),
    '270': StandardProfileSpec(h: 270, b: 95, tw: 7.5, tf: 13.5, weight: 35.20, area: 44.80),
    '300': StandardProfileSpec(h: 300, b: 100, tw: 9.5, tf: 15.0, weight: 44.40, area: 56.60),
    '330': StandardProfileSpec(h: 330, b: 105, tw: 11.0, tf: 16.0, weight: 53.40, area: 68.00),
    '360': StandardProfileSpec(h: 360, b: 110, tw: 12.0, tf: 17.0, weight: 61.20, area: 77.90),
    '400': StandardProfileSpec(h: 400, b: 115, tw: 13.5, tf: 18.0, weight: 72.20, area: 91.90),
  };

  // Beams IPE (DIN 1025-5 & maiak-m.bg)
  static const Map<String, StandardProfileSpec> ipeBeams = {
    '80': StandardProfileSpec(h: 80, b: 46, tw: 3.8, tf: 5.2, weight: 6.00, area: 7.64),
    '100': StandardProfileSpec(h: 100, b: 55, tw: 4.1, tf: 5.7, weight: 8.10, area: 10.30),
    '120': StandardProfileSpec(h: 120, b: 64, tw: 4.4, tf: 6.3, weight: 10.40, area: 13.20),
    '140': StandardProfileSpec(h: 140, b: 73, tw: 4.7, tf: 6.9, weight: 12.90, area: 16.40),
    '160': StandardProfileSpec(h: 160, b: 82, tw: 5.0, tf: 7.4, weight: 15.80, area: 20.10),
    '180': StandardProfileSpec(h: 180, b: 91, tw: 5.3, tf: 8.0, weight: 18.80, area: 23.90),
    '200': StandardProfileSpec(h: 200, b: 100, tw: 5.6, tf: 8.5, weight: 22.40, area: 28.50),
    '220': StandardProfileSpec(h: 220, b: 110, tw: 5.9, tf: 9.2, weight: 26.20, area: 33.40),
    '240': StandardProfileSpec(h: 240, b: 120, tw: 6.2, tf: 9.8, weight: 30.70, area: 39.10),
    '270': StandardProfileSpec(h: 270, b: 135, tw: 6.6, tf: 10.2, weight: 36.10, area: 45.90),
    '300': StandardProfileSpec(h: 300, b: 150, tw: 7.1, tf: 10.7, weight: 42.20, area: 53.80),
    '330': StandardProfileSpec(h: 330, b: 160, tw: 7.5, tf: 11.5, weight: 49.10, area: 62.60),
    '360': StandardProfileSpec(h: 360, b: 170, tw: 8.0, tf: 12.7, weight: 57.10, area: 72.70),
    '400': StandardProfileSpec(h: 400, b: 180, tw: 8.6, tf: 13.5, weight: 66.30, area: 84.50),
    '450': StandardProfileSpec(h: 450, b: 190, tw: 9.4, tf: 14.6, weight: 77.60, area: 98.80),
    '500': StandardProfileSpec(h: 500, b: 200, tw: 10.2, tf: 16.0, weight: 90.70, area: 116.00),
    '550': StandardProfileSpec(h: 550, b: 210, tw: 11.1, tf: 17.2, weight: 106.00, area: 134.00),
    '600': StandardProfileSpec(h: 600, b: 220, tw: 12.0, tf: 19.0, weight: 122.00, area: 156.00),
  };

  // Beams IPE-AA (Ultra-light European I-Beams)
  static const Map<String, StandardProfileSpec> ipeAaBeams = {
    '80': StandardProfileSpec(h: 78.0, b: 46.0, tw: 3.2, tf: 4.2, weight: 4.90, area: 6.30),
    '100': StandardProfileSpec(h: 97.6, b: 55.0, tw: 3.6, tf: 4.5, weight: 6.70, area: 8.50),
    '120': StandardProfileSpec(h: 117.0, b: 64.0, tw: 3.8, tf: 4.8, weight: 8.60, area: 11.00),
    '140': StandardProfileSpec(h: 136.6, b: 73.0, tw: 3.8, tf: 5.2, weight: 10.40, area: 13.30),
    '160': StandardProfileSpec(h: 156.4, b: 82.0, tw: 4.0, tf: 5.6, weight: 12.70, area: 16.20),
    '180': StandardProfileSpec(h: 176.4, b: 91.0, tw: 4.3, tf: 6.2, weight: 15.40, area: 19.60),
    '200': StandardProfileSpec(h: 196.4, b: 100.0, tw: 4.5, tf: 6.7, weight: 18.40, area: 23.40),
    '220': StandardProfileSpec(h: 216.4, b: 110.0, tw: 4.7, tf: 7.4, weight: 21.90, area: 27.90),
    '240': StandardProfileSpec(h: 236.4, b: 120.0, tw: 5.0, tf: 8.0, weight: 25.80, area: 32.90),
    '270': StandardProfileSpec(h: 266.0, b: 135.0, tw: 5.5, tf: 8.7, weight: 31.60, area: 40.20),
    '300': StandardProfileSpec(h: 296.0, b: 150.0, tw: 5.9, tf: 9.2, weight: 36.90, area: 47.00),
    '330': StandardProfileSpec(h: 326.0, b: 160.0, tw: 6.2, tf: 10.0, weight: 43.10, area: 54.90),
    '360': StandardProfileSpec(h: 356.0, b: 170.0, tw: 6.6, tf: 11.2, weight: 50.20, area: 64.00),
    '400': StandardProfileSpec(h: 396.0, b: 180.0, tw: 7.0, tf: 12.0, weight: 57.40, area: 73.20),
    '450': StandardProfileSpec(h: 446.0, b: 190.0, tw: 7.6, tf: 13.1, weight: 67.60, area: 86.10),
    '500': StandardProfileSpec(h: 496.0, b: 200.0, tw: 8.4, tf: 14.5, weight: 79.40, area: 101.10),
    '550': StandardProfileSpec(h: 546.0, b: 210.0, tw: 9.2, tf: 15.8, weight: 92.50, area: 117.80),
    '600': StandardProfileSpec(h: 596.0, b: 220.0, tw: 10.0, tf: 17.0, weight: 107.00, area: 136.30),
  };

  // Beams HEA (Euronorm 53-62)
  static const Map<String, StandardProfileSpec> heaBeams = {
    '100': StandardProfileSpec(h: 96, b: 100, tw: 5.0, tf: 8.0, weight: 16.70, area: 21.20),
    '120': StandardProfileSpec(h: 114, b: 120, tw: 5.0, tf: 8.0, weight: 19.90, area: 25.30),
    '140': StandardProfileSpec(h: 133, b: 140, tw: 5.5, tf: 8.5, weight: 24.70, area: 31.40),
    '160': StandardProfileSpec(h: 152, b: 160, tw: 6.0, tf: 9.0, weight: 30.40, area: 38.80),
    '180': StandardProfileSpec(h: 171, b: 180, tw: 6.0, tf: 9.5, weight: 35.50, area: 45.30),
    '200': StandardProfileSpec(h: 190, b: 200, tw: 6.5, tf: 10.0, weight: 42.30, area: 53.80),
    '220': StandardProfileSpec(h: 210, b: 220, tw: 7.0, tf: 11.0, weight: 50.50, area: 64.30),
    '240': StandardProfileSpec(h: 230, b: 240, tw: 7.5, tf: 12.0, weight: 60.30, area: 76.80),
    '260': StandardProfileSpec(h: 250, b: 260, tw: 7.5, tf: 12.5, weight: 68.20, area: 86.80),
    '280': StandardProfileSpec(h: 270, b: 280, tw: 8.0, tf: 13.0, weight: 76.40, area: 97.30),
    '300': StandardProfileSpec(h: 290, b: 300, tw: 8.5, tf: 14.0, weight: 88.30, area: 112.50),
  };

  // Beams HEB (Euronorm 53-62)
  static const Map<String, StandardProfileSpec> hebBeams = {
    '100': StandardProfileSpec(h: 100, b: 100, tw: 6.0, tf: 10.0, weight: 20.40, area: 26.00),
    '120': StandardProfileSpec(h: 120, b: 120, tw: 6.5, tf: 11.0, weight: 26.70, area: 34.00),
    '140': StandardProfileSpec(h: 140, b: 140, tw: 7.0, tf: 12.0, weight: 33.70, area: 43.00),
    '160': StandardProfileSpec(h: 160, b: 160, tw: 8.0, tf: 13.0, weight: 42.60, area: 54.30),
    '180': StandardProfileSpec(h: 180, b: 180, tw: 8.5, tf: 14.0, weight: 51.20, area: 65.30),
    '200': StandardProfileSpec(h: 200, b: 200, tw: 9.0, tf: 15.0, weight: 61.30, area: 78.10),
    '220': StandardProfileSpec(h: 220, b: 220, tw: 9.5, tf: 16.0, weight: 71.50, area: 91.00),
    '240': StandardProfileSpec(h: 240, b: 240, tw: 10.0, tf: 17.0, weight: 83.20, area: 106.00),
    '260': StandardProfileSpec(h: 260, b: 260, tw: 10.0, tf: 17.5, weight: 93.00, area: 118.40),
    '280': StandardProfileSpec(h: 280, b: 280, tw: 10.5, tf: 18.0, weight: 103.00, area: 131.20),
    '300': StandardProfileSpec(h: 300, b: 300, tw: 11.0, tf: 19.0, weight: 117.00, area: 149.10),
  };

  // Universal Beams (UB)
  static const Map<String, StandardProfileSpec> ubBeams = {
    '100': StandardProfileSpec(h: 100, b: 55, tw: 4.5, tf: 7.0, weight: 20.4, area: 26.0),
    '120': StandardProfileSpec(h: 120, b: 64, tw: 5.0, tf: 8.0, weight: 26.7, area: 34.0),
    '140': StandardProfileSpec(h: 140, b: 73, tw: 5.5, tf: 8.5, weight: 33.7, area: 42.9),
    '160': StandardProfileSpec(h: 160, b: 82, tw: 6.0, tf: 9.5, weight: 42.6, area: 54.3),
    '180': StandardProfileSpec(h: 180, b: 91, tw: 6.5, tf: 10.5, weight: 51.2, area: 65.3),
    '200': StandardProfileSpec(h: 200, b: 100, tw: 7.0, tf: 11.5, weight: 61.3, area: 78.1),
    '220': StandardProfileSpec(h: 220, b: 110, tw: 7.5, tf: 12.5, weight: 71.5, area: 91.0),
    '240': StandardProfileSpec(h: 240, b: 120, tw: 8.0, tf: 13.5, weight: 83.2, area: 106.0),
    '260': StandardProfileSpec(h: 260, b: 125, tw: 8.5, tf: 14.5, weight: 93.0, area: 118.4),
    '280': StandardProfileSpec(h: 280, b: 130, tw: 9.0, tf: 15.5, weight: 103.0, area: 131.2),
    '300': StandardProfileSpec(h: 300, b: 140, tw: 10.0, tf: 16.5, weight: 117.0, area: 149.1),
  };

  // Universal Columns (UC)
  static const Map<String, StandardProfileSpec> ucBeams = {
    '100': StandardProfileSpec(h: 100, b: 100, tw: 6.0, tf: 10.0, weight: 24.0, area: 30.6),
    '120': StandardProfileSpec(h: 120, b: 120, tw: 6.5, tf: 11.0, weight: 32.0, area: 40.8),
    '140': StandardProfileSpec(h: 140, b: 140, tw: 7.0, tf: 12.0, weight: 40.0, area: 51.0),
    '160': StandardProfileSpec(h: 160, b: 160, tw: 8.0, tf: 13.0, weight: 50.0, area: 63.7),
    '180': StandardProfileSpec(h: 180, b: 180, tw: 8.5, tf: 14.0, weight: 60.0, area: 76.5),
    '200': StandardProfileSpec(h: 200, b: 200, tw: 9.0, tf: 15.0, weight: 72.0, area: 91.8),
    '220': StandardProfileSpec(h: 220, b: 220, tw: 9.5, tf: 16.0, weight: 84.0, area: 107.1),
    '240': StandardProfileSpec(h: 240, b: 240, tw: 10.0, tf: 17.0, weight: 96.0, area: 122.4),
    '260': StandardProfileSpec(h: 260, b: 260, tw: 10.5, tf: 18.0, weight: 108.0, area: 137.7),
    '280': StandardProfileSpec(h: 280, b: 280, tw: 11.0, tf: 19.0, weight: 120.0, area: 153.0),
    '300': StandardProfileSpec(h: 300, b: 300, tw: 12.0, tf: 20.0, weight: 132.0, area: 168.3),
  };

  // ASTM A6 Wide Flange Beams (W-Beams)
  static const Map<String, StandardProfileSpec> wBeams = {
    'W 4x13': StandardProfileSpec(h: 106.0, b: 103.0, tw: 7.1, tf: 8.8, weight: 19.3, area: 24.6),
    'W 6x9': StandardProfileSpec(h: 150.0, b: 100.0, tw: 4.3, tf: 5.5, weight: 13.5, area: 17.2),
    'W 6x15': StandardProfileSpec(h: 152.0, b: 152.0, tw: 5.8, tf: 6.6, weight: 22.3, area: 28.4),
    'W 8x10': StandardProfileSpec(h: 200.0, b: 100.0, tw: 4.3, tf: 5.2, weight: 14.9, area: 19.0),
    'W 8x15': StandardProfileSpec(h: 206.0, b: 102.0, tw: 6.2, tf: 8.0, weight: 22.3, area: 28.4),
    'W 8x18': StandardProfileSpec(h: 207.0, b: 133.0, tw: 5.8, tf: 8.4, weight: 26.9, area: 34.3),
    'W 8x24': StandardProfileSpec(h: 201.0, b: 165.0, tw: 6.2, tf: 10.2, weight: 35.9, area: 45.7),
    'W 10x12': StandardProfileSpec(h: 251.0, b: 101.0, tw: 4.8, tf: 5.3, weight: 17.9, area: 22.8),
    'W 10x19': StandardProfileSpec(h: 260.0, b: 102.0, tw: 6.4, tf: 10.0, weight: 28.3, area: 36.1),
    'W 10x22': StandardProfileSpec(h: 259.0, b: 146.0, tw: 6.6, tf: 9.1, weight: 33.0, area: 42.0),
    'W 10x33': StandardProfileSpec(h: 247.0, b: 202.0, tw: 7.4, tf: 11.0, weight: 49.1, area: 62.6),
    'W 12x14': StandardProfileSpec(h: 302.0, b: 101.0, tw: 5.1, tf: 5.7, weight: 20.9, area: 26.6),
    'W 12x19': StandardProfileSpec(h: 309.0, b: 102.0, tw: 6.0, tf: 8.9, weight: 28.3, area: 36.0),
    'W 12x26': StandardProfileSpec(h: 310.0, b: 165.0, tw: 5.8, tf: 9.7, weight: 38.7, area: 49.3),
    'W 12x40': StandardProfileSpec(h: 303.0, b: 203.0, tw: 7.5, tf: 13.1, weight: 59.5, area: 75.8),
    'W 14x22': StandardProfileSpec(h: 349.0, b: 127.0, tw: 5.8, tf: 8.5, weight: 32.8, area: 41.8),
    'W 14x30': StandardProfileSpec(h: 352.0, b: 171.0, tw: 6.9, tf: 9.8, weight: 44.7, area: 56.9),
    'W 14x43': StandardProfileSpec(h: 347.0, b: 203.0, tw: 7.7, tf: 13.5, weight: 64.0, area: 81.5),
    'W 16x26': StandardProfileSpec(h: 399.0, b: 140.0, tw: 6.4, tf: 8.8, weight: 38.7, area: 49.3),
    'W 16x40': StandardProfileSpec(h: 407.0, b: 178.0, tw: 7.7, tf: 12.8, weight: 59.5, area: 75.8),
    'W 18x35': StandardProfileSpec(h: 450.0, b: 152.0, tw: 7.6, tf: 10.8, weight: 52.1, area: 66.4),
    'W 18x50': StandardProfileSpec(h: 457.0, b: 190.0, tw: 9.0, tf: 14.5, weight: 74.4, area: 94.8),
    'W 21x44': StandardProfileSpec(h: 525.0, b: 165.0, tw: 8.9, tf: 11.4, weight: 65.5, area: 83.4),
    'W 24x55': StandardProfileSpec(h: 599.0, b: 178.0, tw: 10.0, tf: 12.8, weight: 81.8, area: 104.2),
  };

  // Japanese Standard Channels (JIS G 3192)
  static const Map<String, StandardProfileSpec> jisChannels = {
    '75x40': StandardProfileSpec(h: 75.0, b: 40.0, tw: 5.0, tf: 7.0, weight: 6.92, area: 8.82),
    '100x50': StandardProfileSpec(h: 100.0, b: 50.0, tw: 5.0, tf: 7.5, weight: 9.36, area: 11.92),
    '125x65': StandardProfileSpec(h: 125.0, b: 65.0, tw: 6.0, tf: 8.0, weight: 13.40, area: 17.11),
    '150x75': StandardProfileSpec(h: 150.0, b: 75.0, tw: 6.5, tf: 10.0, weight: 18.60, area: 23.71),
    '150x75H': StandardProfileSpec(h: 150.0, b: 75.0, tw: 9.0, tf: 12.5, weight: 24.00, area: 30.59),
    '180x75': StandardProfileSpec(h: 180.0, b: 75.0, tw: 7.0, tf: 10.5, weight: 21.40, area: 27.20),
    '200x80': StandardProfileSpec(h: 200.0, b: 80.0, tw: 7.5, tf: 11.0, weight: 24.60, area: 31.33),
    '200x90': StandardProfileSpec(h: 200.0, b: 90.0, tw: 8.0, tf: 13.5, weight: 30.30, area: 38.65),
    '250x90': StandardProfileSpec(h: 250.0, b: 90.0, tw: 9.0, tf: 13.0, weight: 34.60, area: 44.07),
    '250x90H': StandardProfileSpec(h: 250.0, b: 90.0, tw: 11.0, tf: 14.5, weight: 40.20, area: 51.17),
    '300x90': StandardProfileSpec(h: 300.0, b: 90.0, tw: 9.0, tf: 13.0, weight: 38.10, area: 48.57),
    '300x90H': StandardProfileSpec(h: 300.0, b: 90.0, tw: 10.0, tf: 15.5, weight: 43.80, area: 55.74),
    '380x100': StandardProfileSpec(h: 380.0, b: 100.0, tw: 10.5, tf: 16.0, weight: 54.50, area: 69.39),
  };

  // Japanese Standard H-Beams (JIS G 3192)
  static const Map<String, StandardProfileSpec> jisBeams = {
    '100x100': StandardProfileSpec(h: 100.0, b: 100.0, tw: 6.0, tf: 8.0, weight: 17.20, area: 21.90),
    '125x125': StandardProfileSpec(h: 125.0, b: 125.0, tw: 6.5, tf: 9.0, weight: 23.80, area: 30.31),
    '150x75': StandardProfileSpec(h: 150.0, b: 75.0, tw: 5.0, tf: 7.0, weight: 14.00, area: 17.85),
    '150x150': StandardProfileSpec(h: 150.0, b: 150.0, tw: 7.0, tf: 10.0, weight: 31.50, area: 40.14),
    '175x90': StandardProfileSpec(h: 175.0, b: 90.0, tw: 5.0, tf: 8.0, weight: 18.10, area: 23.04),
    '175x175': StandardProfileSpec(h: 175.0, b: 175.0, tw: 7.5, tf: 11.0, weight: 40.20, area: 51.21),
    '200x100': StandardProfileSpec(h: 200.0, b: 100.0, tw: 5.5, tf: 8.0, weight: 21.30, area: 27.16),
    '200x200': StandardProfileSpec(h: 200.0, b: 200.0, tw: 8.0, tf: 12.0, weight: 49.90, area: 63.53),
    '250x125': StandardProfileSpec(h: 250.0, b: 125.0, tw: 6.0, tf: 9.0, weight: 29.60, area: 37.66),
    '250x250': StandardProfileSpec(h: 250.0, b: 250.0, tw: 9.0, tf: 14.0, weight: 72.40, area: 92.18),
    '300x150': StandardProfileSpec(h: 300.0, b: 150.0, tw: 6.5, tf: 9.0, weight: 36.70, area: 46.78),
    '300x300': StandardProfileSpec(h: 300.0, b: 300.0, tw: 10.0, tf: 15.0, weight: 94.00, area: 119.80),
    '350x175': StandardProfileSpec(h: 350.0, b: 175.0, tw: 7.0, tf: 11.0, weight: 49.60, area: 63.14),
    '350x350': StandardProfileSpec(h: 350.0, b: 350.0, tw: 12.0, tf: 19.0, weight: 137.00, area: 173.90),
    '400x200': StandardProfileSpec(h: 400.0, b: 200.0, tw: 8.0, tf: 13.0, weight: 66.00, area: 84.10),
    '400x400': StandardProfileSpec(h: 400.0, b: 400.0, tw: 13.0, tf: 21.0, weight: 172.00, area: 218.70),
  };

  // Standard Square Hollow Sections (SHS) - size -> { thickness: kg/m }
  static const Map<String, Map<String, double>> squareTubes = {
    '20x20': {'1.5': 0.84, '2.0': 1.07},
    '25x25': {'1.5': 1.08, '2.0': 1.39, '2.5': 1.68},
    '30x30': {'1.5': 1.31, '2.0': 1.70, '2.5': 2.07, '3.0': 2.42},
    '40x40': {'1.5': 1.78, '2.0': 2.33, '2.5': 2.86, '3.0': 3.36, '4.0': 4.30},
    '50x50': {'2.0': 2.96, '2.5': 3.64, '3.0': 4.30, '4.0': 5.56, '5.0': 6.73},
    '60x60': {'2.0': 3.59, '2.5': 4.43, '3.0': 5.25, '4.0': 6.82, '5.0': 8.30},
    '70x70': {'3.0': 6.19, '4.0': 8.07, '5.0': 9.87},
    '80x80': {'3.0': 7.13, '4.0': 9.33, '5.0': 11.40, '6.0': 13.50},
    '90x90': {'3.0': 8.07, '4.0': 10.60, '5.0': 13.00, '6.0': 15.40},
    '100x100': {'3.0': 9.01, '4.0': 11.80, '5.0': 14.60, '6.0': 17.30, '8.0': 22.30},
    '120x120': {'4.0': 14.40, '5.0': 17.70, '6.0': 21.00, '8.0': 27.40, '10.0': 33.40},
    '150x150': {'4.0': 18.10, '5.0': 22.40, '6.0': 26.70, '8.0': 35.00, '10.0': 42.80},
    '200x200': {'5.0': 30.30, '6.0': 36.10, '8.0': 47.50, '10.0': 58.50, '12.0': 69.10},
  };

  // Standard Rectangular Hollow Sections (RHS) - size -> { thickness: kg/m }
  static const Map<String, Map<String, double>> rectangularTubes = {
    '40x20': {'1.5': 1.31, '2.0': 1.70, '2.5': 2.07},
    '50x25': {'1.5': 1.66, '2.0': 2.17, '2.5': 2.66, '3.0': 3.12},
    '50x30': {'2.0': 2.33, '2.5': 2.86, '3.0': 3.36, '4.0': 4.30},
    '60x40': {'2.0': 2.96, '2.5': 3.64, '3.0': 4.30, '4.0': 5.56},
    '80x40': {'2.0': 3.59, '2.5': 4.43, '3.0': 5.25, '4.0': 6.82, '5.0': 8.30},
    '100x50': {'2.5': 5.61, '3.0': 6.66, '4.0': 8.70, '5.0': 10.70, '6.0': 12.50},
    '120x60': {'3.0': 8.07, '4.0': 10.60, '5.0': 13.00, '6.0': 15.40},
    '120x80': {'3.0': 9.01, '4.0': 11.80, '5.0': 14.60, '6.0': 17.30, '8.0': 22.30},
    '140x80': {'4.0': 13.10, '5.0': 16.20, '6.0': 19.20, '8.0': 24.90},
    '150x100': {'4.0': 15.00, '5.0': 18.50, '6.0': 22.00, '8.0': 28.70, '10.0': 35.00},
    '160x80': {'4.0': 14.40, '5.0': 17.70, '6.0': 21.00, '8.0': 27.40},
    '200x100': {'4.0': 18.10, '5.0': 22.40, '6.0': 26.70, '8.0': 35.00, '10.0': 42.80},
    '250x150': {'5.0': 30.30, '6.0': 36.10, '8.0': 47.50, '10.0': 58.50, '12.0': 69.10},
  };

  // Standard Steel Pipes (ERW / Seamless - ASTM A53 / API 5L) - size -> { schedule: kg/m }
  static const Map<String, Map<String, double>> steelPipes = {
    '1/2" (21.3 mm)': {'Sch 40 (2.77mm)': 1.27, 'Sch 80 (3.73mm)': 1.62},
    '3/4" (26.7 mm)': {'Sch 40 (2.87mm)': 1.69, 'Sch 80 (3.91mm)': 2.20},
    '1" (33.4 mm)': {'Sch 40 (3.38mm)': 2.50, 'Sch 80 (4.55mm)': 3.24},
    '1-1/4" (42.2 mm)': {'Sch 40 (3.56mm)': 3.39, 'Sch 80 (4.85mm)': 4.47},
    '1-1/2" (48.3 mm)': {'Sch 40 (3.68mm)': 4.05, 'Sch 80 (5.08mm)': 5.41},
    '2" (60.3 mm)': {'Sch 40 (3.91mm)': 5.44, 'Sch 80 (5.54mm)': 7.48},
    '2-1/2" (73.0 mm)': {'Sch 40 (5.16mm)': 8.63, 'Sch 80 (7.01mm)': 11.41},
    '3" (88.9 mm)': {'Sch 40 (5.49mm)': 11.29, 'Sch 80 (7.62mm)': 15.27},
    '4" (114.3 mm)': {'Sch 40 (6.02mm)': 16.07, 'Sch 80 (8.56mm)': 22.32},
    '5" (141.3 mm)': {'Sch 40 (6.55mm)': 21.77, 'Sch 80 (9.53mm)': 30.97},
    '6" (168.3 mm)': {'Sch 40 (7.11mm)': 28.26, 'Sch 80 (10.97mm)': 42.56},
    '8" (219.1 mm)': {'Sch 40 (8.18mm)': 42.55, 'Sch 80 (12.70mm)': 64.64},
    '10" (273.0 mm)': {'Sch 40 (9.27mm)': 60.31, 'Sch 80 (15.09mm)': 95.97},
    '12" (323.8 mm)': {'Sch 40 (10.31mm)': 79.73, 'Sch 80 (17.48mm)': 132.08},
    '14" (355.6 mm)': {
      'Sch 10 (6.35mm)': 54.69,
      'Sch 20 (7.92mm)': 67.90,
      'Sch STD (9.53mm)': 81.33,
      'Sch 40 (11.13mm)': 94.55,
      'Sch XS (12.70mm)': 107.39,
      'Sch 80 (15.09mm)': 126.70,
    },
    '16" (406.4 mm)': {
      'Sch 10 (6.35mm)': 62.64,
      'Sch 20 (7.92mm)': 77.83,
      'Sch STD (9.53mm)': 93.27,
      'Sch 40 / XS (12.70mm)': 123.30,
      'Sch 80 (16.66mm)': 160.10,
    },
    '18" (457.2 mm)': {
      'Sch 10 (6.35mm)': 70.57,
      'Sch 20 (7.92mm)': 87.71,
      'Sch STD (9.53mm)': 105.10,
      'Sch XS (12.70mm)': 139.15,
      'Sch 40 (14.27mm)': 155.80,
      'Sch 80 (19.05mm)': 205.70,
    },
    '20" (508.0 mm)': {
      'Sch 10 (6.35mm)': 78.55,
      'Sch 20 / STD (9.53mm)': 117.10,
      'Sch XS (12.70mm)': 155.10,
      'Sch 40 (15.09mm)': 183.40,
      'Sch 80 (20.62mm)': 247.88,
    },
    '24" (609.6 mm)': {
      'Sch 10 (6.35mm)': 94.53,
      'Sch 20 / STD (9.53mm)': 141.10,
      'Sch XS (12.70mm)': 187.00,
      'Sch 40 (17.48mm)': 255.40,
      'Sch 80 (24.61mm)': 355.28,
    },
  };

  // HR Checkered Sheet weights (kg/m²) - Mild Steel teardrop pattern
  static const Map<String, double> hrCheckeredWeights = {
    '2.0': 17.50,
    '2.5': 21.40,
    '3.0': 25.40,
    '4.0': 33.20,
    '4.5': 37.10,
    '5.0': 41.10,
    '6.0': 49.00,
    '8.0': 64.70,
  };

  // Flat Bars standard widths and thicknesses (mm)
  static const List<String> flatBarWidths = [
    '15', '20', '25', '30', '35', '40', '45', '50', '60', '70', '75', '80', '90', '100', '120', '130', '150', '200'
  ];

  static const List<String> flatBarThicknesses = [
    '3', '4', '5', '6', '8', '10', '12', '15', '16', '20', '25', '30'
  ];

  // Steel Sheets standard thicknesses (mm)
  static const List<String> sheetThicknesses = [
    '0.5', '0.8', '1.0', '1.2', '1.5', '2.0', '2.5', '3.0', '4.0', '5.0', '6.0', '8.0', '10.0', '12.0', '15.0', '20.0', '25.0', '30.0'
  ];

  // Aluminum Checkered Sheet thicknesses (mm)
  static const List<String> checkeredSheetThicknesses = [
    '1.5', '2.0', '2.5', '3.0', '4.0', '4.5', '5.0', '6.0', '8.0'
  ];

  // Aluminum Checkered Sheet weights (kg/m²) - EN 1386 5-bar standard pattern
  static const Map<String, double> aluminumCheckeredWeights = {
    '1.5': 5.55,
    '2.0': 7.00,
    '2.5': 8.35,
    '3.0': 9.80,
    '4.0': 12.60,
    '4.5': 14.00,
    '5.0': 15.40,
    '6.0': 18.20,
    '8.0': 23.80,
  };

  // Round Bar standard diameters (mm)
  static const List<String> roundBarDiameters = [
    '6', '8', '10', '12', '14', '16', '18', '20', '22', '25', '28', '30', '32', '36', '40', '45', '50', '55', '60', '70', '80', '90', '100'
  ];

  // Material densities in g/cm3 (or kg/dm3)
  static const Map<String, double> densities = {
    'Steel': 7.85,
    'Stainless Steel': 8.00,
    'Galvanized Sheet': 8.10,
    'HR Chequered Sheet': 8.50,
    'Aluminum': 2.70,
    'Brass': 8.50,
    'Copper': 8.96,
  };
}
