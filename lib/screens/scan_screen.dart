import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../services/ocr_service.dart';
import 'receipt_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false;
  final ImagePicker _imagePicker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();
  final OCRService _ocrService = OCRService();

  Future<void> _pickAndProcess(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image == null || !mounted) return;

      final croppedImage = await _imageCropper.cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Receipt',
            toolbarColor: AppColors.primaryDark,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Receipt'),
        ],
      );
      if (croppedImage == null || !mounted) return;

      setState(() => _isProcessing = true);
      final result = await _ocrService.processImage(croppedImage.path);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptResultScreen(
            mockStore: result.storeName,
            mockAmount: result.amount,
            mockText: result.rawText,
            qrCode: result.qrCode,
            date: result.date,
            imagePath: croppedImage.path,
          ),
        ),
      );
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể truy cập camera/ML Kit: ${error.message ?? error.code}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể đọc hóa đơn hoặc QR: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Scan Receipt', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Camera Frame / Overlay
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: const Center(
                child: Text('Position receipt inside frame', style: TextStyle(color: Colors.white70)),
              ),
            ),
          ),

          // Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: AppDimens.lg),
                    Text('Reading receipt with ML Kit...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),

          // Action Buttons Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.large(
                    onPressed: _isProcessing ? null : () => _pickAndProcess(ImageSource.camera),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.camera, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextButton.icon(
                    onPressed: _isProcessing ? null : () => _pickAndProcess(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}