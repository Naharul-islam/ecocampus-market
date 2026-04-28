import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';

// ⚠️ তোমার Cloudinary info এখানে বসাও
const String _cloudName = 'dxlqwaoje';
const String _uploadPreset = 'ecocampus_upload';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _selectedCategory = 'Books';
  String _selectedCondition = 'Good';
  String _selectedType = 'Buy';
  bool _loading = false;
  String _uploadStatus = '';

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  final _categories = ['Books', 'Electronics', 'Furniture', 'Clothes', 'Others'];
  final _conditions = ['New', 'Good', 'Fair', 'Poor'];
  final _types = ['Buy', 'Rent', 'Swap', 'Donate'];

  final Map<String, double> _co2Baselines = {
    'Books': 2.5, 'Electronics': 20.0,
    'Furniture': 8.0, 'Clothes': 3.0, 'Others': 5.0,
  };

  double get _co2Saved {
    final baseline = _co2Baselines[_selectedCategory] ?? 5.0;
    final multiplier = _selectedType == 'Rent' ? 0.4 : 0.85;
    return baseline * multiplier;
  }
  double get _greenPoints => _co2Saved * 10;

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(images.take(5));
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null && _selectedImages.length < 5) {
      setState(() => _selectedImages.add(image));
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _imageOption(icon: Icons.photo_library_outlined, label: 'Gallery', onTap: () { Navigator.pop(context); _pickImages(); }),
                _imageOption(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: () { Navigator.pop(context); _pickFromCamera(); }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _imageOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.ecoGreen, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ]),
    );
  }

  Future<String?> _uploadToCloudinary(XFile imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        return json['secure_url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> _uploadAllImages() async {
    final List<String> urls = [];
    for (int i = 0; i < _selectedImages.length; i++) {
      setState(() => _uploadStatus = 'Uploading image ${i + 1}/${_selectedImages.length}...');
      final url = await _uploadToCloudinary(_selectedImages[i]);
      if (url != null) urls.add(url);
    }
    setState(() => _uploadStatus = '');
    return urls;
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final id = const Uuid().v4();

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadAllImages();
      }

      await FirebaseFirestore.instance.collection('listings').doc(id).set({
        'listing_id': id,
        'seller_id': user.uid,
        'seller_name': user.displayName ?? 'Anonymous',
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': _selectedType == 'Donate' ? 0 : double.tryParse(_priceCtrl.text) ?? 0,
        'price_display': _selectedType == 'Donate' ? 'FREE' : '৳ ${_priceCtrl.text.trim()}',
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'transaction_type': _selectedType,
        'co2_saved': _co2Saved,
        'co2': '${_co2Saved.toStringAsFixed(1)} kg',
        'green_points_earned': _greenPoints,
        'is_available': true,
        'emoji': _categoryEmoji(_selectedCategory),
        'image_urls': imageUrls,
        'created_at': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'green_points': FieldValue.increment(_greenPoints),
        'total_co2_saved': FieldValue.increment(_co2Saved),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🌱 Listed! +${_greenPoints.toStringAsFixed(0)} green points!'),
          backgroundColor: AppColors.primary,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() { _loading = false; _uploadStatus = ''; });
    }
  }

  String _categoryEmoji(String cat) {
    const map = {'Books': '📚', 'Electronics': '💻', 'Furniture': '🪑', 'Clothes': '👕', 'Others': '🔧'};
    return map[cat] ?? '📦';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Listing')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 160, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                  child: _selectedImages.isEmpty
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          const Text('Tap to add photos (up to 5)', style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(_categoryEmoji(_selectedCategory), style: const TextStyle(fontSize: 32)),
                        ])
                      : Stack(children: [
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: _selectedImages.length + (_selectedImages.length < 5 ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == _selectedImages.length) {
                                return GestureDetector(
                                  onTap: _showImagePickerOptions,
                                  child: Container(
                                    width: 130, margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(color: AppColors.ecoGreen, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary)),
                                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Icon(Icons.add, color: AppColors.primary, size: 32),
                                      Text('Add More', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                                    ]),
                                  ),
                                );
                              }
                              return Stack(children: [
                                Container(
                                  width: 130, margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(image: FileImage(File(_selectedImages[i].path)), fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(top: 4, right: 12, child: GestureDetector(
                                  onTap: () => setState(() => _selectedImages.removeAt(i)),
                                  child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18)),
                                )),
                              ]);
                            },
                          ),
                          Positioned(bottom: 8, right: 8, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                            child: Text('${_selectedImages.length}/5', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          )),
                        ]),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Item Title *'), validator: (v) => v == null || v.isEmpty ? 'Title required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
              const SizedBox(height: 12),
              const Text('Category', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: _categories.map((c) => ChoiceChip(
                label: Text('${_categoryEmoji(c)} $c'),
                selected: _selectedCategory == c,
                onSelected: (_) => setState(() => _selectedCategory = c),
                selectedColor: AppColors.ecoGreen,
                labelStyle: TextStyle(color: _selectedCategory == c ? AppColors.primaryDark : AppColors.textSecondary),
              )).toList()),
              const SizedBox(height: 12),
              const Text('Transaction Type', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(children: _types.map((t) {
                final colors = {'Buy': Colors.blue, 'Rent': Colors.orange, 'Swap': Colors.purple, 'Donate': Colors.green};
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _selectedType = t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedType == t ? colors[t]!.withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _selectedType == t ? colors[t]! : AppColors.divider),
                    ),
                    child: Text(t, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _selectedType == t ? colors[t]! : AppColors.textSecondary)),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 12),
              const Text('Condition', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: _conditions.map((c) => ChoiceChip(
                label: Text(c), selected: _selectedCondition == c,
                onSelected: (_) => setState(() => _selectedCondition = c),
                selectedColor: AppColors.ecoGreen,
              )).toList()),
              const SizedBox(height: 12),
              if (_selectedType != 'Donate')
                TextFormField(
                  controller: _priceCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (৳)', prefixIcon: Icon(Icons.attach_money)),
                  validator: (v) { if (_selectedType == 'Donate') return null; if (v == null || v.isEmpty) return 'Price required'; return null; },
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.ecoGreen, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Text('🌱', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Eco Impact', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    Text('CO₂ Saved: ${_co2Saved.toStringAsFixed(1)} kg  |  +${_greenPoints.toStringAsFixed(0)} Green Points',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              if (_uploadStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Text(_uploadStatus, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                  ]),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submitListing,
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.upload_outlined),
                  label: Text(_loading ? (_uploadStatus.isNotEmpty ? _uploadStatus : 'Posting...') : 'Post Listing'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
