// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers, unused_local_variable, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../appWrite/appwrite_client.dart' as appwrite;
import 'edit_meal_screen.dart';

class MealDetailsScreen extends StatefulWidget {
  final dynamic meal;

  const MealDetailsScreen({Key? key, required this.meal}) : super(key: key);

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final mainColor = Color(0xFF7c7be6);
    final theme = Theme.of(context);
    final cardColor =
        theme.brightness == Brightness.dark ? Color(0xFF181818) : Colors.white;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final subTextColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey[700]!;

    final name = widget.meal.data['mealName'] ?? '';
    final imageUrl = widget.meal.data['imageUrl'];
    final carbs = widget.meal.data['carbs']?.toString() ?? '0';
    final restaurantName = widget.meal.data['restaurantName'] ?? '';
    final notes = widget.meal.data['notes'] ?? '';
    final createdAt = DateTime.tryParse(widget.meal.data['createdAt'] ?? '');
    final formattedDate = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // صورة الوجبة مع خلفية متدرجة وزر الرجوع
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: mainColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // صورة الوجبة
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.grey[400],
                                size: 64,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.fastfood,
                            color: Colors.grey[400],
                            size: 64,
                          ),
                        ),
                  // تدرج شفاف فوق الصورة
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // اسم الوجبة في الأسفل
                  Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        if (restaurantName.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            restaurantName,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Edit button
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMealScreen(meal: widget.meal),
                    ),
                  );

                  // If the meal was updated successfully, refresh the details
                  if (result == true && mounted) {
                    Navigator.pop(context,
                        true); // Return to meals screen with refresh flag
                  }
                },
              ),
              Consumer2<MealProvider, appwrite.AuthProvider>(
                builder: (context, mealProvider, authProvider, _) {
                  final userId = authProvider.user!.$id;
                  return IconButton(
                    icon: Icon(
                      mealProvider.checkFavoriteStatus(widget.meal.$id, userId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        await mealProvider.toggleFavorite(
                            widget.meal.$id, userId);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),

          // تفاصيل الوجبة
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // كمية الكربوهيدرات
                  Container(
                    padding: EdgeInsets.all(16),
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
                        Icon(Icons.pie_chart, color: mainColor),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'كمية الكربوهيدرات',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$carbs جرام',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // تاريخ الإضافة
                  Container(
                    padding: EdgeInsets.all(16),
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
                        Icon(Icons.calendar_today, color: mainColor),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'تاريخ الإضافة',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (notes.isNotEmpty) ...[
                    SizedBox(height: 16),
                    // الملاحظات
                    Container(
                      padding: EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'ملاحظات',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.notes, color: mainColor),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            notes,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
