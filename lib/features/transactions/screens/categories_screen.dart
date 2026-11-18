import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/category_item.dart';
import '../../../core/models/transaction.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  int _selectedTab = 0; // 0: Expense, 1: Income

  void _showAddEditCategoryModal({CategoryItem? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    TransactionType type = category?.type ??
        (_selectedTab == 0 ? TransactionType.expense : TransactionType.income);
    Color selectedColor = category?.color ?? AppColors.sage;
    IconData selectedIcon = category?.icon ?? LucideIcons.shapes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 22,
                bottom: MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category != null ? 'Edit Category' : 'New Category',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: nameController,
                    label: 'Category Name',
                    hintText: 'e.g. Pet Care, Subscriptions, Freelance',
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      LucideIcons.shapes,
                      LucideIcons.shoppingBag,
                      LucideIcons.utensils,
                      LucideIcons.car,
                      LucideIcons.plane,
                      LucideIcons.house,
                      LucideIcons.dumbbell,
                      LucideIcons.film,
                      LucideIcons.book,
                      LucideIcons.briefcase,
                    ].map((icon) {
                      final isSelected = selectedIcon == icon;
                      return InkWell(
                        onTap: () {
                          setSheetState(() => selectedIcon = icon);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.deepForest.withValues(alpha: 0.12) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.deepForest : AppColors.borderLight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, size: 20, color: isSelected ? AppColors.deepForest : AppColors.sage),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  AppButton(
                    label: category != null ? 'Update Category' : 'Create Category',
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      if (category != null) {
                        ref.read(financeProvider.notifier).updateCategory(
                              category.copyWith(
                                name: name,
                                icon: selectedIcon,
                                color: selectedColor,
                              ),
                            );
                      } else {
                        ref.read(financeProvider.notifier).addCategory(
                          CategoryItem(
                            id: 'cat_custom_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            type: type,
                            icon: selectedIcon,
                            color: selectedColor,
                            isDefault: false,
                          ),
                        );
                      }
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final targetType = _selectedTab == 0 ? TransactionType.expense : TransactionType.income;
    final categories = finance.categories.where((c) => c.type == targetType).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () => _showAddEditCategoryModal(),
            icon: const Icon(LucideIcons.plus, size: 20),
            tooltip: 'Add Category',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                // Segmented Tabs
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 18,
                    vertical: 14,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Expense Categories', 0, isDark),
                        _buildTab('Income Categories', 1, isDark),
                      ],
                    ),
                  ),
                ),

                // Category List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 18,
                      vertical: 6,
                    ),
                    children: [
                      FinSection(
                        children: List.generate(categories.length, (index) {
                          final cat = categories[index];
                          final count = finance.transactions
                              .where((t) => t.categoryId == cat.id)
                              .length;
                          final isLast = index == categories.length - 1;

                          return FinListTile(
                            leading: FinAnimatedIcon(
                              icon: cat.icon,
                              size: 19,
                              color: cat.color,
                              backgroundColor: cat.color.withValues(alpha: 0.12),
                              backgroundSize: 40,
                              borderRadius: 12,
                            ),
                            title: cat.name,
                            subtitle: '$count transactions recorded',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.pencil, size: 16),
                                  onPressed: () => _showAddEditCategoryModal(category: cat),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () async {
                                    final confirmed = await ConfirmationDialog.show(
                                      context,
                                      title: 'Delete Category',
                                      message: 'Are you sure you want to delete "${cat.name}"?',
                                    );
                                    if (confirmed == true) {
                                      ref.read(financeProvider.notifier).deleteCategory(cat.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            showDivider: !isLast,
                          );
                        }),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.deepForest : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.deepForest)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
