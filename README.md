# Flutter Odoo Sales App

A Flutter mobile application built for a sales team to interact with an Odoo ERP system.

The application provides authentication, customer management, and sales order operations through Odoo's API.

## Features

### Authentication

* Login using Odoo username and password.
* Authentication against the Odoo server.
* Displays appropriate error messages for failed login attempts.

### Customers

* Fetches customers from Odoo (`res.partner`).
* Displays:

  * Customer name
  * Phone number
  * City
* Search customers by name.
* View customer details.
* Update and save the customer's phone number directly to Odoo.

### Sales Orders

Available to internal Odoo users.

* View sales orders from Odoo (`sale.order`).
* Display:

  * Order number
  * Customer
  * Order date
  * Status
* View order details.
* Display order products and totals.
* Confirm quotations/sale orders when applicable.

## Tech Stack

* **Flutter**
* **Dart**
* **Provider** – State management
* **HTTP** – API communication
* **Odoo ERP** – Backend / ERP system

## Project Structure

```text
lib/
├── models/
│   ├── customer.dart
│   └── sale_order.dart
│
├── providers/
│   └── odoo_provider.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── customers_screen.dart
│   ├── customer_details_screen.dart
│   ├── orders_screen.dart
│   └── order_details_screen.dart
│
├── services/
│   └── odoo_api.dart
│
└── main.dart
```

## Architecture

The application follows a simple separation of responsibilities:

```text
UI / Screens
     │
     ▼
OdooProvider
     │
     ▼
OdooApi
     │
     ▼
Odoo ERP
```

### OdooApi

Responsible for communication with the Odoo backend, including:

* Authentication
* RPC/API calls
* Reading records
* Searching records
* Updating records
* Calling Odoo model methods

### OdooProvider

Uses `ChangeNotifier` to manage application state and expose data and operations to the Flutter UI.

This includes authentication state, customers, sales orders, loading states, and errors.

## Odoo Integration

The application communicates with standard Odoo models and operations, including:

### `res.partner`

Used for customer management.

```text
customer_rank > 0
```

Customer information is retrieved and updated through Odoo.

### `sale.order`

Used for sales order management.

The application can retrieve orders, display their details, and confirm applicable quotations/orders using Odoo's corresponding model method.

### Internal Users

The application checks the authenticated user's Odoo permissions/group membership to determine whether Sales Order functionality should be available.

## Getting Started

### Prerequisites

Make sure you have:

* Flutter SDK installed
* Dart SDK
* Android Studio or another Flutter-compatible IDE
* Access to an Odoo server
* Valid Odoo credentials

### Installation

Clone the repository:

```bash
git clone <repository-url>
```

Navigate to the project:

```bash
cd odoo_sales_app
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Configuration

Before running the application, configure the Odoo server connection according to the project's configuration.

The application requires:

```text
Odoo Server URL
Database Name
Username
Password
```

**Do not commit real credentials or sensitive production configuration to the repository.**

## Error Handling

The application provides basic handling for:

* Invalid login credentials
* API errors
* Connection failures
* Loading states
* Empty results
* Failed update operations

## Future Improvements

With additional development time, the following could be added:

* Offline customer caching
* Offline edits with synchronization when connectivity is restored
* Persistent authentication/session handling
* Pagination for large customer and sales order datasets
* More detailed API error handling
* Improved form validation
* Unit and widget tests
* More comprehensive UI/UX improvements
* Better handling of network connectivity changes

## Notes

This project was developed as part of a Flutter Mobile Developer technical assessment, with a focus on implementing the requested core functionality within the available development time.
