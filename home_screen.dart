// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // Pour timestamps ; ajoute à pubspec.yaml si besoin

class Post {
  final String id;
  final String user;
  final String avatarUrl;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  int likes;
  bool isLiked;
  final List<Map<String, String>> comments; // {user, text}

  Post({
    required this.id,
    required this.user,
    required this.avatarUrl,
    required this.content,
    this.imageUrl,
    DateTime? timestamp,
    this.likes = 0,
    this.isLiked = false,
    List<Map<String, String>>? comments,
  }) : timestamp = timestamp ?? DateTime.now(),
       comments = comments ?? [];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Post> posts = [
    Post(
      id: '1',
      user: "Alice",
      avatarUrl: "https://picsum.photos/50/50?random=1",
      content: "Regardez cette belle photo ! 🌅 #Vacances",
      imageUrl: "https://picsum.photos/300/200?random=1",
      likes: 12,
      isLiked: false,
      comments: [
        {'user': 'Bob', 'text': 'Superbe ! 😍'},
        {'user': 'Charlie', 'text': 'Où est-ce ?'},
      ],
    ),
    Post(
      id: '2',
      user: "Bob",
      avatarUrl: "https://picsum.photos/50/50?random=2",
      content: "Aujourd'hui j'ai mangé un super burger 🍔. Recommandé !",
      imageUrl: null,
      likes: 8,
      isLiked: true,
      comments: [
        {'user': 'Alice', 'text': 'Ça a l\'air délicieux !'},
      ],
    ),
    Post(
      id: '3',
      user: "Charlie",
      avatarUrl: "https://picsum.photos/50/50?random=3",
      content: "Une autre journée productive au travail. Qui est motivé ? 💼",
      imageUrl: null,
      likes: 5,
      isLiked: false,
      comments: [],
    ),
  ];

  late final AnimationController _likeAnimationController;

  @override
  void initState() {
    super.initState();
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void toggleLike(Post post) {
    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
      if (post.isLiked) {
        _likeAnimationController.forward().then(
          (_) => _likeAnimationController.reverse(),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(post.isLiked ? 'Aimé ! ❤️' : 'Unlike'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void sharePost(Post post) {
    // Implémente share (ex. : share_plus package)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Partagé : ${post.content}')));
  }

  void openCommentModal(Post post) {
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
                'Commentaires (${post.comments.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Liste comments
              Expanded(
                child: post.comments.isEmpty
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
                        reverse: true, // Nouveaux en haut
                        itemCount: post.comments.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final comment = post.comments[index];
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

  void _addComment(Post post, TextEditingController controller) {
    if (controller.text.trim().isEmpty) return;
    setState(() {
      post.comments.insert(0, {
        'user': 'Moi', // Remplace par user courant
        'text': controller.text.trim(),
      });
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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Accueil',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.waving_hand,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {}, // Implémente recherche
                ),
                const SizedBox(width: 16),
              ],
            ),
            SliverToBoxAdapter(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Pull to refresh (simulé)
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) setState(() {});
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/post');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau post'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Card pour un post animé
class _PostCard extends StatelessWidget {
  final Post post;
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
      label: 'Post de ${post.user} : ${post.content}',
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
                            backgroundImage: NetworkImage(post.avatarUrl),
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.person),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.user,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat(
                                    'MMM dd, HH:mm',
                                  ).format(post.timestamp),
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
                        post.content,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (post.imageUrl != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            post.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
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
                            label: '${post.likes}',
                            isActive: post.isLiked,
                            color: Colors.blue,
                            onPressed: onLike,
                            animation: AnimatedScale(
                              scale: post.isLiked ? 1.3 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              child: Icon(
                                Icons.thumb_up,
                                color: post.isLiked ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ),
                          _ActionButton(
                            icon: Icons.comment,
                            label: '${post.comments.length}',
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
  final Widget? animation;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.color,
    required this.onPressed,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isActive ? color ?? Colors.blue : null;
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: animation ?? Icon(icon, color: effectiveColor ?? Colors.grey),
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

/// Modal pour commentaires (simulé)
class _CommentModal extends StatelessWidget {
  final int postIndex;
  const _CommentModal({required this.postIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Commentaires',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Simulé
              itemBuilder: (context, i) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Commentaire $i'),
                subtitle: const Text('Il y a 1h'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Ajouter un commentaire...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => Navigator.pop(context), // Simule envoi
          ),
        ],
      ),
    );
  }
}

/// Navigation en bas (optionnel, si besoin)
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ],
    );
  }
}
