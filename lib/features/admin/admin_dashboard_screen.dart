import 'package:flutter/material.dart';
import 'package:gladiatorapp/core/services/admin_service.dart';
import 'package:gladiatorapp/core/services/auth_service.dart';
import 'package:gladiatorapp/data/models/admin_model.dart';
import 'package:gladiatorapp/features/admin/admin_news_screen.dart';
import 'package:gladiatorapp/features/admin/admin_qr_scanner_screen.dart';
import 'package:gladiatorapp/features/admin/AdminTariffs/admin_tariffs_screen.dart';
import 'package:gladiatorapp/features/home/settings_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();

  // Цвета для светлой темы
  final Color _redAccent = const Color(0xFFE53935);
  final Color _blueAccent = Colors.blue.shade700;
  final Color _greenAccent = Colors.green.shade700;

  AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Админ-панель',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: _redAccent),
            onPressed: () {
              _authService.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<AdminUser?>(
        future: _adminService.getAdminUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: _redAccent,
              ),
            );
          }

          final adminUser = snapshot.data;

          if (adminUser == null) {
            return Center(
              child: Text(
                'Доступ запрещен',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontSize: 18,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Управление системой',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Выберите раздел для администрирования',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      if (adminUser.canScanQr)
                        _buildAdminCard(
                          context,
                          title: 'Сканировать QR-код',
                          icon: Icons.qr_code_scanner,
                          color: _redAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminQrScannerScreen(),
                            ),
                          ),
                        ),
                      _buildAdminCard(
                        context,
                        title: 'Управление тарифами',
                        icon: Icons.attach_money,
                        color: _blueAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminTariffsScreen()),
                          );
                        },
                      ),
                      _buildAdminCard(
                        context,
                        title: 'Управление новостями',
                        icon: Icons.newspaper,
                        color: _greenAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminNewsScreen()),
                          );
                        },
                      ),
                      _buildAdminCard(
                        context,
                        title: 'Настройки приложения',
                        icon: Icons.settings,
                        color: Colors.grey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? theme.cardColor : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.chevron_right,
                color: color,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}