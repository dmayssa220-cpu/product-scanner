import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/identify_repository.dart';

class PhotoScanView extends StatefulWidget {
  const PhotoScanView({super.key});

  @override
  State<PhotoScanView> createState() => _PhotoScanViewState();
}

class _PhotoScanViewState extends State<PhotoScanView> {
  final _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  String? _error;
  String? _matchedProductId;

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _error = null;
      _matchedProductId = null;
    });
    await _identify();
  }

  Future<void> _identify() async {
    if (_image == null) return;
    setState(() => _loading = true);
    try {
      final result = await context.read<IdentifyRepository>().identify(_image!);
      final id = result['product_id'] as String?;
      if (id == null) {
        setState(() => _error = 'Produit non reconnu dans notre base.');
      } else {
        setState(() => _matchedProductId = id);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identifier par photo')),
      body: Column(
        children: [
          Expanded(
            child: _image == null
                ? const Center(child: Text('Prenez une photo du produit'))
                : Image.file(_image!, fit: BoxFit.contain),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_matchedProductId != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => context.push('/product/$_matchedProductId'),
                icon: const Icon(Icons.visibility),
                label: const Text('Voir la fiche produit'),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filled(
                    iconSize: 32,
                    onPressed: _loading ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                  ),
                  IconButton.filledTonal(
                    iconSize: 32,
                    onPressed: _loading ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
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