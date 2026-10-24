import 'package:metal_weight/models/profile_spec.dart';

class StandardData {
  StandardData._();

  // Equal Angles data strictly from maiak-m.bg: size -> { thickness: kg/m }
  static const Map<String, Map<String, double>> equalAngles = {
    '20': {'2': 0.60, '2.5': 0.74, '3': 0.88},
    '25': {'2.5': 0.94, '3': 1.12, '4': 1.45},
    '30': {'2.5': 1.13, '2.7': 1.23, '3': 1.36, '4': 1.78, '5': 2.18},
    '35': {'2.5': 1.35, '3': 1.60, '3.5': 1.85, '4': 2.10, '5': 2.57},
    '40': {'3': 1.84, '4': 2.42, '5': 2.97, '6': 3.52},
    '45': {'3': 2.09, '4': 2.74, '4.5': 3.06, '5': 3.38, '6': 4.00},
    '50': {'3': 2.33, '4': 3.06, '4.5': 3.41, '5': 3.77, '6': 4.47, '7': 5.15, '8': 5.82},
    '60': {'4': 3.70, '4.5': 4.13, '5': 4.57, '5.5': 5.00, '6': 5.42, '8': 7.09, '10': 8.69},
    '70': {'5': 5.37, '5.5': 5.87, '6': 6.38, '6.5': 6.88, '7': 7.38, '9': 9.34},
    '75': {'5': 5.80, '6': 6.85, '7': 7.94, '8': 8.99, '9': 10.07},
    '80': {'5.5': 6.76, '6': 7.34, '7': 8.49, '7.5': 9.06, '8': 9.63, '9': 10.80, '10': 11.90},
    '90': {'6': 8.33, '7': 9.61, '8': 10.90, '9': 12.20, '10': 13.40},
    '100': {'7': 10.79, '8': 12.20, '9': 13.60, '10': 15.00, '12': 17.80},
    '110': {'7': 11.89, '8': 13.50, '9': 15.00, '10': 16.60, '12': 19.70},
    '120': {'8': 14.70, '9': 16.50, '10': 18.20, '12': 21.60, '13': 23.30},
    '125': {'8': 15.46, '9': 17.30, '10': 19.10},
    '130': {
      '8': 15.99,
      '9': 17.90,
      '10': 19.79,
      '12': 23.60,
      '13': 25.37,
      '14': 27.20,
      '15': 29.00
    },
    '140': {'9': 19.41, '10': 21.45, '12': 25.50, '13': 27.50},
    '150': {
      '10': 23.00,
      '12': 27.30,
      '13': 29.50,
      '14': 31.60,
      '15': 33.80,
      '16': 35.90,
      '18': 40.10,
      '20': 44.20
    },
    '160': {
      '10': 24.67,
      '12': 29.35,
      '13': 31.60,
      '14': 34.20,
      '15': 36.20,
      '16': 38.52,
      '18': 43.00,
      '20': 47.40
    },
    '180': {
      '12': 33.12,
      '13': 35.70,
      '14': 38.30,
      '15': 40.90,
      '16': 43.50,
      '18': 48.60,
      '20': 53.70
    },
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
    '100x75': {
      '6': 8.04,
      '7': 9.32,
      '8': 10.60,
      '9': 11.80,
      '10': 13.00,
      '12': 15.40
    },
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
    '50': StandardProfileSpec(
        h: 50, b: 38, tw: 5.0, tf: 7.0, weight: 5.59, area: 7.12),
    '60': StandardProfileSpec(
        h: 60, b: 30, tw: 6.0, tf: 6.0, weight: 5.07, area: 6.46),
    '65': StandardProfileSpec(
        h: 65, b: 42, tw: 5.5, tf: 7.5, weight: 7.09, area: 9.03),
    '80': StandardProfileSpec(
        h: 80, b: 45, tw: 6.0, tf: 8.0, weight: 8.64, area: 11.00),
    '100': StandardProfileSpec(
        h: 100, b: 50, tw: 6.0, tf: 8.5, weight: 10.60, area: 13.50),
    '120': StandardProfileSpec(
        h: 120, b: 55, tw: 7.0, tf: 9.0, weight: 13.40, area: 17.00),
    '140': StandardProfileSpec(
        h: 140, b: 60, tw: 7.0, tf: 10.0, weight: 16.00, area: 20.40),
    '160': StandardProfileSpec(
        h: 160, b: 65, tw: 7.5, tf: 10.5, weight: 18.80, area: 24.00),
    '180': StandardProfileSpec(
        h: 180, b: 70, tw: 8.0, tf: 11.0, weight: 22.00, area: 28.00),
    '200': StandardProfileSpec(
        h: 200, b: 75, tw: 8.5, tf: 11.5, weight: 25.30, area: 32.20),
    '220': StandardProfileSpec(
        h: 220, b: 80, tw: 9.0, tf: 12.5, weight: 29.40, area: 37.40),
    '240': StandardProfileSpec(
        h: 240, b: 85, tw: 9.5, tf: 13.0, weight: 33.20, area: 42.30),
    '260': StandardProfileSpec(
        h: 260, b: 90, tw: 10.0, tf: 14.0, weight: 37.90, area: 48.30),
    '280': StandardProfileSpec(
        h: 280, b: 95, tw: 10.0, tf: 15.0, weight: 41.80, area: 53.30),
    '300': StandardProfileSpec(
        h: 300, b: 100, tw: 10.0, tf: 16.0, weight: 46.20, area: 58.80),
  };

  // Standard Channels UPE (DIN 1026-2)
  static const Map<String, StandardProfileSpec> upeChannels = {
    '80': StandardProfileSpec(
        h: 80, b: 40, tw: 4.5, tf: 7.4, weight: 7.10, area: 8.98),
    '100': StandardProfileSpec(
        h: 100, b: 55, tw: 4.5, tf: 7.5, weight: 9.82, area: 12.50),
    '120': StandardProfileSpec(
        h: 120, b: 60, tw: 5.0, tf: 8.0, weight: 12.10, area: 15.40),
    '140': StandardProfileSpec(
        h: 140, b: 65, tw: 5.0, tf: 9.0, weight: 14.50, area: 18.40),
    '160': StandardProfileSpec(
        h: 160, b: 70, tw: 5.5, tf: 9.5, weight: 17.00, area: 21.70),
    '180': StandardProfileSpec(
        h: 180, b: 75, tw: 5.5, tf: 10.5, weight: 19.70, area: 25.10),
    '200': StandardProfileSpec(
        h: 200, b: 80, tw: 6.0, tf: 11.0, weight: 22.80, area: 29.00),
    '220': StandardProfileSpec(
        h: 220, b: 85, tw: 6.5, tf: 12.0, weight: 26.60, area: 33.90),
    '240': StandardProfileSpec(
        h: 240, b: 90, tw: 7.0, tf: 12.5, weight: 30.20, area: 38.50),
    '270': StandardProfileSpec(
        h: 270, b: 95, tw: 7.5, tf: 13.5, weight: 35.20, area: 44.80),
    '300': StandardProfileSpec(
        h: 300, b: 100, tw: 9.5, tf: 15.0, weight: 44.40, area: 56.60),
    '330': StandardProfileSpec(
        h: 330, b: 105, tw: 11.0, tf: 16.0, weight: 53.40, area: 68.00),
    '360': StandardProfileSpec(
        h: 360, b: 110, tw: 12.0, tf: 17.0, weight: 61.20, area: 77.90),
    '400': StandardProfileSpec(
        h: 400, b: 115, tw: 13.5, tf: 18.0, weight: 72.20, area: 91.90),
  };

  // Beams IPE (DIN 1025-5 & maiak-m.bg)
  static const Map<String, StandardProfileSpec> ipeBeams = {
    '80': StandardProfileSpec(
        h: 80, b: 46, tw: 3.8, tf: 5.2, weight: 6.00, area: 7.64),
    '100': StandardProfileSpec(
        h: 100, b: 55, tw: 4.1, tf: 5.7, weight: 8.10, area: 10.30),
    '120': StandardProfileSpec(
        h: 120, b: 64, tw: 4.4, tf: 6.3, weight: 10.40, area: 13.20),
    '140': StandardProfileSpec(
        h: 140, b: 73, tw: 4.7, tf: 6.9, weight: 12.90, area: 16.40),
    '160': StandardProfileSpec(
        h: 160, b: 82, tw: 5.0, tf: 7.4, weight: 15.80, area: 20.10),
    '180': StandardProfileSpec(
        h: 180, b: 91, tw: 5.3, tf: 8.0, weight: 18.80, area: 23.90),
    '200': StandardProfileSpec(
        h: 200, b: 100, tw: 5.6, tf: 8.5, weight: 22.40, area: 28.50),
    '220': StandardProfileSpec(
        h: 220, b: 110, tw: 5.9, tf: 9.2, weight: 26.20, area: 33.40),
    '240': StandardProfileSpec(
        h: 240, b: 120, tw: 6.2, tf: 9.8, weight: 30.70, area: 39.10),
    '270': StandardProfileSpec(
        h: 270, b: 135, tw: 6.6, tf: 10.2, weight: 36.10, area: 45.90),
    '300': StandardProfileSpec(
        h: 300, b: 150, tw: 7.1, tf: 10.7, weight: 42.20, area: 53.80),
    '330': StandardProfileSpec(
        h: 330, b: 160, tw: 7.5, tf: 11.5, weight: 49.10, area: 62.60),
    '360': StandardProfileSpec(
        h: 360, b: 170, tw: 8.0, tf: 12.7, weight: 57.10, area: 72.70),
    '400': StandardProfileSpec(
        h: 400, b: 180, tw: 8.6, tf: 13.5, weight: 66.30, area: 84.50),
    '450': StandardProfileSpec(
        h: 450, b: 190, tw: 9.4, tf: 14.6, weight: 77.60, area: 98.80),
    '500': StandardProfileSpec(
        h: 500, b: 200, tw: 10.2, tf: 16.0, weight: 90.70, area: 116.00),
    '550': StandardProfileSpec(
        h: 550, b: 210, tw: 11.1, tf: 17.2, weight: 106.00, area: 134.00),
    '600': StandardProfileSpec(
        h: 600, b: 220, tw: 12.0, tf: 19.0, weight: 122.00, area: 156.00),
  };

  // Beams IPE-AA (Ultra-light European I-Beams, Client Stock Specification)
  static const Map<String, StandardProfileSpec> ipeAaBeams = {
    '80': StandardProfileSpec(
        h: 80.0, b: 46.0, tw: 3.2, tf: 4.6, weight: 4.85, area: 6.18),
    '100': StandardProfileSpec(
        h: 100.0, b: 55.0, tw: 3.5, tf: 4.8, weight: 5.72, area: 7.29),
    '120': StandardProfileSpec(
        h: 120.0, b: 64.0, tw: 3.7, tf: 5.0, weight: 8.36, area: 10.65),
    '140': StandardProfileSpec(
        h: 140.0, b: 73.0, tw: 3.8, tf: 5.2, weight: 10.10, area: 12.87),
    '160': StandardProfileSpec(
        h: 160.0, b: 82.0, tw: 4.0, tf: 5.6, weight: 12.30, area: 15.68),
    '180': StandardProfileSpec(
        h: 180.0, b: 91.0, tw: 4.3, tf: 6.2, weight: 14.90, area: 18.98),
    '200': StandardProfileSpec(
        h: 200.0, b: 100.0, tw: 4.5, tf: 6.7, weight: 18.00, area: 22.87),
  };

  // Beams HEA (Euronorm 53-62)
  static const Map<String, StandardProfileSpec> heaBeams = {
    '100': StandardProfileSpec(
        h: 96, b: 100, tw: 5.0, tf: 8.0, weight: 16.70, area: 21.20),
    '120': StandardProfileSpec(
        h: 114, b: 120, tw: 5.0, tf: 8.0, weight: 19.90, area: 25.30),
    '140': StandardProfileSpec(
        h: 133, b: 140, tw: 5.5, tf: 8.5, weight: 24.70, area: 31.40),
    '160': StandardProfileSpec(
        h: 152, b: 160, tw: 6.0, tf: 9.0, weight: 30.40, area: 38.80),
    '180': StandardProfileSpec(
        h: 171, b: 180, tw: 6.0, tf: 9.5, weight: 35.50, area: 45.30),
    '200': StandardProfileSpec(
        h: 190, b: 200, tw: 6.5, tf: 10.0, weight: 42.30, area: 53.80),
    '220': StandardProfileSpec(
        h: 210, b: 220, tw: 7.0, tf: 11.0, weight: 50.50, area: 64.30),
    '240': StandardProfileSpec(
        h: 230, b: 240, tw: 7.5, tf: 12.0, weight: 60.30, area: 76.80),
    '260': StandardProfileSpec(
        h: 250, b: 260, tw: 7.5, tf: 12.5, weight: 68.20, area: 86.80),
    '280': StandardProfileSpec(
        h: 270, b: 280, tw: 8.0, tf: 13.0, weight: 76.40, area: 97.30),
    '300': StandardProfileSpec(
        h: 290, b: 300, tw: 8.5, tf: 14.0, weight: 88.30, area: 112.50),
  };

