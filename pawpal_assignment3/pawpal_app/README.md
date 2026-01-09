# 🐾 PawPal - Pet Adoption & Donation App

**PawPal** is a mobile application developed using Flutter and PHP/MySQL designed to bridge the gap between pet rescuers and potential adopters. It facilitates pet listings, adoption requests, and donations for pets in need.

**Course:** STTGK3013 Mobile Web Programming (A251)  
**Student:** Muhammad Syafiq Bin Suhairy (291214)  
**School of Computing, UUM**

---

## 📱 Features

### 1. Public Pet Listing & Search
- View all available pets in a grid layout.
- **Search:** Filter pets by name using the search bar.
- **Filter:** Sort pets by category (Cat, Dog, Other).

### 2. Adoption Module
- View detailed pet profiles (Name, Age, Description, Owner).
- **Request to Adopt:** Users can submit an adoption request with a motivation message (only if they are not the owner).
- **History:** Track status of past adoption requests.

### 3. Donation Module
- Donate to pets marked as "In Need" (`needs_donation = 1`).
- **Support Types:** Monetary donations or material goods (Food/Medical).
- **History:** Track personal donation history.

### 4. User Profile Management
- Register and Login secure system.
- **Edit Profile:** Update personal details.
- **Image Upload:** Crop and upload profile pictures (stored on server).

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** PHP (RESTful API)
- **Database:** MySQL (XAMPP)
- **State Management:** `setState` (StatefulWidgets)
- **External Packages:** - `http` (API requests)
  - `cached_network_image` (Image optimization)
  - `image_picker` & `image_cropper` (Profile photos)
  - `intl` (Date formatting)

---

## ⚙️ Installation & Setup Guide

To run this project locally, follow these steps:

### 1. Backend Setup (XAMPP)
1.  Download and install **XAMPP**.
2.  Start **Apache** and **MySQL** in the XAMPP Control Panel.
3.  **Database:**
    - Go to `http://localhost/phpmyadmin`.
    - Create a new database named `pawpal_db`.
    - Import the `pawpal_db.sql` file provided in this repository.
4.  **API Files:**
    - Copy the `pawpal_api` folder from `server/` to your XAMPP `htdocs` directory:
      `C:\xampp\htdocs\pawpal_api\`
    - Verify access by opening a browser and visiting: `http://localhost/pawpal_api/dbconnect.php` (Should show no errors).

### 2. Frontend Setup (Flutter)
1.  Clone this repository.
2.  Open the project in **VS Code** or **Android Studio**.
3.  Open terminal and run:
    ```bash
    flutter pub get
    ```
4.  **Configure IP Address:**
    - Open `lib/myconfig.dart`.
    - Change the IP address to your machine's local IPv4 address:
      ```dart
      static const String servername = "http://YOUR_IPV4_ADDRESS/pawpal_api";
      ```
    - *Tip: Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find your IP.*

### 3. Run the App
- Connect your physical device via USB or start an Android Emulator.
- Run the command:
  ```bash
  flutter run
