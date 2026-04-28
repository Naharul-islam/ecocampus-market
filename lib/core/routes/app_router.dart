import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/product/add_product_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/product/my_listings_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/eco/leaderboard_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../features/map/meetup_map_screen.dart';

class AppRouter {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const addProduct = '/add-product';
  static const productDetail = '/product-detail';
  static const myListings = '/my-listings';
  static const chat = '/chat';
  static const chatList = '/chat-list';
  static const notifications = '/notifications';
  static const search = '/search';
  static const profile = '/profile';
  static const leaderboard = '/leaderboard';
  static const wishlist = '/wishlist';
  static const meetupMap = '/meetup-map';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      case productDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => ProductDetailScreen(productData: args ?? {}));
      case myListings:
        return MaterialPageRoute(builder: (_) => const MyListingsScreen());
      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => ChatScreen(chatData: args ?? {}));
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistScreen());
      case meetupMap:
        return MaterialPageRoute(builder: (_) => const MeetupMapScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))));
    }
  }
}