  // Beams HEB (Euronorm 53-62)
  static const Map<String, StandardProfileSpec> hebBeams = {
    '100': StandardProfileSpec(
        h: 100, b: 100, tw: 6.0, tf: 10.0, weight: 20.40, area: 26.00),
    '120': StandardProfileSpec(
        h: 120, b: 120, tw: 6.5, tf: 11.0, weight: 26.70, area: 34.00),
    '140': StandardProfileSpec(
        h: 140, b: 140, tw: 7.0, tf: 12.0, weight: 33.70, area: 43.00),
    '160': StandardProfileSpec(
        h: 160, b: 160, tw: 8.0, tf: 13.0, weight: 42.60, area: 54.30),
    '180': StandardProfileSpec(
        h: 180, b: 180, tw: 8.5, tf: 14.0, weight: 51.20, area: 65.30),
    '200': StandardProfileSpec(
        h: 200, b: 200, tw: 9.0, tf: 15.0, weight: 61.30, area: 78.10),
    '220': StandardProfileSpec(
        h: 220, b: 220, tw: 9.5, tf: 16.0, weight: 71.50, area: 91.00),
    '240': StandardProfileSpec(
        h: 240, b: 240, tw: 10.0, tf: 17.0, weight: 83.20, area: 106.00),
    '260': StandardProfileSpec(
        h: 260, b: 260, tw: 10.0, tf: 17.5, weight: 93.00, area: 118.40),
    '280': StandardProfileSpec(
        h: 280, b: 280, tw: 10.5, tf: 18.0, weight: 103.00, area: 131.20),
    '300': StandardProfileSpec(
        h: 300, b: 300, tw: 11.0, tf: 19.0, weight: 117.00, area: 149.10),
  };

  // Universal Beams (UB) - BS 4-1
  static const Map<String, StandardProfileSpec> ubBeams = {
    '127 x 76 x 13': StandardProfileSpec(
        h: 127.0, b: 76.0, tw: 4.0, tf: 7.6, weight: 13.00, area: 16.50),
    '152 x 89 x 16': StandardProfileSpec(
        h: 152.4, b: 88.7, tw: 4.5, tf: 7.7, weight: 16.00, area: 20.30),
    '178 x 102 x 19': StandardProfileSpec(
        h: 177.8, b: 101.2, tw: 4.8, tf: 7.9, weight: 19.00, area: 24.30),
    '203 x 102 x 23': StandardProfileSpec(
        h: 203.2, b: 101.8, tw: 5.4, tf: 9.3, weight: 23.10, area: 29.40),
    '203 x 133 x 25': StandardProfileSpec(
        h: 203.2, b: 133.2, tw: 5.7, tf: 7.8, weight: 25.10, area: 32.00),
    '203 x 133 x 30': StandardProfileSpec(
        h: 206.8, b: 133.9, tw: 6.4, tf: 9.6, weight: 30.00, area: 38.20),
    '254 x 102 x 22': StandardProfileSpec(
        h: 254.0, b: 101.6, tw: 5.7, tf: 6.8, weight: 22.00, area: 28.00),
    '254 x 102 x 25': StandardProfileSpec(
        h: 257.2, b: 101.9, tw: 6.0, tf: 8.4, weight: 25.20, area: 32.00),
    '254 x 102 x 28': StandardProfileSpec(
        h: 260.4, b: 102.2, tw: 6.3, tf: 10.0, weight: 28.30, area: 36.00),
    '254 x 146 x 31': StandardProfileSpec(
        h: 251.4, b: 146.1, tw: 6.0, tf: 8.6, weight: 31.10, area: 39.70),
    '254 x 146 x 37': StandardProfileSpec(
        h: 256.0, b: 146.4, tw: 6.3, tf: 10.9, weight: 37.00, area: 47.20),
    '254 x 146 x 43': StandardProfileSpec(
        h: 259.6, b: 147.3, tw: 7.2, tf: 12.7, weight: 43.00, area: 54.70),
    '305 x 102 x 25': StandardProfileSpec(
        h: 305.1, b: 101.6, tw: 5.8, tf: 7.0, weight: 24.80, area: 31.60),
    '305 x 102 x 28': StandardProfileSpec(
        h: 308.7, b: 101.8, tw: 6.0, tf: 8.8, weight: 28.20, area: 35.90),
    '305 x 102 x 33': StandardProfileSpec(
        h: 312.7, b: 102.4, tw: 6.6, tf: 10.8, weight: 32.80, area: 41.80),
    '305 x 127 x 37': StandardProfileSpec(
        h: 304.4, b: 123.4, tw: 7.1, tf: 10.7, weight: 37.00, area: 47.10),
    '305 x 127 x 42': StandardProfileSpec(
        h: 307.2, b: 124.3, tw: 8.0, tf: 12.1, weight: 41.90, area: 53.40),
    '305 x 165 x 40': StandardProfileSpec(
        h: 303.4, b: 165.0, tw: 6.0, tf: 10.2, weight: 40.30, area: 51.30),
    '305 x 165 x 46': StandardProfileSpec(
        h: 306.6, b: 165.7, tw: 6.7, tf: 11.8, weight: 46.10, area: 58.70),
    '305 x 165 x 54': StandardProfileSpec(
        h: 310.4, b: 166.9, tw: 7.9, tf: 13.7, weight: 54.00, area: 68.80),
    '356 x 127 x 33': StandardProfileSpec(
        h: 349.0, b: 125.4, tw: 6.0, tf: 8.5, weight: 33.10, area: 42.10),
    '356 x 127 x 39': StandardProfileSpec(
        h: 353.4, b: 126.0, tw: 6.6, tf: 10.7, weight: 39.10, area: 49.80),
    '356 x 171 x 45': StandardProfileSpec(
        h: 351.4, b: 171.1, tw: 7.0, tf: 9.7, weight: 45.00, area: 57.30),
    '356 x 171 x 51': StandardProfileSpec(
        h: 355.0, b: 171.5, tw: 7.4, tf: 11.5, weight: 51.00, area: 64.60),
    '356 x 171 x 57': StandardProfileSpec(
        h: 358.0, b: 172.2, tw: 8.1, tf: 13.0, weight: 57.00, area: 72.60),
    '356 x 171 x 67': StandardProfileSpec(
        h: 363.4, b: 173.2, tw: 9.1, tf: 15.7, weight: 67.10, area: 85.50),
    '406 x 140 x 39': StandardProfileSpec(
        h: 398.0, b: 141.8, tw: 6.4, tf: 8.6, weight: 39.00, area: 49.70),
    '406 x 140 x 46': StandardProfileSpec(
        h: 403.2, b: 142.2, tw: 6.8, tf: 11.2, weight: 46.00, area: 58.60),
    '406 x 178 x 54': StandardProfileSpec(
        h: 402.6, b: 177.7, tw: 7.7, tf: 10.9, weight: 54.10, area: 69.00),
    '406 x 178 x 60': StandardProfileSpec(
        h: 406.4, b: 177.9, tw: 7.9, tf: 12.8, weight: 60.10, area: 76.50),
    '406 x 178 x 67': StandardProfileSpec(
        h: 409.4, b: 178.8, tw: 8.8, tf: 14.3, weight: 67.10, area: 85.50),
    '406 x 178 x 74': StandardProfileSpec(
        h: 412.8, b: 179.5, tw: 9.5, tf: 16.0, weight: 74.20, area: 94.50),
    '457 x 152 x 52': StandardProfileSpec(
        h: 449.8, b: 152.4, tw: 7.6, tf: 10.9, weight: 52.30, area: 66.60),
    '457 x 152 x 60': StandardProfileSpec(
        h: 454.6, b: 152.9, tw: 8.1, tf: 13.3, weight: 59.80, area: 76.20),
    '457 x 152 x 67': StandardProfileSpec(
        h: 458.0, b: 153.8, tw: 9.0, tf: 15.0, weight: 67.20, area: 85.60),
    '457 x 152 x 74': StandardProfileSpec(
        h: 462.0, b: 154.4, tw: 9.6, tf: 17.0, weight: 74.20, area: 94.60),
    '457 x 152 x 82': StandardProfileSpec(
        h: 465.8, b: 155.3, tw: 10.5, tf: 18.9, weight: 82.10, area: 105.00),
    '457 x 191 x 67': StandardProfileSpec(
        h: 453.4, b: 189.9, tw: 8.5, tf: 12.7, weight: 67.10, area: 85.50),
    '457 x 191 x 74': StandardProfileSpec(
        h: 457.0, b: 190.4, tw: 9.0, tf: 14.5, weight: 74.30, area: 94.60),
    '457 x 191 x 82': StandardProfileSpec(
        h: 460.0, b: 191.3, tw: 9.9, tf: 16.0, weight: 82.00, area: 104.00),
    '457 x 191 x 89': StandardProfileSpec(
        h: 463.4, b: 191.9, tw: 10.5, tf: 17.7, weight: 89.30, area: 114.00),
    '457 x 191 x 98': StandardProfileSpec(
        h: 467.2, b: 192.8, tw: 11.4, tf: 19.6, weight: 98.30, area: 125.00),
    '533 x 210 x 82': StandardProfileSpec(
        h: 528.3, b: 208.8, tw: 9.6, tf: 13.2, weight: 82.20, area: 105.00),
    '533 x 210 x 92': StandardProfileSpec(
        h: 533.1, b: 209.3, tw: 10.1, tf: 15.6, weight: 92.10, area: 117.00),
    '533 x 210 x 101': StandardProfileSpec(
        h: 536.7, b: 210.0, tw: 10.8, tf: 17.4, weight: 101.00, area: 129.00),
    '533 x 210 x 109': StandardProfileSpec(
        h: 539.5, b: 210.7, tw: 11.6, tf: 18.8, weight: 109.00, area: 139.00),
    '533 x 210 x 122': StandardProfileSpec(
        h: 544.5, b: 211.9, tw: 12.7, tf: 21.3, weight: 122.00, area: 155.00),
    '610 x 229 x 101': StandardProfileSpec(
        h: 602.6, b: 227.6, tw: 10.5, tf: 14.8, weight: 101.20, area: 129.00),
    '610 x 229 x 113': StandardProfileSpec(
        h: 607.6, b: 228.2, tw: 11.1, tf: 17.3, weight: 113.00, area: 144.00),
    '610 x 229 x 125': StandardProfileSpec(
        h: 612.2, b: 229.0, tw: 11.9, tf: 19.6, weight: 125.10, area: 159.00),
    '610 x 229 x 140': StandardProfileSpec(
        h: 617.2, b: 230.2, tw: 13.1, tf: 22.1, weight: 139.90, area: 178.00),
    '610 x 305 x 149': StandardProfileSpec(
        h: 609.6, b: 304.8, tw: 11.9, tf: 19.7, weight: 149.10, area: 190.00),
    '610 x 305 x 179': StandardProfileSpec(
        h: 617.2, b: 307.0, tw: 14.1, tf: 23.6, weight: 179.00, area: 228.00),
    '610 x 305 x 238': StandardProfileSpec(
        h: 635.8, b: 311.4, tw: 18.4, tf: 31.4, weight: 238.10, area: 303.00),
    '686 x 254 x 125': StandardProfileSpec(
        h: 677.9, b: 253.0, tw: 11.7, tf: 16.2, weight: 125.20, area: 159.00),
    '686 x 254 x 140': StandardProfileSpec(
        h: 683.5, b: 253.7, tw: 12.4, tf: 19.0, weight: 140.10, area: 178.00),
    '686 x 254 x 152': StandardProfileSpec(
        h: 687.5, b: 254.5, tw: 13.2, tf: 21.0, weight: 152.40, area: 194.00),
    '686 x 254 x 170': StandardProfileSpec(
        h: 692.9, b: 255.8, tw: 14.5, tf: 23.7, weight: 170.20, area: 217.00),
    '762 x 267 x 134': StandardProfileSpec(
        h: 750.0, b: 264.4, tw: 12.0, tf: 15.5, weight: 133.90, area: 171.00),
    '762 x 267 x 147': StandardProfileSpec(
        h: 754.0, b: 265.2, tw: 12.8, tf: 17.5, weight: 146.90, area: 187.00),
    '762 x 267 x 173': StandardProfileSpec(
        h: 762.2, b: 266.7, tw: 14.3, tf: 21.6, weight: 173.00, area: 220.00),
    '762 x 267 x 197': StandardProfileSpec(
        h: 769.8, b: 268.0, tw: 15.6, tf: 25.4, weight: 196.80, area: 251.00),
    '838 x 292 x 176': StandardProfileSpec(
        h: 834.9, b: 291.7, tw: 14.0, tf: 18.8, weight: 175.90, area: 224.00),
    '838 x 292 x 194': StandardProfileSpec(
        h: 840.7, b: 292.4, tw: 14.7, tf: 21.7, weight: 193.80, area: 247.00),
    '838 x 292 x 226': StandardProfileSpec(
        h: 850.9, b: 293.8, tw: 16.1, tf: 26.8, weight: 226.50, area: 289.00),
    '914 x 305 x 201': StandardProfileSpec(
        h: 903.0, b: 303.3, tw: 15.1, tf: 20.2, weight: 200.90, area: 256.00),
    '914 x 305 x 224': StandardProfileSpec(
        h: 910.4, b: 304.1, tw: 15.9, tf: 23.9, weight: 224.20, area: 286.00),
    '914 x 305 x 253': StandardProfileSpec(
        h: 918.4, b: 305.5, tw: 17.3, tf: 27.9, weight: 253.40, area: 323.00),
    '914 x 305 x 289': StandardProfileSpec(
        h: 926.6, b: 307.7, tw: 19.5, tf: 32.0, weight: 289.10, area: 368.00),
    '914 x 419 x 343': StandardProfileSpec(
        h: 911.8, b: 418.5, tw: 19.4, tf: 32.0, weight: 343.30, area: 437.00),
    '914 x 419 x 388': StandardProfileSpec(
        h: 921.0, b: 420.5, tw: 21.4, tf: 36.6, weight: 388.00, area: 494.00),
  };

