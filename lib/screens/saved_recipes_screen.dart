import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../theme/tokens.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import 'sign_in_screen.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final Set<int> _expandedIndexes = <int>{};

  Future<List<Map<String, dynamic>>> _loadRecipesForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }

    return _firestoreService.getSavedRecipes(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Daana.bg,
      appBar: AppBar(
        backgroundColor: Daana.bg,
        elevation: 0,
        leading: IconButton(
          icon: const DaanaIcon('chevL', size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('My Recipes', style: Daana.serif(size: 24)),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Eyebrow('Sign in required'),
                    const SizedBox(height: 12),
                    Text(
                      'Please sign in to view your saved recipes.',
                      style: Daana.sans(size: 15, color: Daana.ink70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignInScreen(
                              onClose: () => Navigator.of(context).pop(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Daana.moss,
                        foregroundColor: Daana.bg,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadRecipesForUser(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Daana.moss),
                );
              }

              final recipes = snapshot.data ?? [];
              if (recipes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No saved recipes yet.',
                      style: Daana.sans(size: 15, color: Daana.ink70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                itemCount: recipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  final isExpanded = _expandedIndexes.contains(index);
                  final ingredients = (recipe['ingredients'] as List<dynamic>?)
                      ?.map((item) => item.toString())
                      .toList() ?? <String>[];
                  final instructions = (recipe['instructions'] as List<dynamic>?)
                      ?.map((item) => item.toString())
                      .toList() ?? <String>[];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Daana.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Daana.hairlineSoft),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                recipe['name']?.toString() ?? 'Recipe',
                                style: Daana.serif(size: 22),
                              ),
                            ),
                            if ((recipe['tag'] ?? '').toString().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Daana.moss.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  recipe['tag'].toString(),
                                  style: Daana.sans(size: 11, color: Daana.moss),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe['blurb']?.toString() ?? '',
                          style: Daana.sans(size: 13, color: Daana.ink70, height: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _pill('${recipe['time'] ?? ''}'),
                            _pill('${recipe['match'] ?? ''}% match'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_expandedIndexes.contains(index)) {
                                _expandedIndexes.remove(index);
                              } else {
                                _expandedIndexes.add(index);
                              }
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isExpanded ? 'Hide Details' : 'View Details',
                            style: Daana.sans(size: 13, color: Daana.moss, weight: FontWeight.w600),
                          ),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 8),
                          if (ingredients.isNotEmpty) ...[
                            const Eyebrow('Ingredients'),
                            const SizedBox(height: 8),
                            ...ingredients.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('• ', style: Daana.sans(size: 13, color: Daana.ink50)),
                                      Expanded(
                                        child: Text(item, style: Daana.sans(size: 13, color: Daana.ink)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                          if (instructions.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Eyebrow('Cooking Steps'),
                            const SizedBox(height: 8),
                            ...instructions.asMap().entries.map((entry) {
                              final stepIndex = entry.key + 1;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Daana.ink08,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text('$stepIndex', style: Daana.mono(size: 11, color: Daana.ink)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: Daana.sans(size: 13, color: Daana.ink70, height: 1.45),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Daana.ink08,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Daana.sans(size: 11, color: Daana.ink70)),
    );
  }
}
