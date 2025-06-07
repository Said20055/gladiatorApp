import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:gladiatorapp/core/services/admin_service.dart';
import 'package:gladiatorapp/core/services/subscription_service.dart';

import '../../data/models/admin_model.dart';

class AdminQrScannerScreen extends StatefulWidget {
  const AdminQrScannerScreen({super.key});

  @override
  State<AdminQrScannerScreen> createState() => _AdminQrScannerScreenState();
}

class _AdminQrScannerScreenState extends State<AdminQrScannerScreen> {
  final AdminService _adminService = AdminService();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isLoading = false;
  AdminUser? _adminUser;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final adminUser = await _adminService.getAdminUser();
    if (adminUser == null || !adminUser.canScanQr) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Доступ запрещен')),
      );
    } else {
      setState(() => _adminUser = adminUser);
    }
  }

  void _handleQrScan(String qrCode) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final success = await SubscriptionService.validateQrCode(
        qrCode,
        _adminUser!.uid,
      );

      if (success) {
        _scannerController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Абонемент подтвержден!')),
        );
        Navigator.of(context).pop(); // <-- Закрытие экрана сразу
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка валидации QR-кода')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_adminUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканер QR-кодов'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _handleQrScan(barcode.rawValue ?? '');
              }
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