  // Universal Columns (UC) - BS 4-1
  static const Map<String, StandardProfileSpec> ucBeams = {
    '152 x 152 x 23': StandardProfileSpec(
        h: 152.4, b: 152.2, tw: 5.8, tf: 6.8, weight: 23.00, area: 29.20),
    '152 x 152 x 30': StandardProfileSpec(
        h: 157.6, b: 152.9, tw: 6.5, tf: 9.4, weight: 30.00, area: 38.20),
    '152 x 152 x 37': StandardProfileSpec(
        h: 161.8, b: 154.4, tw: 8.0, tf: 11.5, weight: 37.00, area: 47.10),
    '203 x 203 x 46': StandardProfileSpec(
        h: 203.2, b: 203.2, tw: 7.3, tf: 11.0, weight: 46.10, area: 58.70),
    '203 x 203 x 54': StandardProfileSpec(
        h: 206.2, b: 203.9, tw: 8.0, tf: 12.5, weight: 53.90, area: 68.60),
    '203 x 203 x 60': StandardProfileSpec(
        h: 209.6, b: 205.2, tw: 9.3, tf: 14.2, weight: 60.00, area: 76.40),
    '203 x 203 x 71': StandardProfileSpec(
        h: 215.8, b: 206.2, tw: 10.3, tf: 17.3, weight: 71.00, area: 90.40),
    '203 x 203 x 86': StandardProfileSpec(
        h: 222.2, b: 208.8, tw: 13.0, tf: 20.5, weight: 86.10, area: 110.00),
    '254 x 254 x 73': StandardProfileSpec(
        h: 254.1, b: 254.0, tw: 8.6, tf: 14.2, weight: 73.10, area: 93.10),
    '254 x 254 x 89': StandardProfileSpec(
        h: 260.3, b: 255.9, tw: 10.5, tf: 17.3, weight: 88.90, area: 113.00),
    '254 x 254 x 107': StandardProfileSpec(
        h: 266.7, b: 258.3, tw: 13.0, tf: 20.5, weight: 107.10, area: 136.00),
    '254 x 254 x 132': StandardProfileSpec(
        h: 276.4, b: 261.0, tw: 15.6, tf: 25.1, weight: 132.00, area: 168.00),
    '254 x 254 x 167': StandardProfileSpec(
        h: 289.1, b: 264.5, tw: 19.2, tf: 31.7, weight: 167.10, area: 213.00),
    '305 x 305 x 97': StandardProfileSpec(
        h: 307.9, b: 304.8, tw: 9.9, tf: 15.4, weight: 96.90, area: 123.00),
    '305 x 305 x 118': StandardProfileSpec(
        h: 314.5, b: 306.8, tw: 11.9, tf: 18.7, weight: 117.90, area: 150.00),
    '305 x 305 x 137': StandardProfileSpec(
        h: 320.5, b: 308.7, tw: 13.8, tf: 21.7, weight: 136.90, area: 174.00),
    '305 x 305 x 158': StandardProfileSpec(
        h: 327.2, b: 310.6, tw: 15.7, tf: 25.0, weight: 158.10, area: 201.00),
    '305 x 305 x 198': StandardProfileSpec(
        h: 339.9, b: 314.1, tw: 19.2, tf: 31.4, weight: 198.10, area: 252.00),
    '305 x 305 x 240': StandardProfileSpec(
        h: 352.6, b: 317.9, tw: 23.0, tf: 37.7, weight: 240.00, area: 306.00),
    '305 x 305 x 283': StandardProfileSpec(
        h: 365.3, b: 321.8, tw: 26.9, tf: 44.1, weight: 283.00, area: 360.00),
    '356 x 368 x 129': StandardProfileSpec(
        h: 355.6, b: 368.6, tw: 10.4, tf: 17.5, weight: 129.00, area: 164.00),
    '356 x 368 x 153': StandardProfileSpec(
        h: 362.0, b: 370.5, tw: 12.3, tf: 20.7, weight: 152.90, area: 195.00),
    '356 x 368 x 177': StandardProfileSpec(
        h: 368.2, b: 372.6, tw: 14.4, tf: 23.8, weight: 177.00, area: 226.00),
    '356 x 368 x 202': StandardProfileSpec(
        h: 374.6, b: 374.7, tw: 16.5, tf: 27.0, weight: 201.90, area: 257.00),
    '356 x 406 x 235': StandardProfileSpec(
        h: 381.0, b: 394.8, tw: 18.4, tf: 30.2, weight: 235.10, area: 300.00),
    '356 x 406 x 287': StandardProfileSpec(
        h: 393.6, b: 399.0, tw: 22.6, tf: 36.5, weight: 287.10, area: 366.00),
    '356 x 406 x 340': StandardProfileSpec(
        h: 406.4, b: 403.0, tw: 26.6, tf: 42.9, weight: 339.90, area: 433.00),
    '356 x 406 x 393': StandardProfileSpec(
        h: 419.0, b: 407.0, tw: 30.6, tf: 49.2, weight: 393.00, area: 501.00),
    '356 x 406 x 467': StandardProfileSpec(
        h: 436.6, b: 412.2, tw: 35.8, tf: 58.0, weight: 467.00, area: 595.00),
    '356 x 406 x 551': StandardProfileSpec(
        h: 455.6, b: 418.5, tw: 42.1, tf: 67.5, weight: 551.00, area: 702.00),
    '356 x 406 x 634': StandardProfileSpec(
        h: 474.6, b: 424.0, tw: 47.6, tf: 77.0, weight: 633.90, area: 808.00),
  };

