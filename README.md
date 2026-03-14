# 🚗 GPS Speedometer App

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue)
![Dart](https://img.shields.io/badge/Dart-Language-blue)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![Status](https://img.shields.io/badge/Project-Active-brightgreen)

A modern **GPS-based Speedometer application built with Flutter** that allows users to track their **real-time speed, trip statistics, and travel history** while driving, cycling, or running.

The app uses **device GPS location services** to calculate speed and distance while presenting the information through **modern analog and digital gauges** with a clean and responsive user interface.

---

# 📱 Features

## 🚀 Real-Time Speed Tracking

* Displays **live speed using GPS location updates**
* Works for **cars, bicycles, motorcycles, and running**
* High refresh rate for accurate readings

## 🎛 Analog & Digital Speedometer

* Modern **analog gauge display**
* Minimal **digital speed display**
* Smooth UI animations for real-time speed updates

## 📊 Trip Analytics Dashboard

Track detailed trip statistics including:

* Current speed
* Maximum speed
* Total distance traveled
* Trip duration
* Average speed

## 🗺 Integrated Maps

* Map API integration for location tracking
* View travel routes and movement visually

## 📚 Ride History

Automatically stores previous trips.

Users can:

* View previous ride details
* Share trip statistics
* Delete trip history

## ⚙ Customizable Settings

Personalize the speedometer experience with:

* Speed unit selection (**km/h or mph**)
* Multiple **gauge styles**
* Speed warning alerts
* Permission management

## ⚡ Smooth Performance

Built with Flutter's optimized rendering engine to ensure:

* Smooth animations
* Responsive UI
* Efficient GPS data handling

---

# 🛠 Technologies Used

* **Flutter**
* **Dart**
* **GPS / Location Services**
* **Map API Integration**
* **Material UI**

---

# 📷 Screenshots



![Image](https://github.com/user-attachments/assets/f6db93ce-b06b-4e71-afe0-5d58eb03cad6)

![Image](https://github.com/user-attachments/assets/3ac1f274-ebdf-4db4-84d3-aece381fee40)

![Image](https://github.com/user-attachments/assets/a56a2624-f9b6-4ee7-86e9-99059decfb4d)

![Image](https://github.com/user-attachments/assets/5bc059b4-d0e9-4bd2-b5b1-621c71433820)

![Image](https://github.com/user-attachments/assets/5147c2bf-33b3-409a-8f60-34b7a77b20c3)

![Image](https://github.com/user-attachments/assets/a676abaf-eca9-4754-9476-a7b2cbe7f099)

![Image](https://github.com/user-attachments/assets/db9c0d03-3494-43a2-a611-ff3d23456178)

![Image](https://github.com/user-attachments/assets/d50ad227-4245-490d-a805-841c6b1e7ee8)

![Image](https://github.com/user-attachments/assets/67740f87-41ee-4ac9-9b00-8d720c3ed78b)

![Image](https://github.com/user-attachments/assets/d41e3ecc-da9f-4799-ba9c-0ae47366f63e)

![Image](https://github.com/user-attachments/assets/addd29f6-5b64-40f7-81f7-7756c0373c63)

![Image](https://github.com/user-attachments/assets/b0927e80-4742-4947-86a6-a047c14f62cc)

![Image](https://github.com/user-attachments/assets/dab3c240-74ef-4780-ab2a-6777eaf65384)



---

## 📂 Project Structure

```
speedometer_app
│
├── lib
│   │
│   ├── Database
│   │   └── database_helper.dart
│   │
│   ├── Model
│   │   └── tracking_history.dart
│   │
│   ├── Services
│   │   ├── SpeedAlertHelper.dart
│   │   ├── current_location_map.dart
│   │   ├── gps_status_service.dart
│   │   └── location_service.dart
│   │
│   ├── theme
│   │   └── theme configuration files
│   │
│   ├── widgets
│   │   ├── bottom_nav_bar.dart
│   │   ├── digital_meter.dart
│   │   ├── distance_tracking.dart
│   │   ├── gauge_meter.dart
│   │   ├── gauge_selection_screen.dart
│   │   ├── history.dart
│   │   ├── history_detail.dart
│   │   ├── meter_with_timer.dart
│   │   ├── permissions_screen.dart
│   │   ├── settings.dart
│   │   └── theme_selection_screen.dart
│   │
│   └── main.dart
│
├── linux
├── macos
├── web
├── windows
│
├── .gitignore
├── .gitattributes
└── pubspec.yaml
```

### 📦 Folder Overview

**Database**
Handles local data storage and database operations for saving ride history.

**Model**
Contains data models used in the application such as tracking history.

**Services**
Includes core functionality such as:

* GPS location tracking
* Speed calculation
* Map integration
* Speed alert system

**Widgets**
Reusable UI components used throughout the application such as gauges, navigation bar, settings, and history screens.

**Theme**
Manages theme configuration including UI styling and appearance settings.

**Main.dart**
Application entry point that initializes the Flutter app and loads the main interface.


# ⚙ Installation

### 1️⃣ Clone the Repository

```
git clone https://github.com/yourusername/speedometer-app.git
```

### 2️⃣ Navigate to the Project

```
cd speedometer-app
```

### 3️⃣ Install Dependencies

```
flutter pub get
```

### 4️⃣ Run the App

```
flutter run
```

---

# 🔑 Permissions Required

The application requires the following permissions:

* **Location Access** – to calculate speed and distance
* **Internet Access** – for map API integration

---

# 🚀 Future Improvements

Planned upgrades for future versions:

* Full **route tracking with trip map visualization**
* **Cloud backup** for ride history
* **Dark mode support**
* **Speed limit alerts**
* **Trip export and analytics dashboard**

---

# 👨‍💻 Author

**Muhammad Sameer Khan**

Software Engineering Student
Flutter & Mobile Application Developer

GitHub:
https://github.com/muhammadsameerkhan-edit20

---

# ⭐ Support

If you like this project, please consider **starring the repository** ⭐
