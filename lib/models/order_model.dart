import 'cart_model.dart';
import 'payment_method.dart';
import 'order_status.dart';

class OrderModel {
  final String id;
  final String userId;
  final String orderCode; // Mã code thanh toán (MM41209, BANK3092, COD1902)
  final String fullName;
  final String phone;
  final String address;
  final String? notes;
  final PaymentMethod paymentMethod;
  final List<CartItemModel> items;
  final int subtotal; // Tổng tiền hàng
  final int shippingFee; // Phí vận chuyển
  final int total; // Tổng cộng
  final OrderStatus status;
  final String? cancellationReason; // Lý do hủy đơn hàng
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    this.id = '',
    required this.userId,
    required this.orderCode,
    required this.fullName,
    required this.phone,
    required this.address,
    this.notes,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    this.status = OrderStatus.pending,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'orderCode': orderCode,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'notes': notes,
      'paymentMethod': paymentMethod.value,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'total': total,
      'status': status.value,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      userId: map['userId'] as String,
      orderCode: map['orderCode'] as String,
      fullName: map['fullName'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      notes: map['notes'] as String?,
      paymentMethod: PaymentMethod.fromString(map['paymentMethod'] as String?) ?? PaymentMethod.cod,
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromMap('', item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: map['subtotal'] as int,
      shippingFee: map['shippingFee'] as int,
      total: map['total'] as int,
      status: OrderStatus.fromLegacyString(map['status'] as String?) ?? OrderStatus.pending,
      cancellationReason: map['cancellationReason'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? orderCode,
    String? fullName,
    String? phone,
    String? address,
    String? notes,
    PaymentMethod? paymentMethod,
    List<CartItemModel>? items,
    int? subtotal,
    int? shippingFee,
    int? total,
    OrderStatus? status,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderCode: orderCode ?? this.orderCode,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      total: total ?? this.total,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

