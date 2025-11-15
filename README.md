# 💰 Finance App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter-based personal finance management application with modern UI/UX and robust backend integration.

## 🚀 Features

### 📊 **Dashboard & Analytics**

- **Net Worth Tracking**: Visual charts showing financial progress over time
- **Cash Flow Analysis**: Monthly income vs expense breakdown
- **Upcoming Bills**: Smart reminders for upcoming payments
- **Financial Health Score**: AI-powered financial wellness assessment

### 💳 **Transaction Management**

- **Income & Expense Tracking**: Categorize and monitor all financial activities
- **Transfer Between Accounts**: Seamless money movement tracking
- **Recurring Transactions**: Automated recurring payment management
- **Smart Categorization**: AI-suggested transaction categories

### 🎯 **Goal Management**

- **Financial Goals**: Set and track progress towards financial objectives
- **Progress Visualization**: Visual progress bars and milestone tracking
- **Goal Funding**: Transfer funds from accounts to goals

### 📈 **Budget & Planning**

- **Monthly Budgets**: Set spending limits by category
- **Auto-Budget Suggestions**: AI-powered budget recommendations
- **Spending Analysis**: Detailed breakdown of expenses
- **Budget Reports**: Monthly budget performance insights

### 🏦 **Asset & Debt Management**

- **Asset Portfolio**: Track all your assets and investments
- **Debt Tracking**: Monitor loans, credit cards, and receivables
- **Net Worth Calculation**: Real-time financial position assessment

### 🔐 **Security & Authentication**

- **Firebase Authentication**: Secure email/password and Google Sign-In
- **Cloud Firestore**: Real-time data synchronization
- **User Privacy**: Individual user data isolation

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.7+ with Material Design 3
- **State Management**: Riverpod for reactive state management
- **Backend**: Firebase (Authentication, Firestore)
- **Charts**: fl_chart for data visualization
- **Localization**: Internationalization support (Indonesian)
- **Animations**: Lottie for smooth animations

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **macOS** (10.14+)
- ✅ **Windows** (Windows 10+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.7.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/syaha-creator/finance_app.git
   cd finance_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication and Firestore
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective platform folders

4. **Run the app**

   ```bash
   flutter run
   ```

## 📁 Project Structure

```bash
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App constants
│   ├── theme/             # App theming
│   └── utils/             # Utility functions
├── features/               # Feature modules
│   ├── authentication/    # User authentication
│   ├── dashboard/         # Main dashboard
│   ├── transaction/       # Transaction management
│   ├── budget/            # Budget planning
│   ├── goals/             # Financial goals
│   ├── asset/             # Asset management
│   ├── debt/              # Debt tracking
│   ├── financial_health/  # Financial analysis
│   ├── reports/           # Financial reports
│   └── settings/          # App settings
└── widgets/                # Shared widgets
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key
```

### Firebase Configuration

1. Enable Authentication methods (Email/Password, Google)
2. Set up Firestore security rules
3. Configure Firestore indexes for queries

## 📊 Key Features Implementation

### State Management with Riverpod

- **Provider Pattern**: Clean separation of concerns
- **Auto-dispose**: Memory-efficient state management
- **Stream Integration**: Real-time data updates

### Real-time Data Sync

- **Firestore Streams**: Live data updates
- **Offline Support**: Local data caching
- **Batch Operations**: Atomic database updates

### Responsive Design

- **Material Design 3**: Modern UI components
- **Adaptive Layout**: Works on all screen sizes
- **Dark/Light Theme**: User preference support

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 📦 Building

### Android APK

```bash
flutter build apk --release
```

### iOS IPA

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Riverpod for state management
- fl_chart for beautiful charts
- Lottie for smooth animations

## 📞 Support

If you have any questions or need help:

- Create an issue on GitHub
- Contact: <msyahrul090@gmail.com>

---

## 🎨 Made with ❤️ using Flutter