  // ASTM A6 / Commercial W-Beams (Wide Flange) - Total: 166 standard sizes
  static const Map<String, StandardProfileSpec> wBeams = {
    'W 8 x 8 x 31 (203 x 203 x 46.1)': StandardProfileSpec(
        h: 203.0, b: 203.0, tw: 7.2, tf: 11.0, weight: 46.1, area: 58.73),
    'W 8 x 8 x 35 (203 x 203 x 52)': StandardProfileSpec(
        h: 206.0, b: 204.0, tw: 7.9, tf: 12.6, weight: 52.0, area: 66.24),
    'W 8 x 8 x 40 (203 x 203 x 59)': StandardProfileSpec(
        h: 210.0, b: 205.0, tw: 9.1, tf: 14.2, weight: 59.0, area: 75.16),
    'W 8 x 8 x 48 (203 x 203 x 71)': StandardProfileSpec(
        h: 216.0, b: 206.0, tw: 10.2, tf: 17.4, weight: 71.0, area: 90.45),
    'W 8 x 8 x 58 (203 x 203 x 86)': StandardProfileSpec(
        h: 222.0, b: 209.0, tw: 13.0, tf: 20.6, weight: 86.0, area: 109.55),
    'W 8 x 8 x 67 (203 x 203 x 100)': StandardProfileSpec(
        h: 229.0, b: 210.0, tw: 14.5, tf: 23.7, weight: 100.0, area: 127.39),
    'W 10 x 5.75 x 22 (254 x 146 x 32.7)': StandardProfileSpec(
        h: 258.0, b: 146.0, tw: 6.1, tf: 9.1, weight: 32.7, area: 41.66),
    'W 10 x 5.75 x 26 (254 x 146 x 38.5)': StandardProfileSpec(
        h: 262.0, b: 147.0, tw: 6.6, tf: 11.2, weight: 38.5, area: 49.04),
    'W 10 x 5.75 x 30 (254 x 146 x 44.8)': StandardProfileSpec(
        h: 266.0, b: 148.0, tw: 7.6, tf: 13.0, weight: 44.8, area: 57.07),
    'W 10 x 8 x 33 (254 x 203 x 49.1)': StandardProfileSpec(
        h: 247.0, b: 202.0, tw: 7.4, tf: 11.0, weight: 49.1, area: 62.55),
    'W 10 x 8 x 39 (254 x 203 x 58)': StandardProfileSpec(
        h: 252.0, b: 203.0, tw: 8.0, tf: 13.5, weight: 58.0, area: 73.89),
    'W 10 x 8 x 45 (254 x 203 x 67)': StandardProfileSpec(
        h: 257.0, b: 204.0, tw: 8.9, tf: 15.7, weight: 67.0, area: 85.35),
    'W 10 x 10 x 49 (254 x 254 x 73)': StandardProfileSpec(
        h: 253.0, b: 254.0, tw: 8.6, tf: 14.2, weight: 73.0, area: 92.99),
    'W 10 x 10 x 54 (254 x 254 x 80)': StandardProfileSpec(
        h: 256.0, b: 255.0, tw: 9.4, tf: 15.6, weight: 80.0, area: 101.91),
    'W 10 x 10 x 60 (254 x 254 x 89)': StandardProfileSpec(
        h: 260.0, b: 256.0, tw: 10.7, tf: 17.3, weight: 89.0, area: 113.38),
    'W 10 x 10 x 68 (254 x 254 x 101)': StandardProfileSpec(
        h: 264.0, b: 257.0, tw: 11.9, tf: 19.6, weight: 101.0, area: 128.66),
    'W 10 x 10 x 77 (254 x 254 x 115)': StandardProfileSpec(
        h: 269.0, b: 259.0, tw: 13.5, tf: 22.1, weight: 115.0, area: 146.5),
    'W 10 x 10 x 88 (254 x 254 x 131)': StandardProfileSpec(
        h: 275.0, b: 261.0, tw: 15.4, tf: 25.1, weight: 131.0, area: 166.88),
    'W 10 x 10 x 100 (254 x 254 x 149)': StandardProfileSpec(
        h: 282.0, b: 263.0, tw: 17.3, tf: 28.4, weight: 149.0, area: 189.81),
    'W 10 x 10 x 112 (254 x 254 x 167)': StandardProfileSpec(
        h: 289.0, b: 265.0, tw: 19.2, tf: 31.8, weight: 167.0, area: 212.74),
    'W 12 x 6.5 x 26 (305 x 165 x 38.7)': StandardProfileSpec(
        h: 310.0, b: 165.0, tw: 5.8, tf: 9.7, weight: 38.7, area: 49.3),
    'W 12 x 6.5 x 30 (305 x 165 x 44.5)': StandardProfileSpec(
        h: 313.0, b: 166.0, tw: 6.6, tf: 11.2, weight: 44.5, area: 56.69),
    'W 12 x 6.5 x 35 (305 x 165 x 52)': StandardProfileSpec(
        h: 317.0, b: 167.0, tw: 7.6, tf: 13.2, weight: 52.0, area: 66.24),
    'W 12 x 8 x 40 (305 x 203 x 60)': StandardProfileSpec(
        h: 303.0, b: 203.0, tw: 7.5, tf: 13.1, weight: 60.0, area: 76.43),
    'W 12 x 8 x 45 (305 x 203 x 67)': StandardProfileSpec(
        h: 306.0, b: 204.0, tw: 8.5, tf: 14.6, weight: 67.0, area: 85.35),
    'W 12 x 8 x 50 (305 x 203 x 74)': StandardProfileSpec(
        h: 310.0, b: 205.0, tw: 9.4, tf: 16.3, weight: 74.0, area: 94.27),
    'W 12 x 10 x 53 (305 x 254 x 79)': StandardProfileSpec(
        h: 306.0, b: 254.0, tw: 8.8, tf: 14.6, weight: 79.0, area: 100.64),
    'W 12 x 10 x 58 (305 x 254 x 86)': StandardProfileSpec(
        h: 310.0, b: 254.0, tw: 9.1, tf: 16.3, weight: 86.0, area: 109.55),
    'W 12 x 12 x 65 (305 x 305 x 97)': StandardProfileSpec(
        h: 308.0, b: 305.0, tw: 9.9, tf: 15.4, weight: 97.0, area: 123.57),
    'W 12 x 12 x 72 (305 x 305 x 107)': StandardProfileSpec(
        h: 311.0, b: 306.0, tw: 10.9, tf: 17.0, weight: 107.0, area: 136.31),
    'W 12 x 12 x 79 (305 x 305 x 117)': StandardProfileSpec(
        h: 314.0, b: 307.0, tw: 11.9, tf: 18.7, weight: 117.0, area: 149.04),
    'W 12 x 12 x 87 (305 x 305 x 129)': StandardProfileSpec(
        h: 318.0, b: 308.0, tw: 13.1, tf: 20.6, weight: 129.0, area: 164.33),
    'W 12 x 12 x 96 (305 x 305 x 143)': StandardProfileSpec(
        h: 323.0, b: 309.0, tw: 14.0, tf: 22.9, weight: 143.0, area: 182.17),
    'W 12 x 12 x 106 (305 x 305 x 158)': StandardProfileSpec(
        h: 327.0, b: 310.0, tw: 15.5, tf: 25.1, weight: 158.0, area: 201.27),
    'W 12 x 12 x 120 (305 x 305 x 179)': StandardProfileSpec(
        h: 333.0, b: 313.0, tw: 18.0, tf: 28.1, weight: 179.0, area: 228.03),
    'W 12 x 12 x 136 (305 x 305 x 202)': StandardProfileSpec(
        h: 341.0, b: 315.0, tw: 20.1, tf: 31.8, weight: 202.0, area: 257.32),
    'W 12 x 12 x 152 (305 x 305 x 226)': StandardProfileSpec(
        h: 348.0, b: 317.0, tw: 22.1, tf: 35.6, weight: 226.0, area: 287.9),
    'W 12 x 12 x 170 (305 x 305 x 253)': StandardProfileSpec(
        h: 356.0, b: 319.0, tw: 24.4, tf: 39.6, weight: 253.0, area: 322.29),
    'W 12 x 12 x 190 (305 x 305 x 283)': StandardProfileSpec(
        h: 365.0, b: 322.0, tw: 26.9, tf: 44.1, weight: 283.0, area: 360.51),
    'W 12 x 12 x 210 (305 x 305 x 313)': StandardProfileSpec(
        h: 374.0, b: 325.0, tw: 30.0, tf: 48.3, weight: 313.0, area: 398.73),
    'W 12 x 12 x 230 (305 x 305 x 342)': StandardProfileSpec(
        h: 382.0, b: 328.0, tw: 32.6, tf: 52.6, weight: 342.0, area: 435.67),
    'W 14 x 5 x 22 (356 x 127 x 32.9)': StandardProfileSpec(
        h: 349.0, b: 127.0, tw: 5.8, tf: 8.5, weight: 32.9, area: 41.91),
    'W 14 x 5 x 26 (356 x 127 x 39.0)': StandardProfileSpec(
        h: 353.0, b: 128.0, tw: 6.5, tf: 10.7, weight: 39.0, area: 49.68),
    'W 14 x 6.75 x 30 (356 x 171 x 44.6)': StandardProfileSpec(
        h: 352.0, b: 171.0, tw: 6.9, tf: 9.8, weight: 44.6, area: 56.82),
    'W 14 x 6.75 x 34 (356 x 171 x 51)': StandardProfileSpec(
        h: 355.0, b: 171.0, tw: 7.2, tf: 11.6, weight: 51.0, area: 64.97),
    'W 14 x 6.75 x 38 (356 x 171 x 58)': StandardProfileSpec(
        h: 358.0, b: 172.0, tw: 7.9, tf: 13.1, weight: 58.0, area: 73.89),
    'W 14 x 8 x 43 (356 x 203 x 64)': StandardProfileSpec(
        h: 347.0, b: 203.0, tw: 7.7, tf: 13.5, weight: 64.0, area: 81.53),
    'W 14 x 8 x 48 (356 x 203 x 72)': StandardProfileSpec(
        h: 350.0, b: 204.0, tw: 8.6, tf: 15.1, weight: 72.0, area: 91.72),
    'W 14 x 8 x 53 (356 x 203 x 79)': StandardProfileSpec(
        h: 354.0, b: 205.0, tw: 9.4, tf: 16.8, weight: 79.0, area: 100.64),
    'W 14 x 10 x 61 (356 x 254 x 91)': StandardProfileSpec(
        h: 353.0, b: 254.0, tw: 9.5, tf: 16.4, weight: 91.0, area: 115.92),
    'W 14 x 10 x 68 (356 x 254 x 101)': StandardProfileSpec(
        h: 357.0, b: 255.0, tw: 10.5, tf: 18.3, weight: 101.0, area: 128.66),
    'W 14 x 10 x 74 (356 x 254 x 110)': StandardProfileSpec(
        h: 360.0, b: 256.0, tw: 11.4, tf: 19.9, weight: 110.0, area: 140.13),
    'W 14 x 10 x 82 (356 x 254 x 122)': StandardProfileSpec(
        h: 363.0, b: 257.0, tw: 13.0, tf: 21.7, weight: 122.0, area: 155.41),
    'W 14 x 14.5 x 90 (356 x 368 x 134)': StandardProfileSpec(
        h: 356.0, b: 369.0, tw: 11.2, tf: 18.0, weight: 134.0, area: 170.7),
    'W 14 x 14.5 x 99 (356 x 368 x 147)': StandardProfileSpec(
        h: 360.0, b: 370.0, tw: 12.3, tf: 19.8, weight: 147.0, area: 187.26),
    'W 14 x 14.5 x 109 (356 x 368 x 162)': StandardProfileSpec(
        h: 364.0, b: 371.0, tw: 13.3, tf: 21.8, weight: 162.0, area: 206.37),
    'W 14 x 14.5 x 120 (356 x 368 x 179)': StandardProfileSpec(
        h: 368.0, b: 373.0, tw: 15.0, tf: 23.9, weight: 179.0, area: 228.03),
    'W 14 x 14.5 x 132 (356 x 368 x 196)': StandardProfileSpec(
        h: 372.0, b: 374.0, tw: 16.4, tf: 26.2, weight: 196.0, area: 249.68),
    'W 14 x 16 x 145 (356 x 406 x 216)': StandardProfileSpec(
        h: 375.0, b: 394.0, tw: 17.3, tf: 27.7, weight: 216.0, area: 275.16),
    'W 14 x 16 x 159 (356 x 406 x 237)': StandardProfileSpec(
        h: 380.0, b: 395.0, tw: 18.9, tf: 30.2, weight: 237.0, area: 301.91),
    'W 14 x 16 x 176 (356 x 406 x 262)': StandardProfileSpec(
        h: 387.0, b: 398.0, tw: 21.1, tf: 33.3, weight: 262.0, area: 333.76),
    'W 14 x 16 x 193 (356 x 406 x 287)': StandardProfileSpec(
        h: 393.0, b: 399.0, tw: 22.6, tf: 36.6, weight: 287.0, area: 365.61),
    'W 14 x 16 x 211 (356 x 406 x 314)': StandardProfileSpec(
        h: 399.0, b: 401.0, tw: 24.9, tf: 39.6, weight: 314.0, area: 400.0),
    'W 14 x 16 x 233 (356 x 406 x 347)': StandardProfileSpec(
        h: 407.0, b: 404.0, tw: 27.2, tf: 43.7, weight: 347.0, area: 442.04),
    'W 14 x 16 x 257 (356 x 406 x 382)': StandardProfileSpec(
        h: 416.0, b: 406.0, tw: 29.8, tf: 48.0, weight: 382.0, area: 486.62),
    'W 14 x 16 x 283 (356 x 406 x 421)': StandardProfileSpec(
        h: 425.0, b: 409.0, tw: 32.8, tf: 52.6, weight: 421.0, area: 536.31),
    'W 14 x 16 x 311 (356 x 406 x 463)': StandardProfileSpec(
        h: 435.0, b: 412.0, tw: 35.8, tf: 57.4, weight: 463.0, area: 589.81),
    'W 14 x 16 x 342 (356 x 406 x 509)': StandardProfileSpec(
        h: 446.0, b: 416.0, tw: 39.1, tf: 62.7, weight: 509.0, area: 648.41),
    'W 14 x 16 x 370 (356 x 406 x 551)': StandardProfileSpec(
        h: 455.0, b: 418.0, tw: 42.0, tf: 67.6, weight: 551.0, area: 701.91),
    'W 14 x 16 x 398 (356 x 406 x 592)': StandardProfileSpec(
        h: 465.0, b: 421.0, tw: 45.0, tf: 72.3, weight: 592.0, area: 754.14),
    'W 14 x 16 x 426 (356 x 406 x 634)': StandardProfileSpec(
        h: 474.0, b: 424.0, tw: 47.6, tf: 77.1, weight: 634.0, area: 807.64),
    'W 16 x 5.5 x 26 (406 x 140 x 38.8)': StandardProfileSpec(
        h: 399.0, b: 140.0, tw: 6.4, tf: 8.8, weight: 38.8, area: 49.43),
    'W 16 x 5.5 x 31 (406 x 140 x 46.1)': StandardProfileSpec(
        h: 403.0, b: 140.0, tw: 7.0, tf: 11.2, weight: 46.1, area: 58.73),
    'W 16 x 7 x 36 (406 x 178 x 53)': StandardProfileSpec(
        h: 403.0, b: 177.0, tw: 7.5, tf: 10.9, weight: 53.0, area: 67.52),
    'W 16 x 7 x 40 (406 x 178 x 60)': StandardProfileSpec(
        h: 407.0, b: 178.0, tw: 7.7, tf: 12.8, weight: 60.0, area: 76.43),
    'W 16 x 7 x 45 (406 x 178 x 67)': StandardProfileSpec(
        h: 410.0, b: 179.0, tw: 8.8, tf: 14.4, weight: 67.0, area: 85.35),
    'W 16 x 7 x 50 (406 x 178 x 75)': StandardProfileSpec(
        h: 413.0, b: 180.0, tw: 9.7, tf: 16.0, weight: 75.0, area: 95.54),
    'W 16 x 7 x 57 (406 x 178 x 85)': StandardProfileSpec(
        h: 417.0, b: 181.0, tw: 10.9, tf: 18.2, weight: 85.0, area: 108.28),
    'W 16 x 10.25 x 67 (406 x 260 x 100)': StandardProfileSpec(
        h: 415.0, b: 260.0, tw: 10.0, tf: 16.9, weight: 100.0, area: 127.39),
    'W 16 x 10.25 x 77 (406 x 260 x 114)': StandardProfileSpec(
        h: 420.0, b: 261.0, tw: 11.6, tf: 19.3, weight: 114.0, area: 145.22),
    'W 16 x 10.25 x 89 (406 x 260 x 132)': StandardProfileSpec(
        h: 425.0, b: 263.0, tw: 13.3, tf: 22.2, weight: 132.0, area: 168.15),
    'W 16 x 10.25 x 100 (406 x 260 x 149)': StandardProfileSpec(
        h: 431.0, b: 265.0, tw: 14.9, tf: 25.0, weight: 149.0, area: 189.81),
    'W 18 x 6 x 35 (457 x 152 x 52)': StandardProfileSpec(
        h: 450.0, b: 152.0, tw: 7.6, tf: 10.8, weight: 52.0, area: 66.24),
    'W 18 x 6 x 40 (457 x 152 x 60)': StandardProfileSpec(
        h: 455.0, b: 153.0, tw: 8.0, tf: 13.3, weight: 60.0, area: 76.43),
    'W 18 x 6 x 46 (457 x 152 x 68)': StandardProfileSpec(
        h: 459.0, b: 154.0, tw: 9.1, tf: 15.4, weight: 68.0, area: 86.62),
    'W 18 x 7.5 x 50 (457 x 191 x 74)': StandardProfileSpec(
        h: 457.0, b: 190.0, tw: 9.0, tf: 14.5, weight: 74.0, area: 94.27),
    'W 18 x 7.5 x 55 (457 x 191 x 82)': StandardProfileSpec(
        h: 460.0, b: 191.0, tw: 9.9, tf: 16.0, weight: 82.0, area: 104.46),
    'W 18 x 7.5 x 60 (457 x 191 x 89)': StandardProfileSpec(
        h: 463.0, b: 192.0, tw: 10.5, tf: 17.7, weight: 89.0, area: 113.38),
    'W 18 x 7.5 x 65 (457 x 191 x 97)': StandardProfileSpec(
        h: 466.0, b: 193.0, tw: 11.4, tf: 19.0, weight: 97.0, area: 123.57),
    'W 18 x 7.5 x 71 (457 x 191 x 106)': StandardProfileSpec(
        h: 469.0, b: 194.0, tw: 12.6, tf: 20.6, weight: 106.0, area: 135.03),
    'W 18 x 11 x 76 (457 x 280 x 113)': StandardProfileSpec(
        h: 463.0, b: 280.0, tw: 10.8, tf: 17.3, weight: 113.0, area: 143.95),
    'W 18 x 11 x 86 (457 x 280 x 128)': StandardProfileSpec(
        h: 467.0, b: 282.0, tw: 12.2, tf: 19.6, weight: 128.0, area: 163.06),
    'W 18 x 11 x 97 (457 x 280 x 144)': StandardProfileSpec(
        h: 472.0, b: 283.0, tw: 13.6, tf: 22.1, weight: 144.0, area: 183.44),
    'W 18 x 11 x 106 (457 x 280 x 158)': StandardProfileSpec(
        h: 476.0, b: 284.0, tw: 15.0, tf: 23.9, weight: 158.0, area: 201.27),
    'W 18 x 11 x 119 (457 x 280 x 177)': StandardProfileSpec(
        h: 482.0, b: 286.0, tw: 16.6, tf: 26.9, weight: 177.0, area: 225.48),
    'W 18 x 11 x 130 (457 x 280 x 193)': StandardProfileSpec(
        h: 489.0, b: 283.0, tw: 17.0, tf: 30.5, weight: 193.0, area: 245.86),
    'W 18 x 11 x 143 (457 x 280 x 213)': StandardProfileSpec(
        h: 495.0, b: 285.0, tw: 18.5, tf: 33.5, weight: 213.0, area: 271.34),
    'W 18 x 11 x 158 (457 x 280 x 235)': StandardProfileSpec(
        h: 501.0, b: 287.0, tw: 20.6, tf: 36.6, weight: 235.0, area: 299.36),
    'W 18 x 11 x 175 (457 x 280 x 260)': StandardProfileSpec(
        h: 509.0, b: 289.0, tw: 22.6, tf: 40.4, weight: 260.0, area: 331.21),
    'W 21 x 6.5 x 44 (533 x 165 x 66)': StandardProfileSpec(
        h: 525.0, b: 165.0, tw: 8.9, tf: 11.4, weight: 66.0, area: 84.08),
    'W 21 x 6.5 x 50 (533 x 165 x 74)': StandardProfileSpec(
        h: 529.0, b: 166.0, tw: 9.7, tf: 13.6, weight: 74.0, area: 94.27),
    'W 21 x 6.5 x 57 (533 x 165 x 85)': StandardProfileSpec(
        h: 535.0, b: 166.0, tw: 10.3, tf: 16.5, weight: 85.0, area: 108.28),
    'W 21 x 8.25 x 62 (533 x 210 x 92)': StandardProfileSpec(
        h: 533.0, b: 209.0, tw: 10.2, tf: 15.6, weight: 92.0, area: 117.2),
    'W 21 x 8.25 x 68 (533 x 210 x 101)': StandardProfileSpec(
        h: 537.0, b: 210.0, tw: 10.9, tf: 17.4, weight: 101.0, area: 128.66),
    'W 21 x 8.25 x 73 (533 x 210 x 109)': StandardProfileSpec(
        h: 539.0, b: 211.0, tw: 11.6, tf: 18.8, weight: 109.0, area: 138.85),
    'W 21 x 8.25 x 83 (533 x 210 x 123)': StandardProfileSpec(
        h: 544.0, b: 212.0, tw: 13.1, tf: 21.2, weight: 123.0, area: 156.69),
    'W 21 x 8.25 x 93 (533 x 210 x 138)': StandardProfileSpec(
        h: 549.0, b: 214.0, tw: 14.7, tf: 23.6, weight: 138.0, area: 175.8),
    'W 24 x 7 x 55 (610 x 178 x 82)': StandardProfileSpec(
        h: 599.0, b: 178.0, tw: 10.0, tf: 12.8, weight: 82.0, area: 104.46),
    'W 24 x 7 x 62 (610 x 178 x 92)': StandardProfileSpec(
        h: 603.0, b: 179.0, tw: 10.9, tf: 15.0, weight: 92.0, area: 117.2),
    'W 24 x 9 x 68 (610 x 229 x 101)': StandardProfileSpec(
        h: 603.0, b: 228.0, tw: 10.5, tf: 14.9, weight: 101.0, area: 128.66),
    'W 24 x 9 x 76 (610 x 229 x 113)': StandardProfileSpec(
        h: 608.0, b: 228.0, tw: 11.2, tf: 17.3, weight: 113.0, area: 143.95),
    'W 24 x 9 x 84 (610 x 229 x 125)': StandardProfileSpec(
        h: 612.0, b: 229.0, tw: 11.9, tf: 19.6, weight: 125.0, area: 159.24),
    'W 24 x 9 x 94 (610 x 229 x 140)': StandardProfileSpec(
        h: 617.0, b: 230.0, tw: 13.1, tf: 22.2, weight: 140.0, area: 178.34),
    'W 24 x 9 x 103 (610 x 229 x 153)': StandardProfileSpec(
        h: 623.0, b: 229.0, tw: 14.0, tf: 24.9, weight: 153.0, area: 194.9),
    'W 24 x 12.75 x 104 (610 x 324 x 155)': StandardProfileSpec(
        h: 611.0, b: 324.0, tw: 12.7, tf: 19.0, weight: 155.0, area: 197.45),
    'W 24 x 12.75 x 117 (610 x 324 x 174)': StandardProfileSpec(
        h: 616.0, b: 325.0, tw: 14.0, tf: 21.6, weight: 174.0, area: 221.66),
    'W 24 x 12.75 x 131 (610 x 324 x 195)': StandardProfileSpec(
        h: 622.0, b: 327.0, tw: 15.4, tf: 24.4, weight: 195.0, area: 248.41),
    'W 24 x 12.75 x 146 (610 x 324 x 217)': StandardProfileSpec(
        h: 628.0, b: 328.0, tw: 16.5, tf: 27.7, weight: 217.0, area: 276.43),
    'W 24 x 12.75 x 162 (610 x 324 x 241)': StandardProfileSpec(
        h: 635.0, b: 329.0, tw: 17.9, tf: 31.0, weight: 241.0, area: 307.01),
    'W 24 x 12.75 x 176 (610 x 324 x 262)': StandardProfileSpec(
        h: 641.0, b: 327.0, tw: 19.0, tf: 34.0, weight: 262.0, area: 333.76),
    'W 24 x 12.75 x 192 (610 x 324 x 285)': StandardProfileSpec(
        h: 647.0, b: 329.0, tw: 20.6, tf: 37.1, weight: 285.0, area: 363.06),
    'W 24 x 12.75 x 229 (610 x 324 x 341)': StandardProfileSpec(
        h: 661.0, b: 333.0, tw: 24.4, tf: 43.9, weight: 341.0, area: 434.39),
    'W 27 x 10 x 84 (686 x 254 x 125)': StandardProfileSpec(
        h: 678.0, b: 253.0, tw: 11.7, tf: 16.3, weight: 125.0, area: 159.24),
    'W 27 x 10 x 94 (686 x 254 x 140)': StandardProfileSpec(
        h: 684.0, b: 254.0, tw: 12.4, tf: 18.9, weight: 140.0, area: 178.34),
    'W 27 x 10 x 102 (686 x 254 x 152)': StandardProfileSpec(
        h: 688.0, b: 254.0, tw: 13.1, tf: 21.1, weight: 152.0, area: 193.63),
    'W 27 x 10 x 114 (686 x 254 x 170)': StandardProfileSpec(
        h: 693.0, b: 256.0, tw: 14.5, tf: 23.6, weight: 170.0, area: 216.56),
    'W 27 x 10 x 129 (686 x 254 x 192)': StandardProfileSpec(
        h: 702.0, b: 254.0, tw: 15.5, tf: 27.9, weight: 192.0, area: 244.59),
    'W 30 x 10.5 x 99 (762 x 267 x 147)': StandardProfileSpec(
        h: 753.0, b: 265.0, tw: 13.2, tf: 17.0, weight: 147.0, area: 187.26),
    'W 30 x 10.5 x 108 (762 x 267 x 161)': StandardProfileSpec(
        h: 758.0, b: 266.0, tw: 13.8, tf: 19.3, weight: 161.0, area: 205.1),
    'W 30 x 10.5 x 116 (762 x 267 x 173)': StandardProfileSpec(
        h: 762.0, b: 267.0, tw: 14.4, tf: 21.6, weight: 173.0, area: 220.38),
    'W 30 x 10.5 x 124 (762 x 267 x 185)': StandardProfileSpec(
        h: 766.0, b: 267.0, tw: 14.9, tf: 23.6, weight: 185.0, area: 235.67),
    'W 30 x 10.5 x 132 (762 x 267 x 196)': StandardProfileSpec(
        h: 770.0, b: 268.0, tw: 15.6, tf: 25.4, weight: 196.0, area: 249.68),
    'W 30 x 10.5 x 148 (762 x 267 x 220)': StandardProfileSpec(
        h: 779.0, b: 266.0, tw: 16.5, tf: 30.0, weight: 220.0, area: 280.25),
    'W 33 x 11.5 x 118 (838 x 292 x 176)': StandardProfileSpec(
        h: 835.0, b: 292.0, tw: 14.0, tf: 18.8, weight: 176.0, area: 224.2),
    'W 33 x 11.5 x 130 (838 x 292 x 193)': StandardProfileSpec(
        h: 840.0, b: 292.0, tw: 14.7, tf: 21.7, weight: 193.0, area: 245.86),
    'W 33 x 11.5 x 141 (838 x 292 x 210)': StandardProfileSpec(
        h: 846.0, b: 293.0, tw: 15.4, tf: 24.4, weight: 210.0, area: 267.52),
    'W 33 x 11.5 x 152 (838 x 292 x 226)': StandardProfileSpec(
        h: 851.0, b: 294.0, tw: 16.1, tf: 26.8, weight: 226.0, area: 287.9),
    'W 33 x 11.5 x 169 (838 x 292 x 251)': StandardProfileSpec(
        h: 859.0, b: 292.0, tw: 17.0, tf: 31.0, weight: 251.0, area: 319.75),
    'W 36 x 12 x 135 (914 x 305 x 201)': StandardProfileSpec(
        h: 903.0, b: 304.0, tw: 15.2, tf: 20.1, weight: 201.0, area: 256.05),
    'W 36 x 12 x 150 (914 x 305 x 223)': StandardProfileSpec(
        h: 911.0, b: 304.0, tw: 15.9, tf: 23.9, weight: 223.0, area: 284.08),
    'W 36 x 12 x 160 (914 x 305 x 238)': StandardProfileSpec(
        h: 915.0, b: 305.0, tw: 16.5, tf: 25.9, weight: 238.0, area: 303.18),
    'W 36 x 12 x 170 (914 x 305 x 253)': StandardProfileSpec(
        h: 919.0, b: 306.0, tw: 17.3, tf: 27.9, weight: 253.0, area: 322.29),
    'W 36 x 12 x 182 (914 x 305 x 271)': StandardProfileSpec(
        h: 923.0, b: 307.0, tw: 18.4, tf: 30.0, weight: 271.0, area: 345.22),
    'W 36 x 12 x 194 (914 x 305 x 289)': StandardProfileSpec(
        h: 927.0, b: 308.0, tw: 19.4, tf: 32.0, weight: 289.0, area: 368.15),
    'W 36 x 12 x 210 (914 x 305 x 313)': StandardProfileSpec(
        h: 932.0, b: 309.0, tw: 21.1, tf: 34.5, weight: 313.0, area: 398.73),
    'W 36 x 16.5 x 230 (914 x 419 x 342)': StandardProfileSpec(
        h: 912.0, b: 418.0, tw: 19.3, tf: 32.0, weight: 342.0, area: 435.67),
    'W 36 x 16.5 x 245 (914 x 419 x 365)': StandardProfileSpec(
        h: 916.0, b: 419.0, tw: 20.3, tf: 34.3, weight: 365.0, area: 464.97),
    'W 36 x 16.5 x 260 (914 x 419 x 387)': StandardProfileSpec(
        h: 921.0, b: 420.0, tw: 21.3, tf: 36.6, weight: 387.0, area: 492.99),
    'W 36 x 16.5 x 280 (914 x 419 x 417)': StandardProfileSpec(
        h: 928.0, b: 422.0, tw: 22.5, tf: 39.9, weight: 417.0, area: 531.21),
    'W 36 x 16.5 x 300 (914 x 419 x 446)': StandardProfileSpec(
        h: 933.0, b: 423.0, tw: 24.0, tf: 42.7, weight: 446.0, area: 568.15),
    'W 36 x 16.5 x 328 (914 x 419 x 488)': StandardProfileSpec(
        h: 942.0, b: 422.0, tw: 25.9, tf: 47.0, weight: 488.0, area: 621.66),
    'W 36 x 16.5 x 231 (914 x 419 x 344)': StandardProfileSpec(
        h: 927.0, b: 418.0, tw: 19.3, tf: 32.0, weight: 344.0, area: 438.22),
    'W 36 x 16.5 x 247 (914 x 419 x 368)': StandardProfileSpec(
        h: 931.0, b: 419.0, tw: 20.3, tf: 34.3, weight: 368.0, area: 468.79),
    'W 36 x 16.5 x 262 (914 x 419 x 390)': StandardProfileSpec(
        h: 936.0, b: 420.0, tw: 21.3, tf: 36.6, weight: 390.0, area: 496.82),
    'W 36 x 16.5 x 282 (914 x 419 x 419)': StandardProfileSpec(
        h: 943.0, b: 422.0, tw: 22.5, tf: 39.9, weight: 419.0, area: 533.76),
    'W 36 x 16.5 x 302 (914 x 419 x 449)': StandardProfileSpec(
        h: 948.0, b: 423.0, tw: 24.0, tf: 42.7, weight: 449.0, area: 571.97),
    'W 36 x 16.5 x 330 (914 x 419 x 491)': StandardProfileSpec(
        h: 957.0, b: 422.0, tw: 25.9, tf: 47.0, weight: 491.0, area: 625.48),
    'W 40 x 12 x 149 (1016 x 305 x 222)': StandardProfileSpec(
        h: 970.0, b: 300.0, tw: 16.0, tf: 21.1, weight: 222.0, area: 282.8),
    'W 40 x 12 x 167 (1016 x 305 x 249)': StandardProfileSpec(
        h: 980.0, b: 300.0, tw: 16.5, tf: 26.0, weight: 249.0, area: 317.2),
    'W 40 x 12 x 183 (1016 x 305 x 272)': StandardProfileSpec(
        h: 990.0, b: 300.0, tw: 16.5, tf: 31.0, weight: 272.0, area: 346.5),
    'W 40 x 12 x 211 (1016 x 305 x 314)': StandardProfileSpec(
        h: 1000.0, b: 300.0, tw: 19.1, tf: 35.9, weight: 314.0, area: 400.0),
    'W 40 x 12 x 235 (1016 x 305 x 350)': StandardProfileSpec(
        h: 1008.0, b: 302.0, tw: 21.1, tf: 40.0, weight: 350.0, area: 445.86),
    'W 40 x 12 x 264 (1016 x 305 x 393)': StandardProfileSpec(
        h: 1016.0, b: 303.0, tw: 24.4, tf: 43.9, weight: 393.0, area: 500.64),
    'W 40 x 12 x 278 (1016 x 305 x 415)': StandardProfileSpec(
        h: 1020.0, b: 304.0, tw: 26.0, tf: 46.0, weight: 415.0, area: 528.66),
    'W 40 x 12 x 294 (1016 x 305 x 438)': StandardProfileSpec(
        h: 1026.0, b: 305.0, tw: 26.9, tf: 49.0, weight: 438.0, area: 557.96),
    'W 40 x 12 x 327 (1016 x 305 x 486)': StandardProfileSpec(
        h: 1036.0, b: 308.0, tw: 30.0, tf: 54.1, weight: 486.0, area: 619.11),
  };

