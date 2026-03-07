import 'package:flutter/material.dart';
import 'package:gamezone_flutter/features/Dashboard/presentation/view/bookmark_screen.dart';
import 'package:gamezone_flutter/features/Dashboard/presentation/view/cart_screen.dart';
import 'package:gamezone_flutter/features/Dashboard/presentation/view/profile_screen.dart';
import 'package:gamezone_flutter/features/Dashboard/presentation/view/product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_esports,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "GameZone",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: Colors.white54,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apps),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Bookmarks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _homeBody();
      case 1:
        return const CartScreen();
      case 2:
        return const ProductScreen();
      case 3:
        return const BookmarkScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _homeBody();
    }
  }

  Widget _homeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
                const SizedBox(width: 12),
                Text(
                  "Search games, accessories...",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  top: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "NEW",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Level Up Your Game",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Best deals on gaming gear",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            "Categories",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _CategoryItem(
                  icon: Icons.sports_esports,
                  label: "Games",
                  color: const Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryItem(
                  icon: Icons.headphones,
                  label: "Headsets",
                  color: const Color(0xFFEC4899),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryItem(
                  icon: Icons.mouse,
                  label: "Mouse",
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryItem(
                  icon: Icons.keyboard,
                  label: "Keyboards",
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Featured",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "See All",
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _ProductCard(
                  title: "Xbox Controller",
                  price: "Rs. 9,999",
                  rating: "4.8",
                  image: "assets/images/Xbox.png",
                ),
                _ProductCard(
                  title: "Gaming PC",
                  price: "Rs. 94,499",
                  rating: "4.9",
                  image: "assets/images/GamingPc.png",
                ),
                _ProductCard(
                  title: "PS5",
                  price: "Rs. 69,999",
                  rating: "4.7",
                  image: "assets/images/ps5.png",
                ),
                _ProductCard(
                  title: "Gaming Mouse",
                  price: "Rs. 4,999",
                  rating: "4.5",
                  image: "assets/images/GamingMouse.png",
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Popular",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "See All",
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.headphones,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pro Gaming Headset",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "4.8 (256 reviews)",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Rs. 5,999",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String rating;
  final String image;

  const _ProductCard({
    required this.title,
    required this.price,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
