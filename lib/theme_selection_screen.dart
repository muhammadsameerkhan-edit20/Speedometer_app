import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

class ThemeSelectionScreen extends StatefulWidget {
  @override
  _ThemeSelectionScreenState createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Theme Selection',
              style: TextStyle(
                color: themeProvider.textColor,
              ),
            ),
            backgroundColor: themeProvider.cardColor,
            iconTheme: IconThemeData(
              color: themeProvider.textColor,
            ),
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeProvider.isDarkTheme 
                  ? [Color(0xFF033438), Color(0xFF081214)]
                  : [Color(0xFFE8F5E8), Color(0xFFF0F8F0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Theme',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Light Theme Option
                  _buildThemeOption(
                    title: 'Light Theme',
                    description: 'Clean and bright interface',
                    icon: Icons.light_mode,
                    isSelected: !themeProvider.isDarkTheme,
                    onTap: () => _setTheme(context, false),
                    isDark: false,
                    themeProvider: themeProvider,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Dark Theme Option
                  _buildThemeOption(
                    title: 'Dark Theme',
                    description: 'Easy on the eyes in low light',
                    icon: Icons.dark_mode,
                    isSelected: themeProvider.isDarkTheme,
                    onTap: () => _setTheme(context, true),
                    isDark: true,
                    themeProvider: themeProvider,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Theme Preview
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeProvider.borderColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.speed,
                              color: themeProvider.primaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Speedometer App',
                              style: TextStyle(
                                color: themeProvider.textColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This is how your app will look with the selected theme.',
                          style: TextStyle(
                            color: themeProvider.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _setTheme(BuildContext context, bool isDark) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.setTheme(isDark);
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDark ? 'Dark theme applied' : 'Light theme applied',
        ),
        backgroundColor: isDark ? Colors.grey[800]! : Colors.white,
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? (isDark ? Colors.cyan : Colors.blue)
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? (isDark ? Colors.cyan : Colors.blue)
                  : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected 
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: isDark ? Colors.cyan : Colors.blue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
