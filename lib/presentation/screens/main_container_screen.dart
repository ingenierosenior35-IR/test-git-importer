import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../features/home/presentation/screens/home_page.dart';
import '../../features/matches/presentation/screens/matches_list_screen.dart';
import 'video/video_upload_screen.dart';
import 'analysis/match_history_screen.dart';
import 'profile/profile_screen.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({Key? key}) : super(key: key);

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    const MatchesListScreen(),
    const VideoUploadScreen(),
    const MatchHistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on Home tab, navigate to Home first
      setState(() => _selectedIndex = 0);
      return false;
    }
    // On Home tab → exit the app
    SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.kDarkBackground,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.kDarkCard,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, 'Inicio', 0),
                  _buildNavItem(Icons.sports_soccer_rounded, 'Partidos', 1),
                  _buildNavItem(Icons.videocam_rounded, 'Video', 2),
                  _buildNavItem(Icons.analytics_rounded, 'Análisis', 3),
                  _buildNavItem(Icons.person_rounded, 'Perfil', 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.kYellowAccent.withOpacity(0.12) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.kYellowAccent : AppColors.kGrey,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.kYellowAccent : AppColors.kGrey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
