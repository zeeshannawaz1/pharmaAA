// Global validators for reuse across the app
class BookingManIdValidator {
  static String? validateBookingManId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Booking Man ID required';
    }
    
    // Check if it's a valid number
    final number = int.tryParse(value);
    if (number == null) {
      return 'Booking Man ID must be a number';
    }
    
    // Check if it's positive
    if (number <= 0) {
      return 'Booking Man ID must be a positive number';
    }
    
    return null; // Valid
  }
}

// Other global validators can be added here
class CommonValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
} 