  /// Helper to lookup W-Beam profile spec flexibly by full designation, inch size, metric size, or without spaces.
  static StandardProfileSpec? findWBeam(String query) {
    if (wBeams.containsKey(query)) return wBeams[query];
    final cleanQuery = query.replaceAll(' ', '').toUpperCase();
    for (final entry in wBeams.entries) {
      final cleanKey = entry.key.replaceAll(' ', '').toUpperCase();
      if (entry.key == query ||
          entry.key.startsWith(query) ||
          entry.key.contains(query) ||
          cleanKey.contains(cleanQuery) ||
          cleanQuery.contains(cleanKey)) {
        return entry.value;
      }
    }
    return null;
  }

  // Japanese Standard Channels (JIS G 3192) - Sizes up to 150x75H
  static const Map<String, StandardProfileSpec> jisChannels = {
    '75x40': StandardProfileSpec(
        h: 75.0, b: 40.0, tw: 5.0, tf: 7.0, weight: 6.92, area: 8.82),
    '100x50': StandardProfileSpec(
        h: 100.0, b: 50.0, tw: 5.0, tf: 7.5, weight: 9.36, area: 11.92),
    '125x65': StandardProfileSpec(
        h: 125.0, b: 65.0, tw: 6.0, tf: 8.0, weight: 13.40, area: 17.11),
    '150x75': StandardProfileSpec(
        h: 150.0, b: 75.0, tw: 6.5, tf: 10.0, weight: 18.60, area: 23.71),
    '150x75H': StandardProfileSpec(
        h: 150.0, b: 75.0, tw: 9.0, tf: 12.5, weight: 24.00, area: 30.59),
  };

