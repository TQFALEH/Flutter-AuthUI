// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers, unused_local_variable, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../appWrite/appwrite_client.dart' as appwrite;
import 'add_meal_screen.dart';
import 'meal_details_screen.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({Key? key}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final List<String> _tabs = ['المفضلة', 'الكل'];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Preload data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _handleTabChange() {
    if (!mounted) return;
    setState(() {
      _selectedTab = _tabController.index;
    });
    // Preload data for the selected tab
    _loadMeals(forceLoad: false);
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    await _loadMeals(forceLoad: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals({bool forceLoad = false}) async {
    if (!mounted) return;

    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final authProvider =
        Provider.of<appwrite.AuthProvider>(context, listen: false);

    if (authProvider.user == null) return;

    try {
      // Load favorites first as they're needed for both tabs
      await mealProvider.loadFavoriteMeals(authProvider.user!.$id);

      // Load all meals if we're on the "all" tab or if force loading
      if (_selectedTab == 1 || forceLoad) {
        await mealProvider.loadMeals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الوجبات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final authProvider =
        Provider.of<appwrite.AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  // إغلاق لوحة المفاتيح عند النقر خارج حقول الإدخال
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainColor = Color(0xFF7c7be6);
    final cardColor =
        theme.brightness == Brightness.dark ? Color(0xFF181818) : Colors.white;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final subTextColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey[700]!;
    final plusColor = mainColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: Provider.of<MealProvider>(context, listen: false),
                      child: const AddMealScreen(),
                    ),
                  ),
                ).then((_) => _loadMeals(forceLoad: true));
              },
              backgroundColor: mainColor,
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          color: mainColor,
          onRefresh: () => _loadMeals(forceLoad: true),
          child: GestureDetector(
            onTap: _dismissKeyboard,
            behavior: HitTestBehavior.translucent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
                  child: Text(
                    'وجباتي',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                // Search bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Color(0xFF232323)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'بحث',
                              hintStyle: TextStyle(color: subTextColor),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                            ),
                            textAlign: TextAlign.right,
                            onChanged: (value) {
                              Future.microtask(() {
                                setState(() {
                                  _searchQuery = value;
                                });
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.search, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _tabs.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final label = entry.value;
                      final selected = _selectedTab == idx;
                      return GestureDetector(
                        onTap: () {
                          _tabController.animateTo(idx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  color: selected ? mainColor : subTextColor,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Container(
                                height: 3,
                                width: 24,
                                decoration: BoxDecoration(
                                  color:
                                      selected ? mainColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Meals list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      // المفضلة tab
                      Consumer2<MealProvider, appwrite.AuthProvider>(
                        builder: (context, mealProvider, authProvider, _) {
                          if (mealProvider.isLoading &&
                              mealProvider.favoriteMeals.isEmpty) {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: mainColor));
                          }

                          final filteredMeals =
                              mealProvider.favoriteMeals.where((meal) {
                            final mealName = meal.data['mealName']
                                    ?.toString()
                                    .toLowerCase() ??
                                '';
                            return mealName
                                .contains(_searchQuery.toLowerCase());
                          }).toList();

                          if (filteredMeals.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'لا توجد وجبات في المفضلة',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'اضغط على أيقونة القلب لإضافة وجبات للمفضلة',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            key: const PageStorageKey('favorites_list'),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredMeals.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final meal = filteredMeals[index];
                              return _buildMealCard(
                                context,
                                meal,
                                mealProvider,
                                authProvider,
                                cardColor,
                                textColor,
                                subTextColor,
                                mainColor,
                              );
                            },
                          );
                        },
                      ),
                      // الكل tab
                      Consumer2<MealProvider, appwrite.AuthProvider>(
                        builder: (context, mealProvider, authProvider, _) {
                          if (mealProvider.isLoading &&
                              mealProvider.meals.isEmpty) {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: mainColor));
                          }

                          final filteredMeals =
                              mealProvider.meals.where((meal) {
                            final mealName = meal.data['mealName']
                                    ?.toString()
                                    .toLowerCase() ??
                                '';
                            return mealName
                                .contains(_searchQuery.toLowerCase());
                          }).toList();

                          if (filteredMeals.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.no_meals,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'لا توجد وجبات متاحة',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            key: const PageStorageKey('all_meals_list'),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredMeals.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final meal = filteredMeals[index];
                              return _buildMealCard(
                                context,
                                meal,
                                mealProvider,
                                authProvider,
                                cardColor,
                                textColor,
                                subTextColor,
                                mainColor,
                              );
                            },
                          );
                        },
                      ),
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

  Widget _buildMealCard(
    BuildContext context,
    dynamic meal,
    MealProvider mealProvider,
    appwrite.AuthProvider authProvider,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color mainColor,
  ) {
    final name = meal.data['mealName'] ?? '';
    final imageUrl = meal.data['imageUrl'];
    final carbs = meal.data['carbs'] ?? '0';
    final userId = authProvider.user!.$id;

    // تحويل التاريخ إلى تنسيق مناسب
    final createdAt = DateTime.tryParse(meal.data['createdAt'] ?? '');
    final formattedDate = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '';

    return Dismissible(
      key: Key(meal.$id),
      direction: DismissDirection.endToStart, // للسحب من اليمين إلى اليسار
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(height: 4),
            Text(
              'حذف',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // عرض مربع حوار للتأكيد
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('تأكيد الحذف', textAlign: TextAlign.right),
              content: Text('هل أنت متأكد من حذف هذه الوجبة؟',
                  textAlign: TextAlign.right),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'حذف',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        try {
          await mealProvider.deleteMeal(meal.$id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف الوجبة بنجاح'),
              backgroundColor: mainColor,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حذف الوجبة: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealDetailsScreen(meal: meal),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // زر المفضلة
              IconButton(
                icon: Icon(
                  mealProvider.checkFavoriteStatus(meal.$id, userId)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: mealProvider.checkFavoriteStatus(meal.$id, userId)
                      ? mainColor
                      : subTextColor,
                ),
                onPressed: () async {
                  try {
                    await mealProvider.toggleFavorite(meal.$id, userId);
                    if (mounted) {
                      await _loadMeals(forceLoad: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            mealProvider.checkFavoriteStatus(meal.$id, userId)
                                ? 'تم إضافة الوجبة إلى المفضلة'
                                : 'تم إزالة الوجبة من المفضلة',
                          ),
                          backgroundColor: mainColor,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              // معلومات الوجبة
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'الكربوهيدرات: $carbs جرام',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: subTextColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),
              // صورة الوجبة
              ClipRRect(
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(16)),
                child: Image.network(
                  imageUrl ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.fastfood, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
