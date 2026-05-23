import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../providers/movie_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final favs   = context.watch<FavouritesProvider>();
    final movies = context.watch<MovieProvider>();
    final theme  = context.watch<ThemeProvider>();
    final user   = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [

              // ── Header ────────────────────────────────────────
              _ProfileHeader(
                name:     user?.name     ?? 'Movie Fan',
                email:    user?.email    ?? '',
                photoUrl: user?.photoUrl ?? '',
                onEditPhoto: () => _pickProfilePhoto(context, auth),
              ),

              const SizedBox(height: 8),

              // ── Stats row ─────────────────────────────────────
              _StatsRow(
                favouriteCount: favs.favourites.length,
                ratedCount:     movies.ratedMoviesCount,
                watchedCount:   movies.watchedCount,
              ),

              const SizedBox(height: 24),

              // ── Account section ───────────────────────────────
              _SectionLabel(label: 'Account'),
              _SettingsTile(
                icon:    Icons.person_outline_rounded,
                label:   'Edit Profile',
                onTap:   () => _showEditProfile(context, auth),
              ),
              _SettingsTile(
                icon:    Icons.lock_outline_rounded,
                label:   'Change Password',
                onTap:   () => _showChangePassword(context, auth),
              ),
              _SettingsTile(
                icon:    Icons.notifications_none_rounded,
                label:   'Notifications',
                trailing: Switch(
                  value:       true,
                  activeThumbColor: AppColors.primary,
                  onChanged:   (_) {},
                ),
                onTap: () {},
              ),

              const SizedBox(height: 8),

              // ── Preferences section ───────────────────────────
              _SectionLabel(label: 'Preferences'),
              _SettingsTile(
                icon:  Icons.dark_mode_outlined,
                label: 'Dark Mode',
                trailing: Switch(
                  value:       theme.isDark,
                  activeThumbColor: AppColors.primary,
                  onChanged:   (_) => theme.toggleTheme(),
                ),
                onTap: () => theme.toggleTheme(),
              ),
              _SettingsTile(
                icon:    Icons.language_outlined,
                label:   'Language',
                value:   'English',
                onTap:   () {},
              ),
              _SettingsTile(
                icon:    Icons.hd_outlined,
                label:   'Streaming Quality',
                value:   'HD',
                onTap:   () => _showQualitySheet(context),
              ),

              const SizedBox(height: 8),

              // ── About section ─────────────────────────────────
              _SectionLabel(label: 'About'),
              _SettingsTile(
                icon:  Icons.star_outline_rounded,
                label: 'Rate the App',
                onTap: () {},
              ),
              _SettingsTile(
                icon:  Icons.share_outlined,
                label: 'Share MoviHub',
                onTap: () {},
              ),
              _SettingsTile(
                icon:  Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              _SettingsTile(
                icon:  Icons.info_outline_rounded,
                label: 'App Version',
                value: 'v1.0.0',
                onTap: () {},
              ),

              const SizedBox(height: 8),

              // ── Session section ───────────────────────────────
              _SectionLabel(label: 'Session'),
              _SettingsTile(
                icon:      Icons.logout_rounded,
                label:     AppStrings.logout,
                iconColor: AppColors.error,
                textColor: AppColors.error,
                onTap:     () => _confirmLogout(context, auth),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pick profile photo ────────────────────────────────────────────────────
  Future<void> _pickProfilePhoto(
      BuildContext context, AuthProvider auth) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context:         context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width:  40,
                height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w600,
                color:      AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Take a photo',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(
                  source:      ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null && context.mounted) {
                  await auth.updateProfilePhoto(File(image.path));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile photo updated! ✅'),
                        backgroundColor: AppColors.surface,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(
                  source:      ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null && context.mounted) {
                  await auth.updateProfilePhoto(File(image.path));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile photo updated! ✅'),
                        backgroundColor: AppColors.surface,
                      ),
                    );
                  }
                }
              },
            ),
            if (auth.currentUser?.photoUrl.isNotEmpty == true)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.updateProfile(photoUrl: '');
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Edit profile bottom sheet ─────────────────────────────────────────────
  void _showEditProfile(BuildContext context, AuthProvider auth) {
    final nameCtrl =
        TextEditingController(text: auth.currentUser?.name ?? '');

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize:      MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width:  40,
                height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.w600,
                color:      AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText:  'Display Name',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                filled:     true,
                fillColor:  AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:   const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width:  double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    await auth.updateProfile(name: nameCtrl.text.trim());
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:         Text('Profile updated! ✅'),
                          backgroundColor: AppColors.surface,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Change password bottom sheet ──────────────────────────────────────────
  void _showChangePassword(BuildContext context, AuthProvider auth) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize:      MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width:  40,
                height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.w600,
                color:      AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _PasswordField(
              controller: currentCtrl,
              label:      'Current Password',
            ),
            const SizedBox(height: 14),
            _PasswordField(
              controller: newCtrl,
              label:      'New Password',
            ),
            const SizedBox(height: 14),
            _PasswordField(
              controller: confirmCtrl,
              label:      'Confirm New Password',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width:  double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (newCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:         Text('Passwords do not match!'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  final error = await auth.changePassword(
                    currentPassword: currentCtrl.text,
                    newPassword:     newCtrl.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error ?? 'Password changed successfully! ✅',
                        ),
                        backgroundColor:
                            error != null ? AppColors.error : AppColors.surface,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quality sheet ─────────────────────────────────────────────────────────
  void _showQualitySheet(BuildContext context) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        child: Column(
          mainAxisSize:      MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width:  40,
                height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Streaming Quality',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w600,
                color:      AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            for (final q in ['Auto', 'HD (1080p)', 'SD (720p)', 'Low (480p)'])
              ListTile(
                title: Text(
                  q,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                trailing: q == 'HD (1080p)'
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }

  // ── Logout confirm ────────────────────────────────────────────────────────
  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout?',
          style: TextStyle(
            fontSize:   18,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout from MoviHub?',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color:      AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile header ────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String    name;
  final String    email;
  final String    photoUrl;
  final VoidCallback onEditPhoto;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: onEditPhoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius:          44,
                  backgroundColor: AppColors.surfaceLight,
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'M',
                          style: const TextStyle(
                            fontSize:   36,
                            fontWeight: FontWeight.bold,
                            color:      AppColors.primary,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right:  0,
                  child: Container(
                    width:  28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size:  15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            name,
            style: const TextStyle(
              fontSize:   20,
              fontWeight: FontWeight.bold,
              color:      AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            email,
            style: const TextStyle(
              fontSize: 13,
              color:    AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color:        AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  size:  14,
                ),
                SizedBox(width: 5),
                Text(
                  'MoviHub Member',
                  style: TextStyle(
                    fontSize:   12,
                    color:      AppColors.primary,
                    fontWeight: FontWeight.w500,
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

// ── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int favouriteCount;
  final int ratedCount;
  final int watchedCount;

  const _StatsRow({
    required this.favouriteCount,
    required this.ratedCount,
    required this.watchedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          _StatItem(value: '$favouriteCount', label: 'Favourites'),
          _Divider(),
          _StatItem(value: '$ratedCount',     label: 'Rated'),
          _Divider(),
          _StatItem(value: '$watchedCount',   label: 'Watched'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize:   22,
              fontWeight: FontWeight.bold,
              color:      AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 36, color: AppColors.border);
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize:      11,
          fontWeight:    FontWeight.w600,
          color:         AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final String?      value;
  final Widget?      trailing;
  final VoidCallback onTap;
  final Color?       iconColor;
  final Color?       textColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.trailing,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 2),
      child: ListTile(
        onTap:     onTap,
        tileColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 0.3),
        ),
        leading: Container(
          width:  36,
          height: 36,
          decoration: BoxDecoration(
            color:        (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size:  20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize:   14,
            color:      textColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null)
                  Text(
                    value!,
                    style: const TextStyle(
                      fontSize: 13,
                      color:    AppColors.textMuted,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size:  20,
                ),
              ],
            ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        minLeadingWidth: 36,
      ),
    );
  }
}

// ── Password field ────────────────────────────────────────────────────────────
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String                label;
  const _PasswordField({required this.controller, required this.label});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:  widget.controller,
      obscureText: _obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText:  widget.label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        filled:     true,
        fillColor:  AppColors.background,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textMuted,
            size:  20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}