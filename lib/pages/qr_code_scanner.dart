import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../utils/constants.dart';

class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'qr_scanner');
  QRViewController? _controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un code')), 
      body: Stack(
        children: [
          _buildQrView(context),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Text(
              'Alignez le QR code dans le cadre pour récupérer le code de partie.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cutOut = size.width < 400 || size.height < 400 ? 180.0 : 280.0;
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQrCreated,
      overlay: QrScannerOverlayShape(
        borderColor: PictConstants.PictPrimary,
        borderRadius: 16,
        borderLength: 32,
        borderWidth: 8,
        cutOutSize: cutOut,
      ),
      onPermissionSet: _onPermissionChanged,
    );
  }

  void _onQrCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((data) {
      if (data.code == null) {
        return;
      }
      controller.pauseCamera();
      Navigator.of(context).pop(data.code);
    });
  }

  void _onPermissionChanged(QRViewController controller, bool granted) {
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission caméra refusée')),
      );
    }
  }
}
