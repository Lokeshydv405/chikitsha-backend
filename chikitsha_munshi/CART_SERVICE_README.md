# Cart Service Documentation

## Overview
The `CartService` class provides methods to interact with your backend cart API. It supports adding items, managing member selections, and removing items from the cart.

## Updated Features

### 1. **Get Cart Items**
```dart
final cartService = CartService();
final cartItems = await cartService.getCart(userId);
```

### 2. **Add Item to Cart**
```dart
await cartService.addCartItem(
  userId: "user123",
  packageId: "package456",
  members: [
    {"memberId": "member1", "selected": true},
    {"memberId": "member2", "selected": true},
  ],
);
```

### 3. **Update Member Selection**
```dart
// Add a member to a package
await cartService.updateMemberSelection(
  cartId: "cart123",
  memberId: "member1",
  action: "add",
);

// Remove a member from a package
await cartService.updateMemberSelection(
  cartId: "cart123",
  memberId: "member1",
  action: "remove",
);
```

### 4. **Helper Methods**
```dart
// Add member to cart (convenience method)
await cartService.addMemberToCart(
  cartId: "cart123",
  memberId: "member1",
);

// Remove member from cart (convenience method)
await cartService.removeMemberFromCartItem(
  cartId: "cart123",
  memberId: "member1",
);
```

### 5. **Remove Cart Item**
```dart
await cartService.removeCartItem("cart123");
```

## Data Models

### CartItem
- `id`: Cart item ID
- `userId`: User ID
- `packageInfo`: Package details (name, description, prices)
- `members`: List of selected members

### CartMember
- `id`: Member ID
- `name`: Member name
- `relation`: Relationship to user
- `gender`: Member gender (optional)
- `age`: Member age (optional)
- `selected`: Selection status

### PackageInfo
- `id`: Package ID
- `name`: Package name
- `description`: Package description (optional)
- `offerPrice`: Discounted price
- `originalPrice`: Original price

## Error Handling
All methods include proper error handling and will throw exceptions with descriptive messages if operations fail.

## Backend API Endpoints

The service connects to these endpoints:
- `GET /api/cart/{userId}` - Get cart items
- `POST /api/cart` - Add cart item
- `PATCH /api/cart/{cartId}/member/{memberId}` - Update member selection
- `DELETE /api/cart/{cartId}/member/{memberId}` - Remove member from cart
- `DELETE /api/cart/{cartId}` - Remove cart item

## Configuration
Make sure your `.env` file contains the correct server URL:
```
server=http://your-server-url:port
```