  // Japanese Standard H-Beams (JIS G 3192) - Aligned with Client Catalog
  static const Map<String, StandardProfileSpec> jisBeams = {
    '100x100': StandardProfileSpec(
        h: 100.0, b: 100.0, tw: 6.0, tf: 8.0, weight: 16.90, area: 21.53),
    '125x125': StandardProfileSpec(
        h: 125.0, b: 125.0, tw: 6.5, tf: 9.0, weight: 23.50, area: 29.94),
    '150x75': StandardProfileSpec(
        h: 150.0, b: 75.0, tw: 5.0, tf: 7.0, weight: 14.00, area: 17.85),
    '150x150': StandardProfileSpec(
        h: 150.0, b: 150.0, tw: 7.0, tf: 10.0, weight: 31.10, area: 39.62),
    '175x90': StandardProfileSpec(
        h: 175.0, b: 90.0, tw: 5.0, tf: 8.0, weight: 18.10, area: 23.04),
    '175x175': StandardProfileSpec(
        h: 175.0, b: 175.0, tw: 7.5, tf: 11.0, weight: 40.20, area: 51.21),
    '200x100': StandardProfileSpec(
        h: 200.0, b: 100.0, tw: 5.5, tf: 8.0, weight: 21.30, area: 27.16),
    '200x200': StandardProfileSpec(
        h: 200.0, b: 200.0, tw: 8.0, tf: 12.0, weight: 49.90, area: 63.53),
    '250x125': StandardProfileSpec(
        h: 250.0, b: 125.0, tw: 6.0, tf: 9.0, weight: 29.60, area: 37.66),
    '250x250': StandardProfileSpec(
        h: 250.0, b: 250.0, tw: 9.0, tf: 14.0, weight: 71.80, area: 91.46),
    '300x150': StandardProfileSpec(
        h: 300.0, b: 150.0, tw: 6.5, tf: 9.0, weight: 36.70, area: 46.78),
    '300x300': StandardProfileSpec(
        h: 300.0, b: 300.0, tw: 10.0, tf: 15.0, weight: 93.00, area: 118.47),
    '350x175': StandardProfileSpec(
        h: 350.0, b: 175.0, tw: 7.0, tf: 11.0, weight: 49.40, area: 62.93),
    '350x350': StandardProfileSpec(
        h: 350.0, b: 350.0, tw: 12.0, tf: 19.0, weight: 134.90, area: 171.85),
    '400x200': StandardProfileSpec(
        h: 400.0, b: 200.0, tw: 8.0, tf: 13.0, weight: 65.40, area: 83.31),
    '400x400': StandardProfileSpec(
        h: 400.0, b: 400.0, tw: 13.0, tf: 21.0, weight: 172.00, area: 218.70),
  };

  // Client Catalog Standard I-Beams (Narrow Flange) - 14 Sizes from Client Specification
  static const Map<String, StandardProfileSpec> clientIBeams = {
    '150x75': StandardProfileSpec(
        h: 150.0, b: 75.0, tw: 5.0, tf: 7.0, weight: 14.00, area: 17.85),
    '198x99': StandardProfileSpec(
        h: 198.0, b: 99.0, tw: 4.5, tf: 7.0, weight: 18.20, area: 23.18),
    '200x100': StandardProfileSpec(
        h: 200.0, b: 100.0, tw: 5.5, tf: 8.0, weight: 21.30, area: 27.16),
    '248x124': StandardProfileSpec(
        h: 248.0, b: 124.0, tw: 5.0, tf: 8.0, weight: 25.70, area: 32.74),
    '250x125': StandardProfileSpec(
        h: 250.0, b: 125.0, tw: 6.0, tf: 9.0, weight: 29.60, area: 37.66),
    '298x149': StandardProfileSpec(
        h: 298.0, b: 149.0, tw: 5.5, tf: 8.0, weight: 32.00, area: 40.76),
    '300x150': StandardProfileSpec(
        h: 300.0, b: 150.0, tw: 6.5, tf: 9.0, weight: 36.70, area: 46.78),
    '346x174': StandardProfileSpec(
        h: 346.0, b: 174.0, tw: 6.0, tf: 9.0, weight: 41.20, area: 52.48),
    '350x175': StandardProfileSpec(
        h: 350.0, b: 175.0, tw: 7.0, tf: 11.0, weight: 49.40, area: 62.93),
    '396x199': StandardProfileSpec(
        h: 396.0, b: 199.0, tw: 7.0, tf: 11.0, weight: 56.60, area: 72.10),
    '400x200': StandardProfileSpec(
        h: 400.0, b: 200.0, tw: 8.0, tf: 13.0, weight: 66.00, area: 84.08),
    '496x199': StandardProfileSpec(
        h: 496.0, b: 199.0, tw: 9.0, tf: 14.0, weight: 79.50, area: 101.27),
    '500x200': StandardProfileSpec(
        h: 500.0, b: 200.0, tw: 10.0, tf: 16.0, weight: 89.60, area: 114.14),
    '596x199': StandardProfileSpec(
        h: 596.0, b: 199.0, tw: 10.0, tf: 15.0, weight: 92.50, area: 117.83),
  };

