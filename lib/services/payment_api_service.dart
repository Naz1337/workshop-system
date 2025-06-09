abstract class PaymentAPIService {
  Future<bool> processPayment({
    required double amount,
    required String method,
    required String recipient,
  });
}

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