// MARK: - Tailwind v4 color palette

extension Color {

    // MARK: Slate

    public static func slate(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.984, 0.003, 247.9)
        case 100: return Color(oklch: 0.968, 0.007, 247.9)
        case 200: return Color(oklch: 0.929, 0.013, 255.6)
        case 300: return Color(oklch: 0.869, 0.022, 252.9)
        case 400: return Color(oklch: 0.704, 0.040, 256.4)
        case 500: return Color(oklch: 0.554, 0.046, 257.4)
        case 600: return Color(oklch: 0.446, 0.043, 256.8)
        case 700: return Color(oklch: 0.372, 0.044, 258.5)
        case 800: return Color(oklch: 0.279, 0.041, 260.0)
        case 900: return Color(oklch: 0.208, 0.042, 265.8)
        case 950: return Color(oklch: 0.129, 0.042, 281.1)
        default:  return Color(oklch: 0.554, 0.046, 257.4)
        }
    }

    // MARK: Gray

    public static func gray(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.985, 0.002, 247.9)
        case 100: return Color(oklch: 0.967, 0.003, 264.5)
        case 200: return Color(oklch: 0.924, 0.006, 264.5)
        case 300: return Color(oklch: 0.872, 0.010, 258.3)
        case 400: return Color(oklch: 0.707, 0.022, 261.3)
        case 500: return Color(oklch: 0.551, 0.023, 264.4)
        case 600: return Color(oklch: 0.446, 0.020, 262.8)
        case 700: return Color(oklch: 0.372, 0.018, 264.6)
        case 800: return Color(oklch: 0.269, 0.015, 261.7)
        case 900: return Color(oklch: 0.210, 0.014, 265.8)
        case 950: return Color(oklch: 0.145, 0.017, 281.1)
        default:  return Color(oklch: 0.551, 0.023, 264.4)
        }
    }

    // MARK: Zinc

    public static func zinc(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.985, 0,     0)
        case 100: return Color(oklch: 0.967, 0.001, 286.4)
        case 200: return Color(oklch: 0.920, 0.004, 286.4)
        case 300: return Color(oklch: 0.871, 0.006, 286.5)
        case 400: return Color(oklch: 0.705, 0.015, 286.1)
        case 500: return Color(oklch: 0.552, 0.016, 285.9)
        case 600: return Color(oklch: 0.442, 0.017, 285.1)
        case 700: return Color(oklch: 0.370, 0.013, 285.7)
        case 800: return Color(oklch: 0.274, 0.006, 286.3)
        case 900: return Color(oklch: 0.210, 0.006, 285.9)
        case 950: return Color(oklch: 0.141, 0.005, 285.8)
        default:  return Color(oklch: 0.552, 0.016, 285.9)
        }
    }

    // MARK: Neutral

    public static func neutral(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.985, 0,     0)
        case 100: return Color(oklch: 0.970, 0,     0)
        case 200: return Color(oklch: 0.922, 0,     0)
        case 300: return Color(oklch: 0.870, 0,     0)
        case 400: return Color(oklch: 0.708, 0,     0)
        case 500: return Color(oklch: 0.556, 0,     0)
        case 600: return Color(oklch: 0.439, 0,     0)
        case 700: return Color(oklch: 0.371, 0,     0)
        case 800: return Color(oklch: 0.269, 0,     0)
        case 900: return Color(oklch: 0.205, 0,     0)
        case 950: return Color(oklch: 0.145, 0,     0)
        default:  return Color(oklch: 0.556, 0,     0)
        }
    }

    // MARK: Stone

    public static func stone(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.985, 0.001, 106.4)
        case 100: return Color(oklch: 0.970, 0.002, 106.4)
        case 200: return Color(oklch: 0.923, 0.003, 48.7)
        case 300: return Color(oklch: 0.869, 0.005, 56.4)
        case 400: return Color(oklch: 0.709, 0.010, 56.2)
        case 500: return Color(oklch: 0.553, 0.013, 58.0)
        case 600: return Color(oklch: 0.444, 0.011, 73.6)
        case 700: return Color(oklch: 0.374, 0.010, 67.6)
        case 800: return Color(oklch: 0.268, 0.007, 34.3)
        case 900: return Color(oklch: 0.216, 0.006, 56.0)
        case 950: return Color(oklch: 0.147, 0.004, 49.3)
        default:  return Color(oklch: 0.553, 0.013, 58.0)
        }
    }

    // MARK: Red

    public static func red(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.971, 0.013, 17.4)
        case 100: return Color(oklch: 0.936, 0.032, 17.6)
        case 200: return Color(oklch: 0.885, 0.062, 18.1)
        case 300: return Color(oklch: 0.808, 0.114, 19.6)
        case 400: return Color(oklch: 0.704, 0.191, 22.2)
        case 500: return Color(oklch: 0.637, 0.237, 25.3)
        case 600: return Color(oklch: 0.577, 0.245, 27.3)
        case 700: return Color(oklch: 0.505, 0.213, 27.4)
        case 800: return Color(oklch: 0.444, 0.177, 26.4)
        case 900: return Color(oklch: 0.396, 0.141, 25.7)
        case 950: return Color(oklch: 0.258, 0.092, 26.4)
        default:  return Color(oklch: 0.637, 0.237, 25.3)
        }
    }

    // MARK: Orange

    public static func orange(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.980, 0.016, 73.7)
        case 100: return Color(oklch: 0.954, 0.038, 75.1)
        case 200: return Color(oklch: 0.901, 0.076, 70.1)
        case 300: return Color(oklch: 0.837, 0.128, 66.0)
        case 400: return Color(oklch: 0.750, 0.183, 55.7)
        case 500: return Color(oklch: 0.705, 0.213, 47.6)
        case 600: return Color(oklch: 0.646, 0.222, 41.1)
        case 700: return Color(oklch: 0.553, 0.195, 38.4)
        case 800: return Color(oklch: 0.470, 0.157, 37.6)
        case 900: return Color(oklch: 0.408, 0.123, 38.4)
        case 950: return Color(oklch: 0.266, 0.079, 36.3)
        default:  return Color(oklch: 0.705, 0.213, 47.6)
        }
    }

    // MARK: Amber

    public static func amber(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.987, 0.022, 95.3)
        case 100: return Color(oklch: 0.962, 0.059, 95.6)
        case 200: return Color(oklch: 0.924, 0.120, 95.3)
        case 300: return Color(oklch: 0.879, 0.169, 91.4)
        case 400: return Color(oklch: 0.828, 0.189, 84.5)
        case 500: return Color(oklch: 0.769, 0.188, 70.1)
        case 600: return Color(oklch: 0.666, 0.179, 58.6)
        case 700: return Color(oklch: 0.555, 0.163, 48.9)
        case 800: return Color(oklch: 0.473, 0.137, 46.2)
        case 900: return Color(oklch: 0.414, 0.112, 45.9)
        case 950: return Color(oklch: 0.279, 0.077, 45.0)
        default:  return Color(oklch: 0.769, 0.188, 70.1)
        }
    }

    // MARK: Yellow

    public static func yellow(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.987, 0.026, 102.2)
        case 100: return Color(oklch: 0.973, 0.071, 103.2)
        case 200: return Color(oklch: 0.945, 0.129, 101.5)
        case 300: return Color(oklch: 0.905, 0.182, 98.2)
        case 400: return Color(oklch: 0.852, 0.199, 91.2)
        case 500: return Color(oklch: 0.795, 0.184, 86.4)
        case 600: return Color(oklch: 0.681, 0.162, 75.8)
        case 700: return Color(oklch: 0.554, 0.135, 66.4)
        case 800: return Color(oklch: 0.476, 0.114, 61.9)
        case 900: return Color(oklch: 0.421, 0.095, 57.7)
        case 950: return Color(oklch: 0.286, 0.066, 53.8)
        default:  return Color(oklch: 0.795, 0.184, 86.4)
        }
    }

    // MARK: Lime

    public static func lime(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.986, 0.031, 120.4)
        case 100: return Color(oklch: 0.967, 0.067, 122.3)
        case 200: return Color(oklch: 0.938, 0.127, 124.3)
        case 300: return Color(oklch: 0.897, 0.176, 126.7)
        case 400: return Color(oklch: 0.841, 0.201, 128.1)
        case 500: return Color(oklch: 0.768, 0.204, 129.7)
        case 600: return Color(oklch: 0.648, 0.200, 131.7)
        case 700: return Color(oklch: 0.532, 0.157, 131.6)
        case 800: return Color(oklch: 0.453, 0.124, 130.9)
        case 900: return Color(oklch: 0.405, 0.101, 131.1)
        case 950: return Color(oklch: 0.274, 0.072, 132.1)
        default:  return Color(oklch: 0.768, 0.204, 129.7)
        }
    }

    // MARK: Green

    public static func green(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.982, 0.018, 155.8)
        case 100: return Color(oklch: 0.962, 0.044, 156.7)
        case 200: return Color(oklch: 0.925, 0.084, 155.3)
        case 300: return Color(oklch: 0.871, 0.150, 154.4)
        case 400: return Color(oklch: 0.792, 0.209, 151.7)
        case 500: return Color(oklch: 0.723, 0.219, 149.6)
        case 600: return Color(oklch: 0.627, 0.194, 149.0)
        case 700: return Color(oklch: 0.527, 0.154, 150.1)
        case 800: return Color(oklch: 0.448, 0.119, 151.3)
        case 900: return Color(oklch: 0.393, 0.095, 152.5)
        case 950: return Color(oklch: 0.266, 0.065, 152.7)
        default:  return Color(oklch: 0.723, 0.219, 149.6)
        }
    }

    // MARK: Emerald

    public static func emerald(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.979, 0.021, 166.1)
        case 100: return Color(oklch: 0.950, 0.052, 163.1)
        case 200: return Color(oklch: 0.905, 0.093, 163.9)
        case 300: return Color(oklch: 0.845, 0.143, 164.2)
        case 400: return Color(oklch: 0.765, 0.177, 163.2)
        case 500: return Color(oklch: 0.696, 0.170, 162.5)
        case 600: return Color(oklch: 0.596, 0.145, 163.6)
        case 700: return Color(oklch: 0.508, 0.118, 165.6)
        case 800: return Color(oklch: 0.432, 0.095, 166.2)
        case 900: return Color(oklch: 0.378, 0.077, 168.9)
        case 950: return Color(oklch: 0.262, 0.051, 172.6)
        default:  return Color(oklch: 0.696, 0.170, 162.5)
        }
    }

    // MARK: Teal

    public static func teal(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.984, 0.014, 180.7)
        case 100: return Color(oklch: 0.953, 0.051, 180.8)
        case 200: return Color(oklch: 0.910, 0.096, 180.3)
        case 300: return Color(oklch: 0.855, 0.138, 181.1)
        case 400: return Color(oklch: 0.777, 0.152, 181.9)
        case 500: return Color(oklch: 0.704, 0.140, 182.9)
        case 600: return Color(oklch: 0.600, 0.118, 184.7)
        case 700: return Color(oklch: 0.511, 0.096, 186.4)
        case 800: return Color(oklch: 0.437, 0.078, 188.2)
        case 900: return Color(oklch: 0.386, 0.063, 188.4)
        case 950: return Color(oklch: 0.277, 0.046, 192.5)
        default:  return Color(oklch: 0.704, 0.140, 182.9)
        }
    }

    // MARK: Cyan

    public static func cyan(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.984, 0.019, 200.7)
        case 100: return Color(oklch: 0.956, 0.045, 203.4)
        case 200: return Color(oklch: 0.917, 0.080, 205.3)
        case 300: return Color(oklch: 0.865, 0.127, 207.1)
        case 400: return Color(oklch: 0.789, 0.154, 211.0)
        case 500: return Color(oklch: 0.715, 0.143, 215.2)
        case 600: return Color(oklch: 0.609, 0.126, 221.7)
        case 700: return Color(oklch: 0.520, 0.105, 223.1)
        case 800: return Color(oklch: 0.450, 0.085, 224.3)
        case 900: return Color(oklch: 0.398, 0.070, 227.4)
        case 950: return Color(oklch: 0.302, 0.056, 229.9)
        default:  return Color(oklch: 0.715, 0.143, 215.2)
        }
    }

    // MARK: Sky

    public static func sky(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.977, 0.013, 236.6)
        case 100: return Color(oklch: 0.951, 0.026, 236.1)
        case 200: return Color(oklch: 0.901, 0.058, 230.9)
        case 300: return Color(oklch: 0.828, 0.111, 230.0)
        case 400: return Color(oklch: 0.746, 0.158, 226.8)
        case 500: return Color(oklch: 0.685, 0.169, 237.3)
        case 600: return Color(oklch: 0.588, 0.158, 241.3)
        case 700: return Color(oklch: 0.500, 0.134, 242.7)
        case 800: return Color(oklch: 0.443, 0.110, 240.7)
        case 900: return Color(oklch: 0.391, 0.090, 240.2)
        case 950: return Color(oklch: 0.293, 0.066, 243.2)
        default:  return Color(oklch: 0.685, 0.169, 237.3)
        }
    }

    // MARK: Blue

    public static func blue(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.970, 0.014, 254.6)
        case 100: return Color(oklch: 0.932, 0.032, 254.6)
        case 200: return Color(oklch: 0.882, 0.059, 254.6)
        case 300: return Color(oklch: 0.809, 0.105, 251.8)
        case 400: return Color(oklch: 0.707, 0.165, 254.6)
        case 500: return Color(oklch: 0.623, 0.214, 259.1)
        case 600: return Color(oklch: 0.546, 0.245, 262.9)
        case 700: return Color(oklch: 0.488, 0.243, 264.4)
        case 800: return Color(oklch: 0.424, 0.199, 265.6)
        case 900: return Color(oklch: 0.379, 0.146, 265.4)
        case 950: return Color(oklch: 0.282, 0.091, 267.9)
        default:  return Color(oklch: 0.623, 0.214, 259.1)
        }
    }

    // MARK: Indigo

    public static func indigo(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.962, 0.018, 272.3)
        case 100: return Color(oklch: 0.930, 0.034, 272.8)
        case 200: return Color(oklch: 0.870, 0.065, 274.0)
        case 300: return Color(oklch: 0.785, 0.115, 274.7)
        case 400: return Color(oklch: 0.673, 0.182, 276.9)
        case 500: return Color(oklch: 0.585, 0.233, 277.1)
        case 600: return Color(oklch: 0.511, 0.262, 276.2)
        case 700: return Color(oklch: 0.457, 0.240, 277.0)
        case 800: return Color(oklch: 0.398, 0.195, 277.4)
        case 900: return Color(oklch: 0.359, 0.144, 278.7)
        case 950: return Color(oklch: 0.257, 0.090, 281.3)
        default:  return Color(oklch: 0.585, 0.233, 277.1)
        }
    }

    // MARK: Violet

    public static func violet(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.969, 0.016, 293.8)
        case 100: return Color(oklch: 0.943, 0.029, 294.6)
        case 200: return Color(oklch: 0.894, 0.057, 293.3)
        case 300: return Color(oklch: 0.811, 0.111, 293.5)
        case 400: return Color(oklch: 0.702, 0.183, 293.5)
        case 500: return Color(oklch: 0.606, 0.224, 292.7)
        case 600: return Color(oklch: 0.541, 0.232, 292.5)
        case 700: return Color(oklch: 0.491, 0.210, 292.5)
        case 800: return Color(oklch: 0.432, 0.175, 294.2)
        case 900: return Color(oklch: 0.380, 0.140, 295.1)
        case 950: return Color(oklch: 0.283, 0.109, 296.0)
        default:  return Color(oklch: 0.541, 0.232, 292.5)
        }
    }

    // MARK: Purple

    public static func purple(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.977, 0.014, 308.3)
        case 100: return Color(oklch: 0.946, 0.033, 307.2)
        case 200: return Color(oklch: 0.902, 0.063, 306.4)
        case 300: return Color(oklch: 0.827, 0.119, 306.4)
        case 400: return Color(oklch: 0.714, 0.203, 305.0)
        case 500: return Color(oklch: 0.627, 0.265, 303.9)
        case 600: return Color(oklch: 0.558, 0.288, 302.3)
        case 700: return Color(oklch: 0.496, 0.265, 301.9)
        case 800: return Color(oklch: 0.438, 0.218, 303.7)
        case 900: return Color(oklch: 0.381, 0.176, 304.1)
        case 950: return Color(oklch: 0.291, 0.149, 302.7)
        default:  return Color(oklch: 0.627, 0.265, 303.9)
        }
    }

    // MARK: Fuchsia

    public static func fuchsia(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.977, 0.017, 320.1)
        case 100: return Color(oklch: 0.952, 0.037, 318.9)
        case 200: return Color(oklch: 0.903, 0.076, 319.6)
        case 300: return Color(oklch: 0.833, 0.145, 321.4)
        case 400: return Color(oklch: 0.740, 0.238, 322.2)
        case 500: return Color(oklch: 0.667, 0.295, 322.1)
        case 600: return Color(oklch: 0.591, 0.293, 321.5)
        case 700: return Color(oklch: 0.518, 0.253, 323.0)
        case 800: return Color(oklch: 0.452, 0.211, 324.1)
        case 900: return Color(oklch: 0.401, 0.170, 325.4)
        case 950: return Color(oklch: 0.293, 0.136, 325.4)
        default:  return Color(oklch: 0.667, 0.295, 322.1)
        }
    }

    // MARK: Pink

    public static func pink(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.971, 0.014, 343.2)
        case 100: return Color(oklch: 0.948, 0.028, 342.3)
        case 200: return Color(oklch: 0.899, 0.061, 343.7)
        case 300: return Color(oklch: 0.823, 0.120, 346.0)
        case 400: return Color(oklch: 0.718, 0.202, 349.8)
        case 500: return Color(oklch: 0.656, 0.241, 354.3)
        case 600: return Color(oklch: 0.592, 0.249, 358.9)
        case 700: return Color(oklch: 0.525, 0.223, 3.0)
        case 800: return Color(oklch: 0.459, 0.187, 4.4)
        case 900: return Color(oklch: 0.408, 0.153, 2.6)
        case 950: return Color(oklch: 0.284, 0.109, 3.9)
        default:  return Color(oklch: 0.656, 0.241, 354.3)
        }
    }

    // MARK: Rose

    public static func rose(_ shade: Int) -> Color {
        switch shade {
        case 50:  return Color(oklch: 0.969, 0.015, 12.4)
        case 100: return Color(oklch: 0.941, 0.030, 15.2)
        case 200: return Color(oklch: 0.892, 0.058, 14.3)
        case 300: return Color(oklch: 0.836, 0.099, 14.3)
        case 400: return Color(oklch: 0.766, 0.157, 17.0)
        case 500: return Color(oklch: 0.645, 0.196, 15.6)
        case 600: return Color(oklch: 0.586, 0.197, 14.6)
        case 700: return Color(oklch: 0.514, 0.172, 16.6)
        case 800: return Color(oklch: 0.445, 0.139, 17.8)
        case 900: return Color(oklch: 0.410, 0.115, 20.1)
        case 950: return Color(oklch: 0.271, 0.083, 22.9)
        default:  return Color(oklch: 0.586, 0.197, 14.6)
        }
    }

    // MARK: - Semantic colors

    /// Default primary color (violet 600). Override via `SiteTheme`.
    public static var primary: Color     { .violet(600) }
    /// Default accent color (emerald 400). Override via `SiteTheme`.
    public static var accent: Color      { .emerald(400) }
    /// Surface color (white).
    public static var surface: Color     { Color(oklch: 1.0, 0, 0) }
    /// Secondary surface (slate 100).
    public static var secondary: Color   { .slate(100) }
    /// Tertiary surface (slate 50).
    public static var tertiary: Color    { .slate(50) }
    /// Default text color (slate 900).
    public static var text: Color        { .slate(900) }
    /// Muted / de-emphasised text (slate 500).
    public static var muted: Color       { .slate(500) }
    /// Destructive action color (rose 600).
    public static var destructive: Color { .rose(600) }
    /// Pure white.
    public static var white: Color       { Color(oklch: 1.0, 0, 0) }
    /// Pure black.
    public static var black: Color       { Color(oklch: 0.0, 0, 0) }
    /// Fully transparent.
    public static var clear: Color       { Color(oklch: 0, 0, 0).opacity(0) }
}
