import 'package:flutter/material.dart';

// General Constants
const String appName = "Resep Kita";

// Firebase Collection Names
const String recipesCollection = "recipes";
const String usersCollection = "users";
const String favoritesCollection = "favorites";

// Padding and Margin Sizes
const double defaultPadding = 16.0;
const double defaultMargin = 16.0;
const double cardRadius = 12.0;

// Text Styles
const TextStyle appBarTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle titleTextStyle = TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

const TextStyle subtitleTextStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w600,
  color: Colors.grey,
);

const TextStyle bodyTextStyle = TextStyle(
  fontSize: 14.0,
  color: Colors.black87,
);

// Image Assets
const String logoPath = 'assets/logo.png';
const String defaultProfilePic = 'assets/default_profile_pic.png';

// Firestore Field Names
const String fieldTitle = 'title';
const String fieldDescription = 'description';
const String fieldImageUrl = 'imageUrl';
const String fieldUserId = 'userId';
const String fieldRating = 'rating';
const String fieldIngredients = 'ingredients';
const String fieldSteps = 'steps';
const String fieldCreatedAt = 'createdAt';

// Firebase Storage Path
const String storagePathRecipeImages = 'recipe_images/';

// Button Titles
const String signInButtonTitle = 'Sign In';
const String signUpButtonTitle = 'Sign Up';
const String submitButtonTitle = 'Submit';
const String postRecipeButtonTitle = 'Post Recipe';
const String addToFavoritesButtonTitle = 'Add to Favorites';
const String removeFromFavoritesButtonTitle = 'Remove from Favorites';

// Notification Titles
const String notificationNewRecipe = 'New Recipe Alert';
const String notificationNewComment = 'New Comment on Your Recipe';
const String notificationNewFollow = 'You have a new Follower';

// Rating Constants
const double minRating = 1.0;
const double maxRating = 5.0;

// Firebase Rules Constants (for security rules configuration)
const String firebaseRuleUser = 'user';
const String firebaseRuleRecipe = 'recipe';
const String firebaseRuleFavorites = 'favorites';

// App Theme Colors
const Color primaryColor = Color(0xFF6F35A5);
const Color secondaryColor = Color(0xFFF1E6FF);
const Color accentColor = Color(0xFF6200EE);

// Notifications Constants
const int notificationChannelId = 1;
const String notificationChannelName = "Resep Kita Notifications";
const String notificationChannelDescription =
    "Notifications for new recipes, comments, and follows.";

// Error Messages
const String errorInvalidEmail = "Please enter a valid email address.";
const String errorInvalidPassword =
    "Password must be at least 6 characters long.";
const String errorNetworkIssue = "Please check your internet connection.";
const String errorUserNotFound = "No user found with this email.";
const String errorUnknown = "An unknown error occurred. Please try again.";

// Success Messages
const String successRecipeAdded = "Recipe added successfully!";
const String successProfileUpdated = "Profile updated successfully!";
const String successFavoriteAdded = "Recipe added to favorites!";
const String successFavoriteRemoved = "Recipe removed from favorites!";
