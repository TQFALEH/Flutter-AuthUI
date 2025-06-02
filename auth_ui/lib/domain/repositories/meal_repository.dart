import '../entities/meal.dart';

abstract class MealRepository {
  /// Get all meals for the current user
  Future<List<Meal>> getMeals();

  /// Get favorite meals for the current user
  Future<List<Meal>> getFavoriteMeals();

  /// Add a new meal
  Future<Meal> addMeal(Meal meal);

  /// Update an existing meal
  Future<Meal> updateMeal(Meal meal);

  /// Delete a meal by ID
  Future<void> deleteMeal(String id);

  /// Toggle favorite status for a meal
  Future<void> toggleFavorite(String mealId);

  /// Upload a meal image and return the URL
  Future<String> uploadMealImage(String filePath, String fileName);

  /// Check if a meal is marked as favorite
  Future<bool> isFavorite(String mealId);
}
