import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'delivery_info_form.dart';
import 'saved_addresses_list.dart';

class DeliveryInfoStep extends StatefulWidget {
  final Function(String fullName, String phone, String address, String? notes) onNext;

  const DeliveryInfoStep({
    super.key,
    required this.onNext,
  });

  @override
  State<DeliveryInfoStep> createState() => _DeliveryInfoStepState();
}

class _DeliveryInfoStepState extends State<DeliveryInfoStep> {
  final GlobalKey<DeliveryInfoFormState> _formKey = GlobalKey<DeliveryInfoFormState>();

  void _handleAddressSelected(String addressId) {
    _formKey.currentState?.loadAddress(addressId);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (isMobile) {
      // Mobile: Stack vertically - Saved addresses on top
      return Column(
        children: [
          SavedAddressesList(onAddressSelected: _handleAddressSelected),
          const SizedBox(height: 24),
          DeliveryInfoForm(
            key: _formKey,
            onNext: (fullName, phone, address, notes) {
              widget.onNext(fullName, phone, address, notes);
            },
          ),
        ],
      );
    } else {
      // Desktop: Side by side
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: DeliveryInfoForm(key: _formKey, onNext: widget.onNext),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: SavedAddressesList(onAddressSelected: _handleAddressSelected),
          ),
        ],
      );
    }
  }
}
