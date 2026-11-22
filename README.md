# App Translator — Scan Result Flow

A production-grade Flutter application implementing the **Scan & Translate** flow, built following the **Feature-First Clean Architecture** and conventions from `customer_new_app`.

---

## 📱 Features & Highlights

1. **Scan Screen**:
   * Pick an image from the **Camera** or **Gallery** via `image_picker`.
   * Live image preview with aspect ratio constraints.
   * Primary **Translate** action button (disabled until an image is chosen).
   * In-app language toggle (English ⇄ Arabic) with immediate RTL/LTR mirroring.

2. **Result Screen & The 4 Handled States**:
   * **Loading State**: Circular progress indicator with brand theme styling.
   * **Success State**: Displays picked image, Confidence Badge (`High`, `Medium`, `Low`), Detected Signs count pill, and the translated text according to the active language.
   * **Error State**: Server failure card with dedicated retry mechanism.
   * **No Internet State**: Offline indicator with dedicated retry mechanism.
   * **Interactive Debug Switch**: Live segmented selector enabling testers to switch between `Success`, `Server Error`, and `No Internet` scenarios seamlessly.

3. **Design Tokens (Zero Hardcoding)**:
   * Stored in [`assets/tokens/tokens.json`](assets/tokens/tokens.json).
   * Loaded asynchronously at startup and accessed via `AppTokens` and `BuildContext` extensions:
     * Colors: `context.colors.bg`, `context.colors.surface`, `context.colors.brand`, `context.colors.textPrimary`, `context.colors.textSecondary`, `context.colors.error`.
     * Spacing: `context.spacing.sm`, `context.spacing.md`, `context.spacing.lg`, `context.spacing.insetsMd`, etc.
     * Radius: `context.radius.borderMd`, `context.radius.borderLg`.
   * No hardcoded color hexes, margins, paddings, or border radii in widgets.

4. **Bi-Directional Localization (English & Arabic)**:
   * Powered by `easy_localization` using [`assets/translations/en.json`](assets/translations/en.json) and [`assets/translations/ar.json`](assets/translations/ar.json).
   * UI components and text align properly and mirror automatically in Arabic (RTL).

---

## 🛠️ Architecture & Engineering Decisions

### 1. State Management: Why BLoC / Cubit?
For a real-world enterprise app, **`flutter_bloc` (Cubit)** was chosen because:
* **Separation of Concerns**: Strictly decouples business and translation logic from presentation widgets.
* **Unidirectional Data Flow**: State transitions are immutable, predictable, and traceable.
* **First-Class Testability**: Facilitates deterministic state testing using `bloc_test` and `mocktail`.
* **Consistency with Enterprise Baseline**: Mirrors the exact state management and dependency injection patterns utilized in `customer_new_app`.

### 2. Functional Error Handling with `dartz`
Following the repository pattern from `customer_new_app`, the fake repository returns:
```dart
Future<Either<Failure, TranslationResult>> translateImage({...})
```
Failures are strongly typed as `ServerFailure` and `NoInternetFailure`, allowing the Cubit to fold results cleanly and emit unambiguous UI states.

### 3. Folder Structure
```text
lib/
├── core/
│   ├── data/
│   │   └── error/           # Failure and AppException definitions
│   ├── services/
│   │   └── dependency_injection/ # GetIt Service Locator (sl)
│   └── tokens/              # AppTokens parser & BuildContext extensions
└── features/
    └── scan/
        ├── data/
        │   ├── models/      # TranslationResult model
        │   └── remote/      # ScanRepository & FakeScanRepositoryImpl (1.5s delay)
        └── presentation/
            ├── view_model/  # ScanCubit & ScanState (Equatable)
            ├── view/        # ScanScreen & ResultScreen
            └── widgets/     # ConfidenceBadge, DebugSwitchWidget
```

---

## 🚀 How to Run the App

### Prerequisites
* Flutter SDK (version `>=3.13.7`)
* Dart SDK (version `>=3.13.7`)

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Run the App
```bash
# Run on an attached device or simulator
flutter run
```

### Step 3: Run Static Analysis & Tests
```bash
# Run static analysis
dart analyze

# Run all unit and token tests
flutter test
```

---

## 🧪 Test Coverage

Tests are located in the `test/` directory:
* [`test/scan_cubit_test.dart`](test/scan_cubit_test.dart): Unit tests covering:
  * **The Error Path**: Validates emission of `[ScanStatus.loading, ScanStatus.error]` when `ServerFailure` occurs.
  * **The No Internet Path**: Validates emission of `[ScanStatus.loading, ScanStatus.noInternet]` when `NoInternetFailure` occurs.
  * **The Success Path**: Validates emission of `[ScanStatus.loading, ScanStatus.success]` with `TranslationResult`.
  * **Validation**: Enforces image selection before translating.
* [`test/tokens_test.dart`](test/tokens_test.dart): Validates exact token JSON parsing, hex color translation, and derived spacing/radius helpers.
* [`test/model_test.dart`](test/model_test.dart): Validates JSON serialization and multilingual translation retrieval.

---

## 🔮 What I Would Change With More Time

1. **Real Machine Learning & OCR Integration**:
   * Integrate on-device ML (e.g. Google ML Kit Digital Ink Recognition / Text Recognition) or a Vision API backend.
2. **Interactive Sign Bounding Boxes**:
   * Render bounding box overlays on top of the scanned image so users can tap individual detected hieroglyphs/signs to view per-sign definitions.
3. **Local History & Caching**:
   * Use Hive / SQLite to save past translation scans with offline access, search, and bookmarking.
4. **Speech Synthesis (TTS)**:
   * Provide audio pronunciation for both English and Arabic translations.
5. **End-to-End Integration Tests**:
   * Automate full user journey tests using Flutter Driver / `integration_test` covering camera selection, translation, error recovery, and locale switching.
