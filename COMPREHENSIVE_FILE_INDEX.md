# Comprehensive File Index - Flutter Sales Order Management App

## 📁 Project Overview
This is a Flutter application for sales order management with Clean Architecture, following feature-first organization with flutter_bloc for state management.

---

## 🏗️ Project Structure

### 📱 Flutter App Structure
```
lib/
├── core/                          # Shared/common code
├── features/                      # All app features
├── injection_container.dart      # Dependency injection
├── main_screen.dart              # Main app screen
└── main.dart                     # Entry point
```

---

## 📂 Core Directory (`lib/core/`)

### 🗄️ Database
- `database/offline_database_service.dart` - Local database service for offline functionality

### ❌ Error Handling
- `error/exceptions.dart` - Custom exceptions
- `error/failures.dart` - Failure classes for error handling

### 🌐 Network
- `network/api_client.dart` - HTTP client for API calls

### 🔧 Services
- `services/auth_service.dart` - Authentication service
- `services/confirmed_orders_service.dart` - Confirmed orders management
- `services/location_service.dart` - Location tracking service
- `services/offline_sync_service.dart` - Offline synchronization
- `services/town_area_service.dart` - Town and area management

### 🎯 Use Cases
- `usecases/usecase.dart` - Base use case interface

### 🛠️ Utils
- `utils/constants.dart` - App constants
- `utils/validators.dart` - Input validation utilities

### 🎨 Widgets
- `widgets/all_users_location_widget.dart` - Location tracking for all users
- `widgets/auth_check_widget.dart` - Authentication state checker
- `widgets/booking_man_tracker_widget.dart` - Booking manager tracking
- `widgets/debug_data_table.dart` - Debug data display
- `widgets/location_tracker_widget.dart` - Location tracking widget
- `widgets/main_app_widget.dart` - Main app widget
- `widgets/splash_screen.dart` - App splash screen

---

## 🎯 Features Directory (`lib/features/`)

### 🔐 Authentication Feature (`auth/`)

#### Data Layer
- `data/datasources/auth_remote_data_source.dart` - Remote authentication data source
- `data/models/user_model.dart` - User data model
- `data/repositories/auth_repository_impl.dart` - Authentication repository implementation

#### Domain Layer
- `domain/entities/user.dart` - User entity
- `domain/repositories/auth_repository.dart` - Authentication repository interface
- `domain/usecases/login_user.dart` - User login use case

#### Presentation Layer
- `presentation/bloc/`
  - `auth_bloc.dart` - Authentication bloc
  - `auth_event.dart` - Authentication events
  - `auth_event.freezed.dart` - Generated freezed events
  - `auth_state.dart` - Authentication states
  - `auth_state.freezed.dart` - Generated freezed states
- `presentation/pages/`
  - `login_page.dart` - Login page
  - `user_configuration_page.dart` - User configuration page
- `presentation/widgets/`
  - `login_form.dart` - Login form widget
  - `simple_login_form.dart` - Simplified login form

### 🏠 Home Feature (`home/`)
- `presentation/pages/` - Home page components

### 📊 Insights Feature (`insights/`)
- `presentation/pages/`
  - `insights_page.dart` - Main insights page
  - `sales_trends_page.dart` - Sales trends analysis

### 📦 Products Feature (`products/`)

#### Data Layer
- `data/datasources/products_remote_data_source.dart` - Products remote data source
- `data/models/`
  - `dummy_products.dart` - Dummy product data
  - `product_model.dart` - Product data model
- `data/repositories/products_repository_impl.dart` - Products repository implementation

#### Domain Layer
- `domain/entities/product.dart` - Product entity
- `domain/repositories/products_repository.dart` - Products repository interface
- `domain/usecases/get_products.dart` - Get products use case

#### Presentation Layer
- `presentation/bloc/`
  - `products_bloc.dart` - Products bloc
  - `products_event.dart` - Products events
  - `products_event.freezed.dart` - Generated freezed events
  - `products_state.dart` - Products states
  - `products_state.freezed.dart` - Generated freezed states
- `presentation/pages/`
  - `enhanced_products_page.dart` - Enhanced products page
  - `products_layout_selector.dart` - Products layout selector
  - `products_page.dart` - Main products page
- `presentation/pages/widgets/`
  - `advanced_filter_sheet.dart` - Advanced filtering
  - `category_chips.dart` - Category selection chips
  - `filter_section.dart` - Filter section widget
  - `product_card.dart` - Product card widget
  - `product_details_modal.dart` - Product details modal

### 📈 Reports Feature (`reports/`)

#### Data Layer
- `data/datasources/daily_report_remote_data_source.dart` - Daily reports data source
- `data/models/`
  - `daily_report_model.dart` - Daily report model
  - `dummy_reports.dart` - Dummy report data
