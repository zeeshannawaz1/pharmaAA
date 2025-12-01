# Feature-to-Widget Mapping

This table maps business feature codes (SRC-*, R-*, etc.) to their corresponding screen names, Dart files, and main widget/class names in the project.

| Feature Code | Screen Name                | Dart File (relative to lib/)                                 | Widget/Class Name            |
|--------------|----------------------------|--------------------------------------------------------------|------------------------------|
| SRC-1        | Daily Order Booking        | features/sales_order/presentation/pages/order_booking_layout_form.dart | OrderBookingLayoutForm       |
| SRC-3        | New Sales Order            | features/sales_order/presentation/pages/sales_order_page.dart | SalesOrderPage               |
| SRC-5        | Order Drafts               | features/sales_order/presentation/pages/order_drafts_page.dart | (to confirm)                 |
| SRC-8        | Enhanced Products          | features/products/presentation/pages/enhanced_products_page.dart | EnhancedProductsPage         |
| SRC-9        | Daily Order Booking (alt)  | features/sales_order/presentation/pages/daily_order_booking_page.dart | (to confirm)           |
| SRC-10       | (Stock Debug/Order?)       | features/sales_order/presentation/pages/sales_order_page.dart (stock debug logs) | SalesOrderPage?              |
| R-1          | Reports                    | features/reports/presentation/pages/reports_page.dart         | ReportsPage                  |
| SRC-11       | Login                      | features/auth/presentation/pages/login_page.dart             | LoginPage                    |
| SRC-12       | Products                   | features/products/presentation/pages/products_page.dart       | ProductsPage                 |
| SRC-13       | Enhanced Reports           | features/reports/presentation/pages/enhanced_reports_page.dart | EnhancedReportsPage       |
| SRC-14       | User Configuration         | features/auth/presentation/pages/user_configuration_page.dart | UserConfigurationPage     |
| SRC-15       | New Order Form             | features/sales_order/presentation/pages/new_order_form_page.dart | NewOrderFormPage         |

**Notes:**
- Update this file as you add new features or clarify feature codes.
- If a feature code or mapping is incorrect, please correct it here and notify the team. 