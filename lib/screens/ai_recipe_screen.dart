import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/ai_service.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/price.dart';
import '../widgets/product_placeholder.dart';

class AIRecipeScreen extends StatefulWidget {
  const AIRecipeScreen({super.key});

  @override
  State<AIRecipeScreen> createState() => _AIRecipeScreenState();
}

class _AIRecipeScreenState extends State<AIRecipeScreen> {
  final _aiService = AIService();
  final List<String> ingredients = ['chicken breast', 'tomato', 'onion', 'ginger', 'dahi', 'green chilies'];
  final TextEditingController _controller = TextEditingController();
  
  bool _isLoading = false;
  List<RecipeOption> _recipes = [];
  int selected = 0;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchRecipes() async {
    if (ingredients.isEmpty) {
      if (mounted) setState(() => _recipes = []);
      return;
    }
    
    setState(() => _isLoading = true);
    final results = await _aiService.generateRecipes(ingredients);
    if (mounted) {
      setState(() {
        _recipes = results;
        _isLoading = false;
        selected = 0;
      });
    }
  }

  void _addIngredient(String s) {
    final val = s.trim().toLowerCase();
    if (val.isEmpty || ingredients.contains(val)) return;
    setState(() {
      ingredients.add(val);
      _controller.clear();
    });
    _fetchRecipes();
  }

  void _removeIngredient(int index) {
    setState(() => ingredients.removeAt(index));
    _fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Daana.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: const BoxDecoration(
                            color: Daana.moss, shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: DaanaIcon('sparkle', size: 14, color: Daana.bg),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Eyebrow('Recipes from your fridge'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Three things you can cook tonight, with what you already have.',
                      style: Daana.serif(size: 32, height: 1.05),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _PantryInput(
              ingredients: ingredients,
              controller: _controller,
              onAdd: _addIngredient,
              onRemove: _removeIngredient,
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: Daana.moss)),
                ),
              )
            else if (_recipes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Add ingredients to see recipes.', style: Daana.sans(size: 14, color: Daana.ink50)),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(child: _RecipeTabs(
                recipes: _recipes,
                selected: selected,
                onSelect: (i) => setState(() => selected = i),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _RecipeCard(recipe: _recipes[selected])),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

class _PantryInput extends StatelessWidget {
  final List<String> ingredients;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;
  const _PantryInput({
    required this.ingredients,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Daana.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Daana.hairlineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('In your fridge'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                for (int i = 0; i < ingredients.length; i++)
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                    decoration: BoxDecoration(
                      color: Daana.bg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Daana.hairlineSoft),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(ingredients[i], style: Daana.sans(size: 13)),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => onRemove(i),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: DaanaIcon('close', size: 11, color: Daana.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Daana.bg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Daana.hairline),
                    ),
                    child: TextField(
                      controller: controller,
                      onSubmitted: onAdd,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: 'add another…',
                        hintStyle: Daana.sans(size: 13, color: Daana.ink50),
                      ),
                      style: Daana.sans(size: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Daana.ink08, borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Center(child: DaanaIcon('mic', size: 15)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeTabs extends StatelessWidget {
  final List<RecipeOption> recipes;
  final int selected;
  final ValueChanged<int> onSelect;
  const _RecipeTabs({
    required this.recipes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final r = recipes[i];
          final active = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 200,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: active ? Daana.ink : Daana.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? Daana.ink : Daana.hairlineSoft,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    r.tag.isNotEmpty ? r.tag.toUpperCase() : 'OPTION ${(i + 1).toString().padLeft(2, '0')}',
                    style: Daana.mono(
                      size: 10,
                      color: (active ? Daana.bg : Daana.ink).withOpacity(0.6),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.name,
                    style: Daana.serif(
                      size: 20,
                      color: active ? Daana.bg : Daana.ink,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${r.time} · ${r.match}% MATCH',
                    style: Daana.sans(
                      size: 11,
                      color: (active ? Daana.bg : Daana.ink).withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final RecipeOption recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Daana.card,
            border: Border.all(color: Daana.hairlineSoft),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ProductPlaceholder(
                  label: '${recipe.name.toLowerCase()} — plated',
                  tone: 'c',
                  radius: 0,
                  square: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('Suggestion · ${recipe.match}% match'),
                    const SizedBox(height: 10),
                    Text(recipe.name, style: Daana.serif(size: 36, height: 1.0)),
                    const SizedBox(height: 4),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(recipe.urdu,
                          style: Daana.urdu(size: 22, color: Daana.ink70)),
                    ),
                    const SizedBox(height: 12),
                    Text(recipe.blurb,
                        style: Daana.sans(size: 14, color: Daana.ink70, height: 1.55)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 20, runSpacing: 12,
                      children: [
                        _meta('Time', recipe.time),
                        _meta('Have', '${recipe.have} items'),
                        _meta('Need', '${recipe.need} items'),
                      ],
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

  Widget _meta(String l, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Eyebrow(l),
        const SizedBox(height: 4),
        Text(v, style: Daana.sans(size: 15)),
      ],
    );
  }
}
