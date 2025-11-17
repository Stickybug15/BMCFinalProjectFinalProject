# Project Blueprint

## Overview

This document outlines the architecture, features, and implementation details of the Flutter application. It serves as a single source of truth for the project's design and functionality.

## Style and Design

The application follows Material Design principles, with a modern and visually appealing user interface. The color scheme, typography, and component styles are defined in the `ThemeData` object.

## Features

- **User Authentication:** Secure user authentication with Firebase Auth, including sign-up, login, and session management.
- **Product Catalog:** A comprehensive product catalog with detailed product information, images, and pricing.
- **Shopping Cart:** A fully functional shopping cart that allows users to add, remove, and manage items.
- **Order Management:** A complete order management system that allows users to place orders, track their status, and view their order history.
- **Admin Panel:** A powerful admin panel that allows administrators to manage products, orders, and users.
- **Real-time Chat:** A real-time chat feature that allows users to communicate with administrators.
- **Push Notifications:** A push notification system that keeps users informed about their orders and other important updates.

## Error Handling and Crash Reporting

- **Firebase Crashlytics:** Firebase Crashlytics is used to monitor and analyze crashes, providing valuable insights into the application's stability.

## Current Task: Fix `FirebaseException` in `NotificationService`

### Plan

1.  **Add SHA-1 and SHA-256 Fingerprints to Firebase Project:** Add the SHA-1 and SHA-256 fingerprints to the Firebase project to resolve the `AUTHENTICATION_FAILED` error.
2.  **Add Error Handling to `NotificationService`:** Add error handling to the `NotificationService` to prevent crashes and provide clearer logs if any issues occur with Firebase Cloud Messaging.
