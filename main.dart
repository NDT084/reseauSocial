// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_key_in_widget_constructors, unused_field, unused_local_variable, avoid_print, prefer_final_fields, prefer_const_declarations, no_leading_underscores_for_local_identifiers, unused_element

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Réseau Social',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> posts = [];

  void _addPost(Map<String, dynamic> post) {
    setState(() {
      posts.insert(0, post);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      FeedScreen(posts: posts),
      PostScreen(onPublish: _addPost),
      ProfileScreen(posts: posts), // <-- passer les posts ici
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Créer"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

// -------------------- FEED --------------------
class FeedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  const FeedScreen({super.key, required this.posts});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _likeAnimationController;
  late final Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void toggleLike(Map<String, dynamic> post) {
    setState(() {
      post['isLiked'] = !(post['isLiked'] ?? false);
      post['likes'] = (post['likes'] ?? 0) + (post['isLiked'] ? 1 : -1);
      if (post['isLiked']) {
        _likeAnimationController.forward().then(
          (_) => _likeAnimationController.reverse(),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(post['isLiked'] ? 'Aimé ! ❤️' : 'Unlike'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void sharePost(Map<String, dynamic> post) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Partagé : ${post['content']}')));
  }

  void openCommentModal(Map<String, dynamic> post) {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle drag
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Titre
              Text(
                'Commentaires (${post['comments'] ?? 0})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Liste comments (simulée comme Map ; adapte pour List)
              Expanded(
                child: (post['commentsList'] ?? []).isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun commentaire pour l\'instant. Soyez le premier !',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        reverse: true,
                        itemCount: (post['commentsList'] ?? []).length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final comment = (post['commentsList'] ?? [])[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: Text(
                                comment['user']?[0].toUpperCase() ?? '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              comment['user'] ?? 'Anonyme',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(comment['text'] ?? ''),
                          );
                        },
                      ),
              ),
              // Input
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: "Ajoutez un commentaire...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) =>
                            _addComment(post, commentController),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      heroTag: null,
                      onPressed: () => _addComment(post, commentController),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addComment(
    Map<String, dynamic> post,
    TextEditingController controller,
  ) {
    if (controller.text.trim().isEmpty) return;
    setState(() {
      (post['commentsList'] ??= []).insert(0, {
        'user': 'Moi', // Remplace par user courant
        'text': controller.text.trim(),
      });
      post['comments'] = (post['comments'] ?? 0) + 1;
    });
    controller.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Commentaire ajouté !')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implémente recherche
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            // Pull to refresh (simulé)
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) setState(() {});
          },
          child: widget.posts.isEmpty
              ? const Center(child: Text("Aucun post"))
              : ListView.builder(
                  itemCount: widget.posts.length,
                  itemBuilder: (context, index) {
                    final post = widget.posts[index];
                    return _PostCard(
                      post: post,
                      animationDelay: Duration(milliseconds: index * 150),
                      onLike: () => toggleLike(post),
                      onComment: () => openCommentModal(post),
                      onShare: () => sharePost(post),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// Card pour un post animé
class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final Duration animationDelay;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _PostCard({
    required this.post,
    required this.animationDelay,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Post de ${post['user']} : ${post['content']}',
      child: Card(
        elevation: 8,
        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child:
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: post['avatar'] != null
                                ? NetworkImage(post['avatar'])
                                : null,
                            child: post['avatar'] == null
                                ? Text(post['user']?[0].toUpperCase() ?? '?')
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['user'] ?? 'Anonyme',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('MMM dd, HH:mm').format(
                                    DateTime.parse(post['timestamp'] ?? ''),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Contenu
                      Text(
                        post['content'] ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (post['image'] != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(post['image']),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: Icons.thumb_up,
                            label: '${post['likes'] ?? 0}',
                            isActive: post['isLiked'] ?? false,
                            color: Colors.blue,
                            onPressed: onLike,
                          ),
                          _ActionButton(
                            icon: Icons.comment,
                            label: '${post['comments'] ?? 0}',
                            color: Colors.green,
                            onPressed: onComment,
                          ),
                          _ActionButton(
                            icon: Icons.share,
                            label: 'Partager',
                            color: Colors.orange,
                            onPressed: onShare,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.forward(),
                  delay: animationDelay,
                )
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
      ),
    );
  }
}

/// Bouton d'action générique
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isActive ? color ?? Colors.blue : null;
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon, color: effectiveColor ?? Colors.grey),
            onPressed: onPressed,
          ),
          Text(
            label,
            style: TextStyle(
              color: effectiveColor ?? Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- POST --------------------
class PostScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPublish;
  const PostScreen({super.key, required this.onPublish});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _controller = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;
    final content = _controller.text.trim();
    if (content.isEmpty && _selectedImage == null) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final newPost = {
      'content': content,
      'image': _selectedImage?.path,
      'likes': 0,
      'isLiked': false,
      'comments': 0,
      'commentsList': [], // Pour la liste des comments
      'timestamp': DateTime.now().toIso8601String(),
      'user': 'Moi', // pour profil
      'avatar': null, // Ajoute avatar si besoin
    };

    widget.onPublish(newPost);

    _controller.clear();
    setState(() => _selectedImage = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Post publié !")));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un post")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _controller,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Quoi de neuf ?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedImage != null)
                  Stack(
                    children: [
                      Image.file(
                        File(_selectedImage!.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Galerie"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Caméra"),
                      ),
                    ),
                  ],
                ).animate().slideX(begin: -0.2, end: 0, duration: 300.ms),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handlePublish,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text("Publier"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- PROFILE --------------------
class ProfileScreen extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  const ProfileScreen({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    final userPosts = posts.where((post) => post['user'] == 'Moi').toList();
    int totalLikes = userPosts.fold(
      0,
      (sum, post) => sum + (post['likes'] as int),
    );
    int totalComments = userPosts.fold(
      0,
      (sum, post) => sum + (post['comments'] as int),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              "Nom Utilisateur",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ma courte bio ou description ici",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text("Posts"),
                    const SizedBox(height: 4),
                    Text("${userPosts.length}"),
                  ],
                ),
                Column(
                  children: [
                    const Text("Likes"),
                    const SizedBox(height: 4),
                    Text("$totalLikes"),
                  ],
                ),
                Column(
                  children: [
                    const Text("Commentaires"),
                    const SizedBox(height: 4),
                    Text("$totalComments"),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Modifier le profil"),
            ),
            ElevatedButton(onPressed: () {}, child: const Text("Déconnexion")),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Mes Posts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            if (userPosts.isEmpty)
              const Center(child: Text("Vous n'avez aucun post pour le moment"))
            else
              ...userPosts.map((post) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['content']),
                        if (post['image'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.file(File(post['image'])),
                          ),
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              color: post['isLiked']
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text("${post['likes']}"),
                            const SizedBox(width: 20),
                            const Icon(Icons.comment),
                            const SizedBox(width: 8),
                            Text("${post['comments']}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
