# A&A Pharma Test Project - Complete File Index

## Project Overview
This is a Flutter application for pharmaceutical sales and order management with backend PHP services.

## Root Directory Files

### Configuration Files
- `pubspec.yaml` - Flutter project dependencies and configuration
- `pubspec.lock` - Locked dependency versions
- `analysis_options.yaml` - Dart/Flutter code analysis rules
- `.gitignore` - Git ignore patterns
- `.metadata` - Flutter project metadata
- `rouftest1.iml` - IntelliJ IDEA project file

### Backend PHP Services
- `conn.php` - Database connection configuration
- `getUserLogin.php` - User authentication service
- `getOrclClients.php` - Client data retrieval service
- `getOrclProds.php` - Product data retrieval service
- `getDailySSR.php` - Daily sales report service
- `getclientarea.php` - Client area data service
- `getareasbytown.php` - Area data by town service
- `getclientcity.php` - Client city data service
- `getdata.php` - Generic data retrieval service
- `postSalOrders.php` - Sales order posting service
- `postSalOrdersCopy.php` - Sales order copy service
- `postSalOrdersCopy1.php` - Sales order copy service variant
- `postSalOrdersCopyFixed.php` - Fixed sales order copy service
- `postSalOrdersChk1.php` - Sales order check service
- `PostOrederCheck.php` - Order verification service
- `zee_postSalOrders.php` - Zee sales order posting service
- `zee_order_process.php` - Zee order processing service
- `zee_order_confirmed.php` - Zee order confirmation service
- `zee_order_confirmed_new.php` - New Zee order confirmation service
- `zee_postSalOrderOld.php` - Old Zee sales order service
- `test.php` - Testing service
- `hello.php` - Hello world service

### Backup Files
- `getUserLogin.php.bak` - Backup of user login service
- `getOrclProdsSel.php.bak` - Backup of product selection service
- `getOrclClients.php.bak` - Backup of client service
- `getDailySSR.php.bak` - Backup of daily sales report service

### Documentation
- `README.md` - Project readme
- `FEATURE_MAPPING.md` - Feature mapping documentation
- `to do list.txt` - Development todo list

### Log Files
- `build_log.txt` - Build process logs
- `flutter_error_log.txt` - Flutter error logs

## Flutter Application Structure

### Main Application Files
- `lib/main.dart` - Application entry point
- `lib/main_screen.dart` - Main application screen
- `lib/injection_container.dart` - Dependency injection configuration

### Core Module (`lib/core/`)

#### Widgets (`lib/core/widgets/`)
- `splash_screen.dart` - Application splash screen
- `auth_check_widget.dart` - Authentication verification widget
- `all_users_location_widget.dart` - User location tracking widget
- `booking_man_tracker_widget.dart` - Booking manager tracking widget

#### Services (`lib/core/services/`)
- `auth_service.dart` - Authentication service
- `confirmed_orders_service.dart` - Confirmed orders management
- `location_service.dart` - Location services
- Additional service files for core functionality

#### Database (`lib/core/database/`)
- `offline_database_service.dart` - Offline data storage service

#### Network (`lib/core/network/`)
- `api_client.dart` - HTTP API client

#### Error Handling (`lib/core/error/`)
- `exceptions.dart` - Custom exceptions
- `failures.dart` - Failure handling

#### Utilities (`lib/core/utils/`)
- `constants.dart` - Application constants
- `validators.dart` - Input validation utilities

#### Use Cases (`lib/core/usecases/`)
- `usecase.dart` - Base use case implementation

### Feature Modules (`lib/features/`)

#### Authentication (`lib/features/auth/`)
- **Data Layer:**
  - `data/datasources/auth_remote_data_source.dart` - Remote authentication data source
  - `data/models/user_model.dart` - User data model
  - `data/repositories/auth_repository_impl.dart` - Authentication repository implementation
- **Domain Layer:**
  - `domain/entities/user.dart` - User entity
  - `domain/repositories/auth_repository.dart` - Authentication repository interface
  - `domain/usecases/login_user.dart` - User login use case
- **Presentation Layer:**
  - `presentation/bloc/auth_bloc.dart` - Authentication state management
  - `presentation/bloc/auth_event.dart` - Authentication events
  - `presentation/bloc/auth_state.dart` - Authentication states
  - `presentation/pages/login_page.dart` - Login page
  - `presentation/pages/user_configuration_page.dart` - User configuration page
  - `presentation/widgets/login_form.dart` - Login form widget
  - `presentation/widgets/simple_login_form.dart` - Simplified login form

#### Products (`lib/features/products/`)
- **Data Layer:**
  - `data/datasources/products_remote_data_source.dart` - Remote product data source
  - `data/models/product_model.dart` - Product data model
  - `data/models/dummy_products.dart` - Sample product data
  - `data/repositories/products_repository_impl.dart` - Product repository implementation
- **Domain Layer:**
  - `domain/entities/product.dart` - Product entity
  - `domain/repositories/products_repository.dart` - Product repository interface
  - `domain/usecases/get_products.dart` - Product retrieval use case
- **Presentation Layer:**
  - `presentation/bloc/products_bloc.dart` - Product state management
  - `presentation/bloc/products_event.dart` - Product events
  - `presentation/bloc/products_state.dart` - Product states
  - `presentation/pages/products_page.dart` - Main products page
  - `presentation/pages/enhanced_products_page.dart` - Enhanced products view
  - `presentation/pages/products_layout_selector.dart` - Layout selection
  - `presentation/widgets/advanced_filter_sheet.dart` - Advanced filtering
  - `presentation/widgets/category_chips.dart` - Category selection
  - `presentation/widgets/filter_section.dart` - Filter controls

