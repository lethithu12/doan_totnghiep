import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/order_status.dart';
import '../models/cart_model.dart';
import '../models/payment_method.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'orders';

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Tạo mã code thanh toán dựa trên phương thức thanh toán
  String _generateOrderCode(PaymentMethod paymentMethod) {
    final random = Random();
    final randomDigits = (1000 + random.nextInt(9000)).toString(); // 4 chữ số ngẫu nhiên

    switch (paymentMethod) {
      case PaymentMethod.momo:
        return 'MM$randomDigits';
      case PaymentMethod.bank:
        return 'BANK$randomDigits';
      case PaymentMethod.cod:
        return 'COD$randomDigits';
    }
  }

  /// Tạo đơn hàng mới
  Future<OrderModel> createOrder({
    required String fullName,
    required String phone,
    required String address,
    String? notes,
    required PaymentMethod paymentMethod,
    required List<Map<String, dynamic>> items,
    required int subtotal,
    required int shippingFee,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Người dùng chưa đăng nhập.';
    }

    try {
      final orderCode = _generateOrderCode(paymentMethod);
      final total = subtotal + shippingFee;
      final now = DateTime.now();

      // Convert items từ Map sang CartItemModel
      final cartItems = items.map((item) {
        return CartItemModel(
          productId: item['productId'] as String,
          productName: item['productName'] as String,
          imageUrl: item['imageUrl'] as String?,
          price: item['price'] as int,
          originalPrice: item['originalPrice'] as int,
          quantity: item['quantity'] as int,
          selectedVersion: item['selectedVersion'] as String?,
          selectedColor: item['selectedColor'] as String?,
          createdAt: DateTime.parse(item['createdAt'] as String),
          updatedAt: DateTime.parse(item['updatedAt'] as String),
        );
      }).toList();

      final order = OrderModel(
        userId: userId,
        orderCode: orderCode,
        fullName: fullName,
        phone: phone,
        address: address,
        notes: notes,
        paymentMethod: paymentMethod,
        items: cartItems,
        subtotal: subtotal,
        shippingFee: shippingFee,
        total: total,
        status: OrderStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _firestore.collection(_collection).add(order.toMap());
      return order.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Lỗi khi tạo đơn hàng: ${e.toString()}';
    }
  }

  /// Lấy danh sách đơn hàng của user hiện tại
  Stream<List<OrderModel>> getOrders() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
        //orderBy thủ công
        final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Lấy tất cả đơn hàng (cho admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Lấy một đơn hàng theo ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy đơn hàng: ${e.toString()}';
    }
  }

  /// Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': newStatus.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật trạng thái đơn hàng: ${e.toString()}';
    }
  }

  /// Hủy đơn hàng (chỉ cho phép khi status là pending, confirmed, hoặc processing)
  Future<void> cancelOrder(String orderId, String reason) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Người dùng chưa đăng nhập.';
    }

    try {
      // Kiểm tra đơn hàng có thuộc về user hiện tại không
      final order = await getOrderById(orderId);
      if (order == null) {
        throw 'Không tìm thấy đơn hàng.';
      }

      if (order.userId != userId) {
        throw 'Bạn không có quyền hủy đơn hàng này.';
      }

      // Kiểm tra status có cho phép hủy không
      if (order.status != OrderStatus.pending &&
          order.status != OrderStatus.confirmed &&
          order.status != OrderStatus.processing) {
        throw 'Đơn hàng này không thể hủy.';
      }

      // Cập nhật status và lý do hủy
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderStatus.cancelled.value,
        'cancellationReason': reason,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi hủy đơn hàng: ${e.toString()}';
    }
  }
}

