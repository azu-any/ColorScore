# ColorScore (AppAccesibilidad) ⚽️👁️

**Real-time visual assistance for enjoying football matches with high-contrast customizable shapes, colors, and accessibility filters.**

ColorScore is an iOS application designed to make live football (soccer) matches more accessible for people with color vision deficiency (daltonism) and low vision. Using on-device Computer Vision, CoreML, and unsupervised clustering, the app detects players, goalkeepers, and the ball in real time through the device camera and overlays customizable geometric indicators and high-contrast visual filters.

---

## ✨ Features

- **Real-Time Object Detection (`Vision` & `CoreML`)**: Detects players, goalkeepers, and the ball live from the camera feed using a custom-trained YOLO model (`best.mlpackage`).
- **Automatic Team Classification (`Accelerate` & K-Means)**: A 10-second on-field calibration step extracts jersey colors from detected player bounding boxes and groups them automatically into two teams using K-Means clustering (`SimpleKMeans` & `TeamClassifier`).
- **Customizable Shapes & High-Contrast Colors**: Assign distinct geometric shapes (circle, triangle, square, etc.) and high-contrast colors independently for Team 1, Team 2, both goalkeepers, and the ball.
- **Daltonism & Low-Vision Camera Filters (`CoreImage`)**:
  - **Daltonization Filters**: Protanopia, Deuteranopia, and Tritanopia color-matrix enhancements.
  - **Magnifier-Inspired High-Contrast Filters**: Yellow/Blue, Yellow/Black, White/Blue, Red/Black, Grayscale, and Inverted modes.
- **Custom Team Management (`SwiftData`)**: Choose from preloaded Liga MX clubs or create custom teams with custom badges and colors persisted locally with SwiftData.
- **Live Scoreboard & Camera Controls**: Track match scores directly from the top overlay and adjust live camera zoom.
- **Accessibility First**: Built with **Liquid Glass** (`glassEffect`) styling, high-contrast UI components, and full **VoiceOver** support (`accessibilityLabel`, `accessibilityHint`, traits, and sort priorities).

---

## 🛠️ Tech Stack & Architecture

| Technology | Purpose |
| :--- | :--- |
| **SwiftUI & UIKit** | Modern declarative UI with Liquid Glass design and `AVFoundation` camera integration |
| **Vision & CoreML** | Real-time YOLO object detection for players, goalkeepers, and ball |
| **CoreImage & Accelerate** | Live camera color filters and fast K-Means clustering on jersey color crops |
| **SwiftData** | Local persistence for user-created custom teams (`CustomTeam`) |

### Project Structure

```text
AppAccesibilidad/
├── App/                        # App entry point, SwiftData container, and orientation lock
├── Features/
│   ├── Home/                   # Home screen, tutorial, credits, and Liquid Glass cards
│   ├── LiveMatch/
│   │   ├── Personalization/    # MatchSettings, CameraFilter, shapes, and color enums
│   │   ├── ViewControllers/    # Camera capture, Vision pipeline, calibration, and live overlays
│   │   └── Views/              # SwiftUI camera controls, scoreboard, and customization sheets
│   └── Team/                   # Team selection and custom team creation (SwiftData)
├── Resources/                  # Assets catalog and AppIcon
├── Shared/                     # Reusable components, custom pickers, and Color extensions
└── Vision/
    ├── Models/                 # CoreML object detection models (.mlpackage)
    ├── TeamAssigner/           # SimpleKMeans and TeamClassifier for automatic team assignment
    └── VisionProcessor.swift   # Serial Vision request handler
```

---

## 🚀 Getting Started

### Requirements

- **Xcode**: 26.0+ (supports iOS 26 Liquid Glass APIs; base deployment target iOS 16.0+)
- **iOS Device**: Physical iPhone or iPad recommended for live camera and CoreML performance
- **Git LFS**: Recommended if cloning large CoreML model weights

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/azu-any/AppAccesibilidad.git
   cd AppAccesibilidad
   ```

2. **Open the project in Xcode:**
   ```bash
   open AppAccesibilidad.xcodeproj
   ```

3. **Configure Signing & Run:**
   - Select the `AppAccesibilidad` target in Xcode.
   - Under **Signing & Capabilities**, select your personal or organizational Development Team.
   - Connect a physical iOS device and press **Run (`⌘R`)**.

---

## 📖 How It Works

1. **Select Teams**: On the home screen, select Team 1 and Team 2 from the club list or create a custom team with your own badge and color.
2. **Start Match**: Tap **"Empezar partido"**. The app transitions to landscape mode and opens the rear camera.
3. **Calibrate Camera**: Point the camera at players on the pitch and tap **"Empezar calibración"** for 10 seconds so the K-Means classifier learns each team's uniform color.
4. **Customize Indicators & Filters**: Tap the settings button during the match to customize player shapes, colors, or enable a daltonism/high-contrast camera filter.
5. **Track Score & Zoom**: Tap team scores in the top bar to increment/decrement goals and use the bottom-left control to zoom in or out.

---

## 🤝 Contributing

Contributions are welcome! Whether it's improving detection accuracy, adding new accessibility filters, localizing into more languages, or fixing bugs:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-accessibility-feature`)
3. Commit your changes (`git commit -m 'Add amazing accessibility feature'`)
4. Push to the branch (`git push origin feature/amazing-accessibility-feature`)
5. Open a Pull Request

---

## 👥 Authors & Credits

Created with ❤️ to make football more accessible for everyone:

- **Azuany Mila Cerón** — [@azu-any](https://github.com/azu-any) · [LinkedIn](https://www.linkedin.com/in/azuany-mila)
- **Nina Maeva Mazadiego Cortés** — [@MaeMazcort](https://github.com/MaeMazcort)
- **Daniela Renée Ramírez Gutiérrez** — [@danielarenee](https://github.com/danielarenee)
- **Goben Diego Constantino Aguirre** — [@PocketNugget](https://github.com/PocketNugget)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