- `data/repositories/daily_report_repository_impl.dart` - Daily reports repository implementation

#### Domain Layer
- `domain/entities/daily_report.dart` - Daily report entity
- `domain/repositories/daily_report_repository.dart` - Daily reports repository interface
- `domain/usecases/get_daily_reports.dart` - Get daily reports use case

#### Presentation Layer
- `presentation/bloc/`
  - `daily_report_bloc.dart` - Daily reports bloc
  - `daily_report_event.dart` - Daily reports events
  - `daily_report_event.freezed.dart` - Generated freezed events
  - `daily_report_state.dart` - Daily reports states
  - `daily_report_state.freezed.dart` - Generated freezed states
- `presentation/pages/`
  - `enhanced_reports_page.dart` - Enhanced reports page
  - `reports_page.dart` - Main reports page
- `presentation/pages/widgets/` - Report widgets (5 files)
- `presentation/widgets/` - Additional report widgets
- `porder_page.dart` - Purchase order page

### 🛒 Sales Order Feature (`sales_order/`) - **Main Feature**

#### Data Layer
- `data/datasources/`
  - `clients_remote_data_source.dart` - Clients remote data source
  - `order_draft_local_data_source.dart` - Order drafts local data source
  - `products_remote_data_source.dart` - Products remote data source
  - `stock_remote_data_source.dart` - Stock remote data source
- `data/models/`
  - `client_model.dart` - Client data model
  - `order_draft_model.dart` - Order draft data model
  - `product_model.dart` - Product data model
- `data/repositories/`
  - `clients_repository_impl.dart` - Clients repository implementation
  - `order_draft_repository_impl.dart` - Order drafts repository implementation
  - `products_repository_impl.dart` - Products repository implementation
  - `stock_repository_impl.dart` - Stock repository implementation

#### Domain Layer
- `domain/entities/`
  - `client.dart` - Client entity
  - `order_draft.dart` - Order draft entity
  - `product.dart` - Product entity
- `domain/repositories/order_draft_repository.dart` - Order drafts repository interface
- `domain/usecases/`
  - `delete_order_draft.dart` - Delete order draft use case
  - `get_areas.dart` - Get areas use case
  - `get_cities.dart` - Get cities use case
  - `get_clients.dart` - Get clients use case
  - `get_order_drafts.dart` - Get order drafts use case
  - `get_products.dart` - Get products use case
  - `get_stock.dart` - Get stock use case
  - `save_order_draft.dart` - Save order draft use case

#### Presentation Layer
- `presentation/bloc/`
  - `clients_cubit.dart` - Clients state management
  - `order_draft_bloc.dart` - Order drafts bloc
  - `order_draft_bloc.freezed.dart` - Generated freezed bloc
  - `order_draft_event.dart` - Order drafts events
  - `order_draft_state.dart` - Order drafts states
  - `products_cubit.dart` - Products state management
  - `stock_cubit.dart` - Stock state management
- `presentation/pages/`
  - `confirmed_orders_page.dart` - Confirmed orders page
  - `daily_order_booking_page.dart` - Daily order booking page
  - `new_order_form_page.dart` - New order form page
  - `order_booking_layout_form.dart` - Order booking layout form
  - `order_drafts_page.dart` - **Order drafts page (main page)**
  - `order_summary_page.dart` - Order summary page
  - `sales_order_page.dart` - Sales order page

---

## 🌐 Backend PHP Files

### 🔌 Database Connection
- `conn.php` - Database connection configuration

### 👤 User Management
- `getUserLogin.php` - User login endpoint
- `getUserLogin.php.bak` - Backup of user login

### 🏢 Client Management
- `getOrclClients.php` - Get Oracle clients
- `getOrclClients.php.bak` - Backup of Oracle clients
- `getclientcity.php` - Get client cities
- `getclientarea.php` - Get client areas
- `getareasbytown.php` - Get areas by town

### 📦 Product Management
- `getOrclProds.php` - Get Oracle products
- `getOrclProdsSel.php` - Get Oracle product selections
- `getOrclProdsSel.php.bak` - Backup of product selections

### 📊 Reports & Data
- `getDailySSR.php` - Get daily SSR reports
- `getDailySSR.php.bak` - Backup of daily SSR
- `getdata.php` - General data retrieval

### 🛒 Order Processing
- `postSalOrders.php` - Post sales orders
- `postSalOrdersChk1.php` - Post sales orders check 1
- `postSalOrdersCopy.php` - Post sales orders copy
- `postSalOrdersCopy1.php` - Post sales orders copy 1
- `postSalOrdersCopyFixed.php` - Post sales orders copy fixed
- `PostOrederCheck.php` - Post order check

