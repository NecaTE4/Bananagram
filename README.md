
# 🍌 BananaGram — Social Media Photo Sharing App


![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white) ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black) ![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)


**A playful, Instagram-style social media application built with Flutter.**

BananaGram is a mobile photo-sharing platform where users can post images, like posts, leave comments, edit their profiles, and explore a dynamic feed. Designed with a fun monkey-banana themed visual style, the project demonstrates a full-stack social media workflow on the client side.

---

## 🚀 Features

### 🖼️ Photo Uploading
* **Selection:** Select an image from the device gallery.
* **Captioning:** Add descriptions to your photos.
* **Preview:** Review images before posting.
* **Feed:** Instantly display posted images in the main feed.

### ❤️ Likes & Interactions
* **Banana Likes:** Tap to like/unlike posts with custom animations.
* **Visuals:** Animated banana-themed icons.
* **Counters:** Real-time like count display per post.

### 💬 Comments System
* **Engagement:** Add comments to any post.
* **Overview:** View all comments in a list format.
* **Details:** Includes username and avatar.
* **Updates:** Real-time UI updates after adding a comment.

### 👤 Profile Management
* **Customization:** Edit username and profile picture.
* **Gallery:** View a grid of the user’s own posts.
* **Sync:** Real-time updates across the app after profile edits.

### ✨ UI/UX & Design
* **Theme:** Fun Monkey & Banana themed graphics.
* **Animations:** Smooth Lottie animations and transitions.
* **Performance:** Cached images for fast scrolling.
* **Branding:** Custom fonts (e.g., Billabong) and iconography.

### 🔒 Authentication
* Simple login screen (Mock/Placeholder flow).
* Email/Username-based login interface.

---

## 
# 📦 Architecture Breakdown

### **1.  `/models`**

Contains data models representing core objects:

-   **Post**  → image, caption, username, likes, comments
    
-   **Comment**  → comment text, username, timestamp
    

### **2.  `/screen`**

Screens that represent full pages:

-   **Feed Screen**  → shows list of posts
    
-   **Post Upload (image & text)**  → two-step posting flow
    
-   **Profile Screen**  → user details & posts
    
-   **Profile Edit Screen**  → updating user data
    
-   **Login Screen**  → simple login mock
    

### **3.  `/widgets`**

Reusable building blocks:

-   **Post widget**  → standardized post layout
    
-   **Comment widget**  → one-line comment item
    
-   **Navigation bar**  → bottom tab navigation
    
-   **Loading widget**  → consistent loading styles
    

### **4.  `/utils`**

Utility helpers:

-   **img_cached.dart**  → Image caching for smooth scrolling
    

### **5.  `assets/`**

-   Images for UI
    
-   Lottie animations: bananas, monkeys, interactions
    
-   Custom fonts (e.g., Billabong) for branding

## ⬇ Installation

### Clone the repository  
```
git clone https://github.com/NecaTE4/Bananagram.git
```
### Navigate to the project directory
```
cd BananaGram
```

### Install dependencies
```
flutter pub get
```

### Run the app
```
flutter run
```


## 🛠 Requirements

- Flutter SDK 3.x
- Dart: 3.x
- OS: Android 6.0+ / iOS 13+
- IDE: VSCode or Android Studio

## 👨‍💻 Developer

Author: NecaTE4
[Github](https://github.com/NecaTE4/)

## License
[MIT License](LICENSE) © 2025 NecaTE4
