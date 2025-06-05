# Flutter Lab 2 - Login Page

This project is a part of **CST2335 - Mobile Graphical Interface Programming (Summer 2025)** lab work at **Algonquin College**. It demonstrates the use of basic Flutter widgets like `TextField`, `ElevatedButton`, `Image`, and simple state management with `setState()`.

## 💡 Lab Objective

The goal of Lab 2 is to create a **Login Page** with:

- Two text fields (one for login name and one password)
- A "Login" button that checks the entered password
- An image that changes based on whether the password is correct

---

## ✅ Features Implemented

- 🔐 **Password field** with `obscureText: true` to hide the input
- 👁️ **Show/Hide Password Toggle** using an eye icon
- 🔵 **"Login" button** with **blue, bold, and larger text**
- 🖼️ **Image** that changes dynamically:
  - Displays a **question mark** initially
  - Changes to a **light bulb** if the password is `"QWERTY123"`
  - Changes to a **stop sign** for any incorrect password



## 📁 Assets Used

Make sure to include the following images in your `images/` folder and register them in `pubspec.yaml`:

- `images/question-mark.jpg`
- `images/light-bulb.jpg`
- `images/stop-sign.jpg`

### Example `pubspec.yaml` section:
```yaml
flutter:
  assets:
    - images/question-mark.jpg
    - images/light-bulb.jpg
    - images/stop-sign.jpg
