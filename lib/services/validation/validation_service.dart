class ValidationService {
  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Simple email validation
    if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email address';
    }

    // Check if email has characters before @ and after .
    final parts = value.split('@');
    if (parts.length != 2) return 'Enter a valid email address';

    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.isEmpty) return 'Enter a valid email address';
    if (!domainPart.contains('.')) return 'Enter a valid email address';

    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Optional: Add more password requirements
    // if (!RegExp(r'[A-Z]').hasMatch(value)) {
    //   return 'Password must contain at least one uppercase letter';
    // }
    // if (!RegExp(r'[0-9]').hasMatch(value)) {
    //   return 'Password must contain at least one number';
    // }

    return null;
  }

  // Validate name (first name, last name)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    if (value.length > 50) {
      return '$fieldName is too long';
    }

    // Check if contains only letters, spaces, hyphens, apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-'']+$").hasMatch(value)) {
      return '$fieldName can only contain letters';
    }

    return null;
  }

  // Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove non-digits
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Phone number must be 10-15 digits';
    }

    return null;
  }

  // Validate OTP
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  // Confirm password match
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}