  // Client Catalog Standard H-Beams (Wide Flange) - 8 Sizes from Client Stock Specification
  static const Map<String, StandardProfileSpec> clientHBeams = {
    '100x100': StandardProfileSpec(
        h: 100.0, b: 100.0, tw: 6.0, tf: 8.0, weight: 17.20, area: 21.91),
    '125x125': StandardProfileSpec(
        h: 125.0, b: 125.0, tw: 6.5, tf: 9.0, weight: 23.80, area: 30.32),
    '150x150': StandardProfileSpec(
        h: 150.0, b: 150.0, tw: 7.0, tf: 10.0, weight: 31.50, area: 40.13),
    '200x200': StandardProfileSpec(
        h: 200.0, b: 200.0, tw: 8.0, tf: 12.0, weight: 49.90, area: 63.57),
    '250x250': StandardProfileSpec(
        h: 250.0, b: 250.0, tw: 9.0, tf: 14.0, weight: 72.40, area: 92.23),
    '300x300': StandardProfileSpec(
        h: 300.0, b: 300.0, tw: 10.0, tf: 15.0, weight: 94.00, area: 119.75),
    '350x350': StandardProfileSpec(
        h: 350.0, b: 350.0, tw: 12.0, tf: 19.0, weight: 138.00, area: 175.80),
    '400x400': StandardProfileSpec(
        h: 400.0, b: 400.0, tw: 13.0, tf: 21.0, weight: 172.00, area: 219.11),
  };

  static StandardProfileSpec? findClientIBeam(
      double h, double b, double tw, double tf) {
    for (final spec in clientIBeams.values) {
      if ((spec.h - h).abs() <= 2.0 &&
          (spec.b - b).abs() <= 2.0 &&
          (spec.tw - tw).abs() <= 0.6 &&
          (spec.tf - tf).abs() <= 0.6) {
        return spec;
      }
    }
    for (final spec in clientIBeams.values) {
      if ((spec.h - h).abs() <= 1.0 && (spec.b - b).abs() <= 1.0) {
        return spec;
      }
    }
    for (final spec in ipeBeams.values) {
      if ((spec.h - h).abs() <= 1.0 &&
          (spec.b - b).abs() <= 1.0 &&
          (spec.tw - tw).abs() <= 0.6 &&
          (spec.tf - tf).abs() <= 0.6) {
        return spec;
      }
    }
    for (final spec in ipeAaBeams.values) {
      if ((spec.h - h).abs() <= 1.0 &&
          (spec.b - b).abs() <= 1.0 &&
          (spec.tw - tw).abs() <= 0.6 &&
          (spec.tf - tf).abs() <= 0.6) {
        return spec;
      }
    }
    return null;
  }

  static StandardProfileSpec? findClientHBeam(
      double h, double b, double tw, double tf) {
    for (final spec in clientHBeams.values) {
      if ((spec.h - h).abs() <= 2.0 &&
          (spec.b - b).abs() <= 2.0 &&
          (spec.tw - tw).abs() <= 0.6 &&
          (spec.tf - tf).abs() <= 0.6) {
        return spec;
      }
    }
    for (final spec in clientHBeams.values) {
      if ((spec.h - h).abs() <= 1.0 && (spec.b - b).abs() <= 1.0) {
        return spec;
      }
    }
    for (final spec in jisBeams.values) {
      if ((spec.h - h).abs() <= 1.0 &&
          (spec.b - b).abs() <= 1.0 &&
          (spec.tw - tw).abs() <= 0.6 &&
          (spec.tf - tf).abs() <= 0.6) {
        return spec;
      }
    }
    for (final spec in heaBeams.values) {
      if ((spec.h - h).abs() <= 1.0 &&
          (spec.b - b).abs() <= 1.0 &&
          (spec.tw - tw).abs() <= 0.6 &&
          (spec.tf - tf).abs() <= 0.6) {
        return spec;
      }
    }
    for (final spec in hebBeams.values) {
      if ((spec.h - h).abs() <= 1.0 &&
          (spec.b - b).abs() <= 1.0 &&
          (spec.tw - tw).abs() <= 0.6 &&
          (spec.tf - tf).abs() <= 0.6) {
        return spec;
      }
    }
    for (final spec in wBeams.values) {
      if ((spec.h - h).abs() <= 2.0 &&
          (spec.b - b).abs() <= 2.0 &&
          (spec.tw - tw).abs() <= 0.6 &&
          (spec.tf - tf).abs() <= 0.6) {
        return spec;
      }
    }
    return null;
  }

  // Standard Square Hollow Sections (SHS) - size -> { thickness: kg/m }
  static const Map<String, Map<String, double>> squareTubes = {
    '19x19': {'1.2': 0.67, '1.5': 0.81},
    '20x20': {'1.2': 0.71, '1.5': 0.84, '2.0': 1.07},
    '25x25': {'1.2': 0.90, '1.5': 1.08, '2.0': 1.39, '2.5': 1.68, '3.0': 1.95},
    '30x30': {'1.2': 1.09, '1.5': 1.31, '2.0': 1.70, '2.5': 2.07, '3.0': 2.42},
    '40x40': {
      '1.2': 1.47,
      '1.5': 1.78,
      '2.0': 2.33,
      '2.5': 2.86,
      '3.0': 3.36,
      '4.0': 4.30,
      '5.0': 5.16
    },
    '50x50': {
      '1.2': 1.85,
      '1.5': 2.25,
      '2.0': 2.96,
      '2.5': 3.64,
      '3.0': 4.30,
      '4.0': 5.56,
      '5.0': 6.73
    },
    '60x60': {
      '1.2': 2.22,
      '1.5': 2.73,
      '2.0': 3.59,
      '2.5': 4.43,
      '3.0': 5.25,
      '4.0': 6.82,
      '5.0': 8.30,
      '6.0': 9.69
    },
    '70x70': {'3.0': 6.19, '4.0': 8.07, '5.0': 9.87},
    '80x80': {
      '3.0': 7.13,
      '4.0': 9.33,
      '5.0': 11.40,
      '6.0': 13.50,
      '8.0': 17.20
    },
    '90x90': {
      '3.0': 8.07,
      '4.0': 10.60,
      '5.0': 13.00,
      '6.0': 15.40,
      '8.0': 19.80,
      '9.0': 22.00
    },
    '100x100': {
      '3.0': 9.01,
      '4.0': 11.80,
      '5.0': 14.60,
      '6.0': 17.30,
      '8.0': 22.30,
      '10.0': 26.90
    },
    '120x120': {
      '4.0': 14.40,
      '5.0': 17.70,
      '6.0': 21.00,
      '8.0': 27.40,
      '10.0': 33.40,
      '12.0': 38.90
    },
    '150x150': {
      '4.0': 18.10,
      '5.0': 22.40,
      '6.0': 26.70,
      '8.0': 35.00,
      '10.0': 42.80,
      '12.0': 50.20,
      '15.0': 60.60
    },
    '200x200': {
      '5.0': 30.30,
      '6.0': 36.10,
      '8.0': 47.50,
      '10.0': 58.50,
      '12.0': 69.10,
      '15.0': 84.10,
      '20.0': 107.00
    },
  };

  // Standard Rectangular Hollow Sections (RHS) - size -> { thickness: kg/m }
  static const Map<String, Map<String, double>> rectangularTubes = {
    '30x15': {'1.2': 0.78, '1.5': 0.96, '2.0': 1.23},
    '40x20': {'1.2': 1.09, '1.5': 1.31, '2.0': 1.70, '2.5': 2.07, '3.0': 2.42},
    '50x25': {'1.2': 1.37, '1.5': 1.66, '2.0': 2.17, '2.5': 2.66, '3.0': 3.13},
    '50x30': {
      '1.2': 1.47,
      '1.5': 1.78,
      '2.0': 2.33,
      '2.5': 2.86,
      '3.0': 3.36,
      '4.0': 4.30
    },
    '60x30': {'1.2': 1.63, '1.5': 2.02, '2.0': 2.65, '2.5': 3.25, '3.0': 3.84},
    '60x40': {
      '1.2': 1.85,
      '1.5': 2.25,
      '2.0': 2.96,
      '2.5': 3.64,
      '3.0': 4.30,
      '4.0': 5.56
    },
    '80x40': {
      '1.2': 2.22,
      '1.5': 2.73,
      '2.0': 3.59,
      '2.5': 4.43,
      '3.0': 5.25,
      '4.0': 6.82,
      '5.0': 8.30,
      '6.0': 9.69
    },
    '100x50': {
      '1.2': 2.76,
      '1.5': 3.43,
      '2.0': 4.53,
      '2.5': 5.61,
      '3.0': 6.66,
      '4.0': 8.70,
      '5.0': 10.65,
      '6.0': 12.52,
    },
    '120x60': {
      '1.2': 3.33,
      '1.5': 4.14,
      '2.0': 5.47,
      '2.5': 6.79,
      '3.0': 8.07,
      '4.0': 10.59,
      '5.0': 13.01,
      '6.0': 15.34,
    },
    '120x80': {
      '3.0': 9.01,
      '4.0': 11.80,
      '5.0': 14.60,
      '6.0': 17.30,
      '8.0': 22.30
    },
    '140x80': {'4.0': 13.10, '5.0': 16.20, '6.0': 19.20, '8.0': 24.90},
    '150x100': {
      '4.0': 14.98,
      '5.0': 18.50,
      '6.0': 21.94,
      '8.0': 28.53,
      '10.0': 34.76
    },
    '160x80': {'4.0': 14.40, '5.0': 17.70, '6.0': 21.00, '8.0': 27.40},
    '200x100': {
      '3.0': 13.73,
      '4.0': 18.12,
      '5.0': 22.43,
      '6.0': 26.65,
      '8.0': 34.81,
      '10.0': 42.61,
      '12.0': 50.06
    },
    '200x120': {'6.0': 28.53, '8.0': 37.32, '10.0': 45.75, '12.0': 53.83},
    '250x150': {
      '5.0': 30.30,
      '6.0': 36.07,
      '8.0': 47.37,
      '10.0': 58.31,
      '12.0': 68.90
    },
  };