### 🔄 ZEE Order Processing
- `zee_order_confirmed.php` - ZEE order confirmed
- `zee_order_confirmed_new.php` - ZEE order confirmed new
- `zee_order_process.php` - ZEE order process
- `zee_postSalOrderOld.php` - ZEE post sales order old
- `zee_postSalOrders.php` - ZEE post sales orders

### 🧪 Testing & Utilities
- `test.php` - Test file
- `hello.php` - Hello world test

---

## 📱 Platform-Specific Files

### 🤖 Android (`android/`)
- `app/build.gradle.kts` - Android app build configuration
- `app/google-services.json` - Google services configuration
- `app/src/` - Android source files
- `build.gradle.kts` - Android project build configuration
- `gradle.properties` - Gradle properties
- `settings.gradle.kts` - Gradle settings

### 🍎 iOS (`ios/`)
- `Flutter/` - Flutter iOS configuration
- `Podfile` - CocoaPods dependencies
- `Runner/` - iOS app runner
- `Runner.xcodeproj/` - Xcode project
- `Runner.xcworkspace/` - Xcode workspace
- `RunnerTests/` - iOS tests

### 🐧 Linux (`linux/`)
- `CMakeLists.txt` - CMake configuration
- `flutter/` - Flutter Linux configuration
- `runner/` - Linux app runner

### 🖥️ macOS (`macos/`)
- `Flutter/` - Flutter macOS configuration
- `Podfile` - CocoaPods dependencies
- `Runner/` - macOS app runner
- `Runner.xcodeproj/` - Xcode project
- `Runner.xcworkspace/` - Xcode workspace
- `RunnerTests/` - macOS tests

### 🪟 Windows (`windows/`)
- `CMakeLists.txt` - CMake configuration
- `flutter/` - Flutter Windows configuration
- `runner/` - Windows app runner

### 🌐 Web (`web/`)
- `favicon.png` - Web favicon
- `icons/` - Web app icons
- `index.html` - Web app entry point
- `manifest.json` - Web app manifest

---

## 📋 Configuration Files

### 📦 Flutter Configuration
- `pubspec.yaml` - Flutter dependencies and configuration
- `pubspec.lock` - Locked dependency versions
- `analysis_options.yaml` - Dart analysis options

### 📚 Documentation
- `README.md` - Project documentation
- `PROJECT_INDEX.md` - Project index
- `FEATURE_MAPPING.md` - Feature mapping documentation
- `to do list.txt` - Todo list

### 🧪 Testing
- `test/widget_test.dart` - Widget tests

### 📊 Assets
- `assets/fonts/` - Custom fonts (Poppins family - 36 TTF files)
- `assets/images/logo.png` - App logo
- `assets/csv/` - CSV data files

### 📁 Data & Logs
- `offline_data/` - Offline data storage
- `build_log.txt` - Build logs
- `flutter_error_log.txt` - Flutter error logs

---

## 🏗️ Build Files
- `build/` - Build output directory (contains compiled files, APKs, etc.)
- `.dart_tool/` - Dart tooling cache
- `admin/` - Admin-related files

---

## 📊 File Statistics

### 📱 Dart Files: 124 files
- Core: 19 files
- Features: 94 files
- Main: 3 files
- Tests: 1 file
- Generated: 7 files

### 🌐 PHP Files: 23 files
- Order Processing: 10 files
- Data Retrieval: 8 files
- Testing: 2 files
- Backups: 3 files

### 🎨 Asset Files: 40+ files
- Fonts: 36 TTF files
- Images: 1 PNG file
- Icons: 4 PNG files

### ⚙️ Configuration Files: 15+ files
- Flutter: 3 files
- Platform-specific: 12+ files
- Documentation: 4 files

---

## 🎯 Key Features

1. **🔐 Authentication System** - User login and configuration
2. **🛒 Sales Order Management** - Complete order lifecycle
3. **📦 Product Management** - Product catalog and stock
4. **👥 Client Management** - Client and area management
5. **📊 Reporting System** - Daily reports and insights
6. **🌐 Offline Support** - Local database and sync
7. **📍 Location Tracking** - GPS and location services
8. **🔄 Real-time Sync** - Online/offline synchronization

---

## 🏛️ Architecture

- **Clean Architecture** with clear separation of concerns
- **Feature-first organization** for better maintainability
- **flutter_bloc** for state management
- **Dependency injection** with GetIt
- **Repository pattern** for data access
- **Use case pattern** for business logic
- **Freezed** for immutable data classes

---

*Generated on: $(date)*
*Total Files Indexed: 200+ files*
