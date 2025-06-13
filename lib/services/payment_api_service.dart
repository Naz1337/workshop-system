// Abstract class representing the interface for payment services.
// Any payment method (e.g., DuitNow, IPay88) must implement this contract.
abstract class PaymentAPIService {

  // Processes the payment with the given parameters.
  // Returns true if payment is successful, otherwise false.
  Future<bool> processPayment({
    required double amount,
    required String method,
    required String recipient,
  });
}

// Concrete implementation of PaymentAPIService for DuitNow.
// Simulates processing a DuitNow payment.
class DuitNowPaymentService implements PaymentAPIService {
  @override
  Future<bool> processPayment({
    required double amount,
    required String method,
    required String recipient,
  }) async {
    // Integration with actual DuitNow API
    await Future.delayed(const Duration(seconds: 2));
    return true; // Simulate success
  }
}

// Concrete implementation of PaymentAPIService for IPay88.
// Simulates processing an IPay88 payment.
class IPay88PaymentService implements PaymentAPIService {
  @override
  Future<bool> processPayment({
    required double amount,
    required String method,
    required String recipient,
  }) async {
    // Integration with actual IPay88 API
    await Future.delayed(const Duration(seconds: 2));
    return true; // Simulate success
  }
}

// implementation based on the selected payment method.
class PaymentServiceFactory {
  PaymentAPIService getService(String method) {
    switch (method) {
      case 'DuitNow':
        return DuitNowPaymentService();
      case 'IPay88':
        return IPay88PaymentService();
      default:
        throw Exception('Unsupported payment method');
    }
  }
}