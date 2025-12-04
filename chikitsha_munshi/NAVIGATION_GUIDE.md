# Cart to Booking Navigation Guide

## Overview
This guide explains how to navigate from the CartPage to the BookingPage and what data is passed between them.

## Navigation Flow

### 1. **Cart Page → Booking Page**
When the user clicks "Book Now" on the CartPage, the following happens:

```dart
// In CartPage.dart
void _navigateToBooking() {
  final bookingData = {
    'userId': widget.userId,
    'cartItems': [...], // Cart items with selected members
    'totalAmount': discountedAmount,
    'originalAmount': orderAmount,
    'discount': totalDiscount,
  };

  Navigator.pushNamed(
    context,
    '/booking',
    arguments: bookingData,
  );
}
```

### 2. **Data Structure Passed to Booking**
The `bookingData` contains:

- **userId**: Current user ID
- **cartItems**: Array of cart items with:
  - `packageId`: Test package ID
  - `packageName`: Test package name
  - `price`: Discounted price
  - `originalPrice`: Original price
  - `selectedMembers`: Array of selected family members
- **totalAmount**: Final amount to pay
- **originalAmount**: Total original amount
- **discount**: Total discount amount

### 3. **Booking Page Features**
The BookingPage includes:

- **Booking Summary**: Shows all packages and selected members
- **Price Breakdown**: Original amount, discount, and total
- **Address Selection**: For sample collection (placeholder)
- **Time Slot Selection**: For appointment booking (placeholder)
- **Confirm Booking Button**: Final booking confirmation

## Usage Examples

### Basic Navigation
```dart
// Navigate to booking page
Navigator.pushNamed(context, '/booking', arguments: bookingData);
```

### Alternative Direct Navigation
```dart
// Direct navigation with MaterialPageRoute
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingPage(
      userId: widget.userId,
      bookingData: bookingData,
    ),
  ),
);
```

## Route Configuration

The booking route is configured in `main.dart`:

```dart
routes: {
  '/booking': (context) => BookingPage(userId: '688217fd660df33b9a85f42c'),
  // ... other routes
}
```

## Next Steps

To complete the booking flow, you can:

1. **Add Address Management**: Create address selection/addition functionality
2. **Add Time Slot Selection**: Implement date/time picker for appointments
3. **Add Payment Integration**: Connect with payment gateway
4. **Add Booking Confirmation**: Store booking details in backend
5. **Add Order Tracking**: Show booking status and updates

## Files Involved

- `lib/screens/profile/cart/CartPage.dart` - Cart page with navigation
- `lib/screens/booking/BookingPage.dart` - Booking page (created)
- `lib/main.dart` - Route configuration
- `lib/core/services/cart_services.dart` - Cart service for data

## Button States

The "Book Now" button is:
- **Enabled**: When at least one member is selected (`hasSelectedMembers = true`)
- **Disabled**: When no members are selected (`hasSelectedMembers = false`)

This ensures users can only proceed to booking when they have valid selections.