#### Reports (`lib/features/reports/`)
- **Data Layer:**
  - `data/datasources/daily_report_remote_data_source.dart` - Remote report data source
  - `data/models/daily_report_model.dart` - Daily report data model
  - `data/models/dummy_reports.dart` - Sample report data
  - `data/repositories/daily_report_repository_impl.dart` - Report repository implementation
- **Domain Layer:**
  - `domain/entities/daily_report.dart` - Daily report entity
  - `domain/repositories/daily_report_repository.dart` - Report repository interface
  - `domain/usecases/get_daily_reports.dart` - Report retrieval use case
- **Presentation Layer:**
  - `presentation/bloc/daily_report_bloc.dart` - Report state management
  - `presentation/bloc/daily_report_event.dart` - Report events
  - `presentation/bloc/daily_report_state.dart` - Report states
  - `presentation/pages/reports_page.dart` - Main reports page
  - `presentation/pages/enhanced_reports_page.dart` - Enhanced reports view
  - `presentation/widgets/category_performance_widget.dart` - Category performance display
  - `presentation/widgets/report_chart_widget.dart` - Chart visualization
- **Additional Files:**
  - `porder_page.dart` - Purchase order page

#### Sales Order (`lib/features/sales_order/`)
- **Data Layer:**
  - `data/datasources/clients_remote_data_source.dart` - Remote client data source
  - `data/datasources/order_draft_local_data_source.dart` - Local order draft storage
  - `data/datasources/products_remote_data_source.dart` - Remote product data source
  - `data/models/client_model.dart` - Client data model
  - `data/models/order_draft_model.dart` - Order draft data model
  - `data/models/product_model.dart` - Product data model
  - `data/repositories/clients_repository_impl.dart` - Client repository implementation
  - `data/repositories/order_draft_repository_impl.dart` - Order draft repository implementation
  - `data/repositories/products_repository_impl.dart` - Product repository implementation
- **Domain Layer:**
  - `domain/entities/client.dart` - Client entity
  - `domain/entities/order_draft.dart` - Order draft entity
  - `domain/entities/product.dart` - Product entity
  - `domain/repositories/order_draft_repository.dart` - Order draft repository interface
  - `domain/usecases/delete_order_draft.dart` - Order draft deletion use case
  - `domain/usecases/get_areas.dart` - Area retrieval use case
  - `domain/usecases/get_cities.dart` - City retrieval use case
- **Presentation Layer:**
  - `presentation/bloc/clients_cubit.dart` - Client state management
  - `presentation/bloc/order_draft_bloc.dart` - Order draft state management
  - `presentation/bloc/order_draft_event.dart` - Order draft events
  - `presentation/bloc/order_draft_state.dart` - Order draft states
  - `presentation/pages/confirmed_orders_page.dart` - Confirmed orders page
  - `presentation/pages/daily_order_booking_page.dart` - Daily order booking
  - `presentation/pages/new_order_form_page.dart` - New order creation
  - `presentation/pages/order_draft_page.dart` - Order draft management
  - `presentation/pages/order_summary_page.dart` - Order summary view

#### Insights (`lib/features/insights/`)
- **Presentation Layer:**
  - `presentation/pages/insights_page.dart` - Main insights page
  - `presentation/pages/sales_trends_page.dart` - Sales trends analysis

#### Home (`lib/features/home/`)
- **Presentation Layer:**
  - `presentation/pages/` - Home page implementations

## Platform-Specific Directories

### Android (`android/`)
- `app/build.gradle.kts` - Android app build configuration
- `app/google-services.json` - Google Services configuration
- `app/src/main/AndroidManifest.xml` - Main Android manifest
- `app/src/main/kotlin/` - Kotlin source code
- `app/src/main/res/` - Android resources (drawables, layouts, values)
- `build.gradle.kts` - Project build configuration
- `gradle.properties` - Gradle properties
- `settings.gradle.kts` - Gradle settings

### iOS (`ios/`)
- `Flutter/` - Flutter iOS configuration
- `Runner/` - iOS app runner
- `Runner.xcodeproj/` - Xcode project files
- `Runner.xcworkspace/` - Xcode workspace
- `Podfile` - CocoaPods dependencies

### Web (`web/`)
- `index.html` - Web app entry point
- `manifest.json` - Web app manifest
- `favicon.png` - Web app icon
- `icons/` - Web app icons

### Desktop Platforms
- `macos/` - macOS app configuration
- `windows/` - Windows app configuration
- `linux/` - Linux app configuration

## Assets

### Fonts (`assets/fonts/`)
- Poppins font family (35+ font files)
- License files (OFL.txt)

### Images (`assets/images/`)
- `logo.png` - Application logo

### CSV Data (`assets/csv/`)
- Data files for the application

## Testing
- `test/widget_test.dart` - Widget testing configuration

## Build and Development
- `build/` - Build output directory
- `.dart_tool/` - Dart tool cache
- `.flutter-plugins-dependencies` - Flutter plugin dependencies

## Notes
- The project follows a clean architecture pattern with clear separation of concerns
- Uses BLoC pattern for state management
- Implements repository pattern for data access
- Has comprehensive offline data handling capabilities
- Includes both Flutter mobile app and PHP backend services
- Supports multiple platforms (Android, iOS, Web, Desktop)

## File Count Summary
- **Total Files:** 100+ files
- **Dart Files:** 50+ files
- **PHP Files:** 30+ files
- **Configuration Files:** 20+ files
- **Asset Files:** 40+ files
- **Platform-Specific Files:** 100+ files