  // Standard Steel Pipes (ERW / Seamless - ASTM A53 / API 5L / ANSI B 36.10) - Complete sizes 1/4" to 48"
  static const Map<String, Map<String, double>> steelPipes = {
    '1/4" (13.7 mm)': {
      'Sch 40 / STD (2.24mm)': 0.63,
      'Sch 80 / XS (3.02mm)': 0.8,
    },
    '3/8" (17.1 mm)': {
      'Sch 40 / STD (2.31mm)': 0.84,
      'Sch 80 / XS (3.20mm)': 1.1,
    },
    '1/2" (21.3 mm)': {
      'Sch 20 (2.60mm)': 1.21,
      'Sch 40 / STD (2.77mm)': 1.27,
      'Sch 80 / XS (3.73mm)': 1.62,
      'Sch 160 (4.78mm)': 1.95,
      'Sch XXS (7.47mm)': 2.55,
    },
    '3/4" (26.7 mm)': {
      'Sch 20 (2.60mm)': 1.56,
      'Sch 40 / STD (2.87mm)': 1.69,
      'Sch 80 / XS (3.91mm)': 2.2,
      'Sch 160 (5.56mm)': 2.9,
      'Sch XXS (7.82mm)': 3.64,
    },
    '1" (33.4 mm)': {
      'Sch 20 (3.20mm)': 2.41,
      'Sch 40 / STD (3.38mm)': 2.5,
      'Sch 80 / XS (4.55mm)': 3.24,
      'Sch 160 (6.35mm)': 4.24,
      'Sch XXS (9.09mm)': 5.45,
    },
    '1-1/4" (42.2 mm)': {
      'Sch 20 (3.20mm)': 3.1,
      'Sch 40 / STD (3.56mm)': 3.39,
      'Sch 80 / XS (4.85mm)': 4.47,
      'Sch 160 (6.35mm)': 5.61,
      'Sch XXS (9.70mm)': 7.77,
    },
    '1-1/2" (48.3 mm)': {
      'Sch 20 (3.20mm)': 3.57,
      'Sch 40 / STD (3.68mm)': 4.05,
      'Sch 80 / XS (5.08mm)': 5.41,
      'Sch 160 (7.14mm)': 7.25,
      'Sch XXS (10.15mm)': 9.56,
    },
    '2" (60.3 mm)': {
      'Sch 20 (3.60mm)': 5.03,
      'Sch 40 / STD (3.91mm)': 5.44,
      'Sch 80 / XS (5.54mm)': 7.48,
      'Sch 160 (8.74mm)': 11.11,
      'Sch XXS (11.07mm)': 13.44,
    },
    '2-1/2" (73.0 mm)': {
      'Sch 20 (3.60mm)': 6.43,
      'Sch 40 / STD (5.16mm)': 8.63,
      'Sch 80 / XS (7.01mm)': 11.41,
      'Sch 160 (9.53mm)': 14.92,
      'Sch XXS (14.02mm)': 20.39,
    },
    '3" (88.9 mm)': {
      'Sch 20 (4.00mm)': 8.37,
      'Sch 40 / STD (5.49mm)': 11.29,
      'Sch 80 / XS (7.62mm)': 15.27,
      'Sch 160 (11.13mm)': 21.35,
      'Sch XXS (15.24mm)': 27.68,
    },
    '3-1/2" (101.6 mm)': {
      'Sch 40 / STD (5.74mm)': 13.57,
      'Sch 80 / XS (8.08mm)': 18.63,
    },
    '4" (114.3 mm)': {
      'Sch 20 (4.50mm)': 12.2,
      'Sch 40 / STD (6.02mm)': 16.07,
      'Sch 80 / XS (8.56mm)': 22.32,
      'Sch 120 (11.13mm)': 28.32,
      'Sch 160 (13.49mm)': 33.54,
      'Sch XXS (17.12mm)': 41.03,
    },
    '5" (141.3 mm)': {
      'Sch 20 (5.00mm)': 16.8,
      'Sch 40 / STD (6.55mm)': 21.77,
      'Sch 80 / XS (9.53mm)': 30.97,
      'Sch 120 (12.70mm)': 40.28,
      'Sch 160 (15.88mm)': 49.11,
      'Sch XXS (19.05mm)': 57.43,
    },
    '6" (168.3 mm)': {
      'Sch 20 (5.00mm)': 19.7,
      'Sch 40 / STD (7.11mm)': 28.26,
      'Sch 80 / XS (10.97mm)': 42.56,
      'Sch 120 (14.27mm)': 54.2,
      'Sch 160 (18.26mm)': 67.56,
      'Sch XXS (21.95mm)': 79.22,
    },
    '8" (219.1 mm)': {
      'Sch 20 (6.35mm)': 33.31,
      'Sch 30 (7.04mm)': 36.81,
      'Sch 40 / STD (8.18mm)': 42.55,
      'Sch 60 (10.31mm)': 53.08,
      'Sch 80 / XS (12.70mm)': 64.64,
      'Sch 100 (15.09mm)': 75.92,
      'Sch 120 (18.26mm)': 90.44,
      'Sch 140 (20.62mm)': 100.9,
      'Sch 160 (23.01mm)': 111.2,
      'Sch XXS (22.23mm)': 107.99,
    },
    '10" (273.0 mm)': {
      'Sch 20 (6.35mm)': 41.77,
      'Sch 30 (7.80mm)': 51.0,
      'Sch 40 / STD (9.27mm)': 60.31,
      'Sch 60 / XS (12.70mm)': 81.55,
      'Sch 80 (15.09mm)': 96.01,
      'Sch 100 (18.26mm)': 114.7,
      'Sch 120 (21.44mm)': 133.0,
      'Sch 140 / XXS (25.40mm)': 155.1,
      'Sch 160 (28.58mm)': 172.2,
    },
    '12" (323.8 mm)': {
      'Sch 20 (6.35mm)': 49.73,
      'Sch 30 (8.38mm)': 65.2,
      'Sch STD (9.53mm)': 73.88,
      'Sch 40 (10.31mm)': 79.73,
      'Sch XS (12.70mm)': 97.46,
      'Sch 60 (14.27mm)': 108.9,
      'Sch 80 (17.48mm)': 132.0,
      'Sch 100 (21.44mm)': 159.9,
      'Sch 120 / XXS (25.40mm)': 186.9,
      'Sch 140 (28.58mm)': 208.1,
      'Sch 160 (33.32mm)': 238.7,
    },
    '14" (355.6 mm)': {
      'Sch 10 (6.35mm)': 54.69,
      'Sch 20 (7.92mm)': 67.9,
      'Sch 30 / STD (9.53mm)': 81.33,
      'Sch 40 (11.13mm)': 94.55,
      'Sch XS (12.70mm)': 107.39,
      'Sch 60 / 80 (15.09mm)': 126.7,
      'Sch 100 (19.05mm)': 158.1,
      'Sch 120 (23.83mm)': 194.9,
      'Sch 140 (27.79mm)': 224.6,
      'Sch 160 (31.75mm)': 253.9,
      'Sch XXS (35.71mm)': 281.7,
    },
    '16" (406.4 mm)': {
      'Sch 10 (6.35mm)': 62.64,
      'Sch 20 (7.92mm)': 77.83,
      'Sch 30 / STD (9.53mm)': 93.27,
      'Sch 40 / XS (12.70mm)': 123.3,
      'Sch 60 / 80 (16.66mm)': 160.1,
      'Sch 100 (21.44mm)': 203.5,
      'Sch 120 (26.19mm)': 245.5,
      'Sch 140 (30.96mm)': 286.6,
      'Sch 160 (36.53mm)': 333.1,
      'Sch XXS (40.49mm)': 365.38,
    },
    '18" (457.2 mm)': {
      'Sch 10 (6.35mm)': 70.57,
      'Sch 20 (7.92mm)': 87.71,
      'Sch STD (9.53mm)': 105.1,
      'Sch 30 (11.13mm)': 122.3,
      'Sch XS (12.70mm)': 139.15,
      'Sch 40 (14.27mm)': 155.8,
      'Sch 60 / 80 (19.05mm)': 205.7,
      'Sch 100 (23.83mm)': 245.5,
      'Sch 120 (29.36mm)': 309.6,
      'Sch 140 (34.93mm)': 363.5,
      'Sch 160 (39.67mm)': 408.2,
      'Sch XXS (45.24mm)': 459.3,
    },
    '20" (508.0 mm)': {
      'Sch 10 (6.35mm)': 78.55,
      'Sch 20 / STD (9.53mm)': 117.1,
      'Sch 30 / XS (12.70mm)': 155.1,
      'Sch 40 (15.09mm)': 183.4,
      'Sch 60 / 80 (20.62mm)': 247.8,
      'Sch 100 (26.19mm)': 311.1,
      'Sch 120 (32.54mm)': 381.5,
      'Sch 140 (38.10mm)': 441.4,
      'Sch 160 (44.45mm)': 508.1,
      'Sch XXS (50.01mm)': 564.8,
    },
    '22" (559.0 mm)': {
      'Sch 10 (6.35mm)': 86.54,
      'Sch 20 / STD (9.53mm)': 129.1,
      'Sch 30 / XS (12.70mm)': 171.0,
      'Sch 60 (22.23mm)': 294.2,
      'Sch 80 (28.58mm)': 373.8,
      'Sch 100 (34.93mm)': 451.4,
      'Sch 120 (41.28mm)': 527.0,
      'Sch 140 (47.63mm)': 600.0,
      'Sch 160 (53.98mm)': 672.2,
    },
    '24" (609.6 mm)': {
      'Sch 10 (6.35mm)': 94.53,
      'Sch 20 / STD (9.53mm)': 141.1,
      'Sch XS (12.70mm)': 187.0,
      'Sch 30 (14.27mm)': 209.6,
      'Sch 40 (17.48mm)': 255.4,
      'Sch 60 (24.61mm)': 355.2,
      'Sch 80 (30.96mm)': 442.0,
      'Sch 100 (38.89mm)': 547.7,
      'Sch 120 (46.02mm)': 640.0,
      'Sch 140 (52.37mm)': 720.1,
      'Sch 160 (59.54mm)': 808.2,
    },
    '26" (660.4 mm)': {
      'Sch 10 (7.92mm)': 127.3,
      'Sch STD (9.53mm)': 152.8,
      'Sch 20 / XS (12.70mm)': 202.7,
    },
    '28" (711.2 mm)': {
      'Sch 10 (7.92mm)': 137.3,
      'Sch STD (9.53mm)': 164.8,
      'Sch 20 / XS (12.70mm)': 218.6,
      'Sch 30 (15.88mm)': 271.2,
    },
    '30" (762.0 mm)': {
      'Sch 10 (7.92mm)': 147.2,
      'Sch STD (9.53mm)': 176.8,
      'Sch 20 / XS (12.70mm)': 234.6,
      'Sch 30 (15.88mm)': 291.1,
    },
    '32" (812.8 mm)': {
      'Sch 10 (7.92mm)': 157.2,
      'Sch 40 (17.48mm)': 342.9,
      'Sch STD (9.53mm)': 188.8,
      'Sch 20 / XS (12.70mm)': 250.6,
      'Sch 30 (15.88mm)': 312.1,
    },
    '34" (863.6 mm)': {
      'Sch 10 (7.92mm)': 167.2,
      'Sch STD (9.53mm)': 200.3,
      'Sch 20 / XS (12.70mm)': 266.6,
      'Sch 30 (15.88mm)': 332.1,
      'Sch 40 (17.48mm)': 364.9,
    },
    '36" (914.4 mm)': {
      'Sch 10 (7.92mm)': 176.9,
      'Sch STD (9.53mm)': 212.5,
      'Sch 20 / XS (12.70mm)': 282.2,
      'Sch 30 (15.88mm)': 351.7,
      'Sch 40 (19.05mm)': 426.4,
    },
    '38" (965.0 mm)': {
      'Sch STD (9.53mm)': 224.54,
      'Sch XS (12.70mm)': 298.24,
    },
    '40" (1016.0 mm)': {
      'Sch STD (9.53mm)': 236.53,
      'Sch XS (12.70mm)': 314.22,
    },
    '42" (1067.0 mm)': {
      'Sch STD (9.53mm)': 248.52,
      'Sch XS (12.70mm)': 330.19,
    },
    '44" (1118.0 mm)': {
      'Sch STD (9.53mm)': 260.5,
      'Sch XS (12.70mm)': 346.16,
    },
    '46" (1168.0 mm)': {
      'Sch STD (9.53mm)': 272.25,
      'Sch XS (12.70mm)': 361.66,
    },
    '48" (1219.0 mm)': {
      'Sch STD (9.53mm)': 284.24,
      'Sch XS (12.70mm)': 377.79,
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
    '15',
    '20',
    '25',
    '30',
    '35',
    '40',
    '45',
    '50',
    '60',
    '70',
    '75',
    '80',
    '90',
    '100',
    '120',
    '130',
    '150',
    '200'
  ];

  static const List<String> flatBarThicknesses = [
    '3',
    '4',
    '5',
    '6',
    '8',
    '10',
    '12',
    '15',
    '16',
    '20',
    '25',
    '30'
  ];

  // Steel Sheets standard thicknesses (mm)
  static const List<String> sheetThicknesses = [
    '0.5',
    '0.8',
    '1.0',
    '1.2',
    '1.5',
    '2.0',
    '2.5',
    '3.0',
    '4.0',
    '5.0',
    '6.0',
    '8.0',
    '10.0',
    '12.0',
    '15.0',
    '20.0',
    '25.0',
    '30.0'
  ];

  // Aluminum Checkered Sheet thicknesses (mm)
  static const List<String> checkeredSheetThicknesses = [
    '1.5',
    '2.0',
    '2.5',
    '3.0',
    '4.0',
    '4.5',
    '5.0',
    '6.0',
    '8.0'
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
    '6',
    '8',
    '10',
    '12',
    '14',
    '16',
    '18',
    '20',
    '22',
    '25',
    '28',
    '30',
    '32',
    '36',
    '40',
    '45',
    '50',
    '55',
    '60',
    '70',
    '80',
    '90',
    '100'
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
