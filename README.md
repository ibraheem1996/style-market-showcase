<div align="center">

# 🛍️ Style Market

### Flutter shopping app + Flutter Web admin dashboard

A complete fashion shopping experience built with Flutter, from browsing products and managing variants to checkout, orders, inventory, and store administration.

**Mobile App** · **Flutter Web Admin** · **REST API Integration**

</div>

---

## ✨ What is Style Market?

Style Market is an e-commerce project built around two Flutter applications:

| 📱 Customer App | 🖥️ Admin Dashboard |
| --- | --- |
| Browse and search products | Monitor store activity |
| View colors, sizes, prices, and stock | Manage products and variants |
| Cart and favorites | Manage product images and inventory |
| Addresses and checkout | Review and manage orders |
| Order history and details | Manage catalog content |
| Arabic and English support | Responsive Flutter Web interface |

The two applications communicate with the same REST API while keeping their UI, state, routing, and client logic separate.

---

## 📱 Customer App

The mobile app focuses on a smooth shopping flow from discovery to order tracking.

### Main experience

- 🔎 Product search, listing, sorting, and filters
- 👕 Product details with color and size variants
- ❤️ Favorites and shared favorite state
- 🛒 Cart with quantity, selection, and pricing logic
- 📍 Address management and phone verification
- 💳 Multi-step checkout
- 📦 Orders and order details
- 👀 Recently viewed products
- 🌍 Arabic and English localization
- 📐 Responsive and reusable UI components
- 🔐 Session and token handling
- 🔔 Notification integration

### Mobile preview

> Screenshots and a short walkthrough video will be added here.

<!--
Add mobile screenshots here.
Suggested order:
Home → Listing/Search → Product Details → Cart → Checkout → Order Details
-->

---

## 🖥️ Admin Dashboard

The Admin application is built with Flutter Web and focuses on store operations rather than a simple CRUD panel.

### Main experience

- 📊 Dashboard metrics and charts
- 📦 Order management and status actions
- 📝 Internal order notes
- 🛍️ Product and variant management
- 🖼️ Product media upload, ordering, and primary-image control
- 📉 Product lifecycle and deletion-impact checks
- 🌳 Category tree management
- 🧩 Collection item ordering and validation
- 🎯 Audience, banner, color, and size management
- 🧭 Session-aware routing
- 📐 Responsive sidebar and compact layouts

### Admin preview

> Dashboard and management screenshots will be added here.

<!--
Add admin screenshots here.
Suggested order:
Dashboard → Products → Product Media → Orders → Responsive narrow layout
-->

---

## 🚀 Engineering Highlights

The project includes more than screens and API calls. Some of the main engineering work includes:

### 🔄 Reliable client state

- Shared Cart and Favorites state across multiple screens
- Optimistic updates with rollback and reconciliation
- Protection against stale async responses
- Session-aware state cleanup
- Clear separation between screen state and shared application state

### 🌐 Networking & sessions

- Dio and Retrofit API integration
- Centralized request and authentication interceptors
- Token refresh and request retry handling
- Typed API failures instead of raw network errors
- Separate customer and admin session flows

### 📐 Responsive UI

- Centralized breakpoints and layout values
- Adaptive product grids and content widths
- Responsive Flutter Web shell
- Sidebar / compact navigation behavior
- Reusable typography, spacing, media, and theme rules

### 🧠 Business logic outside widgets

Examples include:

- Product variant selection rules
- Duplicate variant detection
- Cart pricing and local mutation logic
- Product deletion-impact checks
- Category tree operations
- Collection item validation and ordering
- Order filtering, pagination, and actions

---

## 🧭 Architecture

The project uses a **feature-first Flutter architecture**.

The Mobile app mainly uses **GetX**, while the Admin Dashboard uses **Cubit / Flutter Bloc** and **GoRouter**.

The architecture is kept practical: simple features stay simple, while complex flows get clearer state, domain, and data boundaries.

### 👉 [Read the Architecture Guide](docs/architecture.md)

The architecture guide explains the original project structure, state management, networking, routing, dependency injection, and data flow with simple diagrams.

---

## 🧰 Tech Stack

| Area | Technology |
| --- | --- |
| Mobile | Flutter, Dart, GetX |
| Admin Web | Flutter Web, Flutter Bloc / Cubit |
| Routing | GetX routing, GoRouter |
| Networking | Dio, Retrofit |
| Dependency Injection | GetIt, Injectable, GetX bindings |
| Models & State | Freezed, JSON serialization |
| Backend Communication | REST API |
| Firebase | Authentication, Messaging, Crashlytics, Analytics, Performance |
| Local Storage | Shared Preferences, secure/session storage |
| Testing | Flutter Test, mocks/fakes, Cubit tests |

---

## 🧪 Testing

Testing focuses on behavior that is easy to break and important to the user experience, such as:

- Async request ordering
- Cart and favorites mutations
- Authentication and session behavior
- Responsive layout rules
- Product variant logic
- Checkout state
- Order actions
- Dashboard mapping
- Product media operations

---

## 🔍 Explore the Code

This repository contains selected Flutter source from the real project.

The code samples focus on useful engineering examples rather than publishing every feature or every layer.

- 📱 [Mobile code samples](code-samples/mobile/)
- 🖥️ [Admin code samples](code-samples/admin/)
- 🧭 [Architecture](docs/architecture.md)

---

## 🎬 Demo & Screenshots

Planned additions:

- 📹 Short product walkthrough
- 📱 Mobile screenshots
- 🖥️ Admin Dashboard screenshots
- 🔗 APK / store link when available
- 🌐 Live Admin demo when available

---

## 🔒 Source Availability

The complete Style Market source is maintained privately.

---

<div align="center">

### Built with Flutter 💙

**Style Market — Mobile shopping + Web administration in one project**

</div>
