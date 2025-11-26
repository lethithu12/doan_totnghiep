import 'package:flutter/material.dart';
import '../../../../services/address_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/address_model.dart';

class DeliveryInfoForm extends StatefulWidget {
  final Function(String fullName, String phone, String address, String? notes) onNext;

  const DeliveryInfoForm({
    super.key,
    required this.onNext,
  });

  @override
  State<DeliveryInfoForm> createState() => DeliveryInfoFormState();
}

class DeliveryInfoFormState extends State<DeliveryInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _addressService = AddressService();
  final _authService = AuthService();
  
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isSaving = false;

  // Load address data into form
  Future<void> loadAddress(String addressId) async {
    try {
      final addresses = await _addressService.getAddressesOnce();
      final address = addresses.firstWhere((a) => a.id == addressId);
      
      setState(() {
        _fullNameController.text = address.fullName;
        _phoneController.text = address.phone;
        _addressController.text = address.address;
        _notesController.text = address.notes ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải địa chỉ: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw 'Vui lòng đăng nhập';
      }

      // Check if phone number already exists
      final existingAddresses = await _addressService.getAddressesOnce();
      final phoneNumber = _phoneController.text.trim();
      final phoneExists = existingAddresses.any(
        (address) => address.phone == phoneNumber,
      );

      if (phoneExists) {
        throw 'Số điện thoại này đã tồn tại trong danh sách địa chỉ đã lưu';
      }

      final address = AddressModel(
        userId: userId,
        fullName: _fullNameController.text.trim(),
        phone: phoneNumber,
        address: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _addressService.addAddress(address);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu địa chỉ thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Clear form
        _fullNameController.clear();
        _phoneController.clear();
        _addressController.clear();
        _notesController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin giao hàng',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            // Họ và tên
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Họ và tên *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Số điện thoại
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Số điện thoại *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value.trim())) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Địa chỉ giao hàng
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Địa chỉ giao hàng *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập địa chỉ giao hàng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Ghi chú
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Ghi chú cho đơn hàng (không bắt buộc)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Nút lưu địa chỉ mới
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _handleSaveAddress,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.folder),
                label: const Text('Lưu địa chỉ mới'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(
                    color: Colors.green[300]!,
                    width: 2,
                  ),
                  foregroundColor: Colors.green[700],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nút tiếp tục
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final notes = _notesController.text.trim().isEmpty
                        ? null
                        : _notesController.text.trim();
                    widget.onNext(
                      _fullNameController.text.trim(),
                      _phoneController.text.trim(),
                      _addressController.text.trim(),
                      notes,
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Tiếp tục'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

