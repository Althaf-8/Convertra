# Convertra

Convertra is a comprehensive, all-in-one Flutter application designed to handle a wide variety of daily conversion and calculation needs. From currency exchange rates to physical unit conversions and financial calculations, Convertra provides a modern, user-friendly interface to get quick answers.

## Features

Convertra organizes its tools into an accessible dashboard with search functionality, offering the following capabilities:

### 💱 Currency Conversion
- Real-time currency exchange rates.
- Support for a wide range of global currencies.

### 📏 Unit Converters
Extensive unit conversion tools for various physical properties:
- **Length / Distance**: Convert between meters, miles, feet, etc.
- **Area**: Square meters, acres, hectares, etc.
- **Mass / Weight**: Kilograms, pounds, stones, etc.
- **Volume / Capacity**: Liters, gallons, cups, etc.
- **Temperature**: Celsius, Fahrenheit, Kelvin.
- **Time / Duration**: Seconds, hours, days, years.
- **Speed / Velocity**: km/h, mph, knots.
- **Energy & Power**: Joules, calories, watts.
- **Data Storage**: Bytes, KB, MB, GB, TB.

### 🧮 Utility & Financial Calculators
- **Bill Splitter**: Easily calculate split bills and tips at restaurants.
- **Profit & Loss**: Calculate business or investment margins.
- **Fuel Economy**: Convert and calculate fuel efficiency.

## 📱 User Interface
- **Modern Dashboard**: A clean grid layout for quick access to all tools.
- **Search**: Built-in search bar to instantly find the converter you need.
- **Responsive Design**: Built with Google Fonts and a polished color scheme.

## Project Structure

The project is structured as follows:

- **`lib/main.dart`**: The entry point of the application.
- **`lib/screens/`**: Contains the UI implementations for most unit converters and utility calculators (e.g., `length_conversion_screen.dart`, `bill_split_screen.dart`).
- **`lib/currencyscreens/`**: Dedicated directory for currency conversion logic and screens.
- **`lib/widgets/`**: Reusable UI components.
- **`lib/constants/`**: App-wide constants.

## Tech Stack

- **Flutter & Dart**: Core framework and language.
- **Dio & Http**: For handling API requests (e.g., fetching exchange rates).
- **Google Fonts**: For typography.
- **Url Launcher**: For external link handling.

## Getting Started

To run this project locally:

1.  **Prerequisites**: Ensure you have Flutter installed and set up on your machine.
2.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd convertra
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the app**:
    ```bash
    flutter run
    ```

For more help with Flutter, verify the [online documentation](https://docs.flutter.dev/).
