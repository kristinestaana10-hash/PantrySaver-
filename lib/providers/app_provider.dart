import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrysaver/models/user_profile.dart';
import 'package:pantrysaver/services/auth_service.dart';
import 'package:pantrysaver/services/budget_service.dart';
import 'package:pantrysaver/services/pantry_service.dart';
import 'package:pantrysaver/services/shopping_service.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    try {
      _authService.authStateChanges.listen((user) {
        currentUser = user;
        if (user != null) {
          loadProfile(user.uid);
        }
        notifyListeners();
      });
    } catch (_) {
      // Firebase may not be initialized in tests or early startup; the UI can still work.
    }
  }

  final AuthService _authService = AuthService();
  PantryService? _pantryService;
  BudgetService? _budgetService;
  ShoppingService? _shoppingService;

  User? currentUser;
  UserProfile? profile;
  bool isLoading = false;
  bool darkMode = false;
  String? errorMessage;

  Future<void> signUp({required String email, required String password, required String fullName}) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();
    try {
      final credential = await _authService.signUp(email: email, password: password, fullName: fullName);
      currentUser = credential.user;
      if (credential.user != null) {
        await loadProfile(credential.user!.uid);
      }
    } catch (e) {
      errorMessage = AppProvider.formatExceptionMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();
    try {
      final credential = await _authService.signIn(email: email, password: password);
      currentUser = credential.user;
      if (credential.user != null) {
        await loadProfile(credential.user!.uid);
      }
    } catch (e) {
      errorMessage = AppProvider.formatExceptionMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    errorMessage = null;
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      errorMessage = AppProvider.formatExceptionMessage(e);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    currentUser = null;
    profile = null;
    notifyListeners();
  }

  Future<void> loadProfile(String uid) async {
    try {
      profile = await _authService.getUserProfile(uid);
    } catch (e) {
      profile = null;
      errorMessage ??= AppProvider.formatExceptionMessage(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile updated) async {
    await _authService.updateUserProfile(updated);
    profile = updated;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
  }

  PantryService get pantryService {
    _pantryService ??= PantryService();
    return _pantryService!;
  }

  BudgetService get budgetService {
    _budgetService ??= BudgetService(firebaseEnabled: true);
    return _budgetService!;
  }

  ShoppingService get shoppingService {
    _shoppingService ??= ShoppingService();
    return _shoppingService!;
  }

  static String formatExceptionMessage(Object e) {
    if (e is FirebaseAuthException) {
      return e.message ?? 'Authentication failed. Please check your Firebase configuration.';
    }
    if (e is FirebaseException) {
      return e.message ?? 'Firestore or Firebase failed. Please check your Firebase configuration.';
    }
    if (e is Exception) {
      final message = e.toString();
      final prefix = 'Exception: ';
      if (message.startsWith(prefix)) {
        return message.substring(prefix.length).trim();
      }
      return message;
    }
    return e.toString();
  }
}
