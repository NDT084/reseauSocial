import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reseau_social/screens/home_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _controller = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);

    // Simulation d'upload (remplace par vrai Firebase Storage si nécessaire)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pop(context, {
      'content': content,
      'image': _selectedImage?.path,
      'user': 'Moi',
      'timestamp': DateTime.now().toIso8601String(),
      'likes': 0,
      'comments': 0,
      'liked': false,
      'avatar': null,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post publié avec succès !')));

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Créer une publication',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontSize: 18,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePublish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _controller.text.trim().isNotEmpty || _selectedImage != null
                      ? AppTheme.primaryColor
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Publier',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ],
        ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Zone de texte du post
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Champ de texte
                    _PostTextField(controller: _controller),
                    
                    const SizedBox(height: 24),
                    
                    // Bouton d'ajout de photo/vidéo
                    _buildAddMediaButton(context),
                    
                    const SizedBox(height: 16),
                    
                    // Aperçu de l'image sélectionnée
                    if (_selectedImage != null)
                      _ImagePreview(
                        image: _selectedImage!,
                        onRemove: () => setState(() => _selectedImage = null),
                      ),
                  ],
                ),
              ),
            ),
            
            // Barre d'outils inférieure
            _buildBottomToolbar(),
          ],
        ),
      ),
    );
  }
}

// Champ texte pour le post
class _PostTextField extends StatelessWidget {
  final TextEditingController controller;
  const _PostTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Écrivez votre post',
      child: TextFormField(
        controller: controller,
        maxLines: 10,
        maxLength: 1000,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppTheme.textPrimary,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'Quoi de neuf ? Partagez votre moment...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        validator: (value) => value?.trim().isEmpty ?? true
            ? 'Veuillez écrire quelque chose ou ajouter une image'
            : null,
      ),
    );
  }
}

  // Bouton pour ajouter des médias
  Widget _buildAddMediaButton(BuildContext context) {
    return Animate(
      effects: const [FadeEffect(), ScaleEffect()],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showSourceBottomSheet,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajouter des photos/vidéos',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jusqu\'à 10 images',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Barre d'outils inférieure
  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.photo_library_outlined,
            label: 'Photo/Video',
            onTap: _showSourceBottomSheet,
          ),
          const SizedBox(width: 16),
          _buildToolbarButton(
            icon: Icons.tag_faces_outlined,
            label: 'Humeur',
            onTap: () {},
          ),
          const Spacer(),
          Text(
            '${_controller.text.length}/1000',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Bouton de la barre d'outils
  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Afficher le menu de sélection de source
  void _showSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée de glissement
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Titre
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ajouter une photo ou une vidéo',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              
              // Options
              _buildBottomSheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Galerie',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.camera_alt_outlined,
                label: 'Appareil photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Option du menu de sélection de source
  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              Icon(icon, size: 24, color: AppTheme.textPrimary),
              const SizedBox(width: 20),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sélectionner une image
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: source);
      if (image != null && mounted) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ajouter une image',
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isPicking ? null : _showSourceBottomSheet,
              icon: _isPicking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library),
              label: const Text('Galerie'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ).animate().slideX(begin: -0.2, end: 0, duration: 300.ms),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _isPicking ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Caméra'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ).animate(delay: 100.ms).slideX(begin: 0.2, end: 0, duration: 300.ms),
        ],
      ),
    );
  }
}

// Preview de l'image sélectionnée
class _ImagePreview extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _ImagePreview({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [FadeEffect(), ScaleEffect()],
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(image.path),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bouton Publier qui s'active dynamiquement
class _PublishButton extends StatelessWidget {
  final bool isLoading;
  final TextEditingController controller;
  final XFile? image;
  final VoidCallback onPublish;

  const _PublishButton({
    required this.isLoading,
    required this.controller,
    required this.image,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, TextEditingValue value, _) {
        final isValid = value.text.trim().isNotEmpty;

        return SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading || !isValid ? null : onPublish,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: isLoading
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send),
                      const SizedBox(width: 8),
                      const Text('Publier'),
                      if (image != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.image),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}
