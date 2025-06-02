import 'package:flutter/foundation.dart';
import 'package:appwrite/models.dart';
import '../appWrite/appwrite_client.dart' as appwrite;

class MealProvider with ChangeNotifier {
  List<Document> _meals = [];
  List<Document> _favoriteMeals = [];
  Set<String> _favoriteMealIds = {};
  bool _isLoading = false;
  String? _error;

  List<Document> get meals => _meals;
  List<Document> get favoriteMeals => _favoriteMeals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تحميل جميع الوجبات
  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final meals = await appwrite.AppwriteClient.getMeals();
      _meals = meals;
      notifyListeners();
    } catch (e) {
      print('Error loading meals: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحميل الوجبات المفضلة للمستخدم
  Future<void> loadFavoriteMeals(String userId) async {
    try {
      final favorites = await appwrite.AppwriteClient.getFavoriteMeals(userId);
      _favoriteMeals = favorites;
      _favoriteMealIds = Set.from(favorites.map((meal) => meal.$id));
      notifyListeners();
    } catch (e) {
      print('Error loading favorite meals: $e');
      _error = e.toString();
      rethrow;
    }
  }

  /// إضافة وجبة جديدة
  Future<bool> addMeal({
    required String mealName,
    required double carbs,
    String? restaurantName,
    String? notes,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final document = await appwrite.AppwriteClient.createMeal(
        mealName: mealName,
        carbs: carbs,
        restaurantName: restaurantName,
        notes: notes,
        imageUrl: imageUrl,
      );

      _meals.insert(0, document);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding meal: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة وجبة إلى المفضلة
  Future<void> toggleFavorite(String mealId, String userId) async {
    final wasInFavorites = _favoriteMealIds.contains(mealId);

    // Optimistic update
    if (wasInFavorites) {
      _favoriteMealIds.remove(mealId);
      _favoriteMeals.removeWhere((meal) => meal.$id == mealId);
    } else {
      _favoriteMealIds.add(mealId);
      final meal = _meals.firstWhere((m) => m.$id == mealId);
      _favoriteMeals.add(meal);
    }
    notifyListeners();

    try {
      if (wasInFavorites) {
        await appwrite.AppwriteClient.removeFromFavorites(mealId, userId);
      } else {
        await appwrite.AppwriteClient.addToFavorites(mealId, userId);
      }
    } catch (e) {
      // Revert on error
      if (wasInFavorites) {
        _favoriteMealIds.add(mealId);
        final meal = _meals.firstWhere((m) => m.$id == mealId);
        _favoriteMeals.add(meal);
      } else {
        _favoriteMealIds.remove(mealId);
        _favoriteMeals.removeWhere((meal) => meal.$id == mealId);
      }
      notifyListeners();
      _error = e.toString();
      rethrow;
    }
  }

  /// التحقق من حالة المفضلة
  bool checkFavoriteStatus(String mealId, String userId) {
    return _favoriteMealIds.contains(mealId);
  }

  /// حذف وجبة
  Future<void> deleteMeal(String mealId) async {
    try {
      await appwrite.AppwriteClient.deleteMeal(mealId);
      _meals.removeWhere((meal) => meal.$id == mealId);
      _favoriteMeals.removeWhere((meal) => meal.$id == mealId);
      _favoriteMealIds.remove(mealId);
      notifyListeners();
    } catch (e) {
      print('Error deleting meal: $e');
      _error = e.toString();
      rethrow;
    }
  }
}
