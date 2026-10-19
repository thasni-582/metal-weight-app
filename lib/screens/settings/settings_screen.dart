import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/core/constants/company_data.dart';
import 'package:metal_weight/core/providers/app_settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Map<String, String>> _languageOptions = [
    {'code': 'en', 'name': 'English (US)'},
    {'code': 'ar', 'name': 'العربية (Arabic)'},
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.strings.get('settings')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildSectionHeader(settings.strings.get('preferences')),
            const SizedBox(height: 8),
            _buildGroupedCard([
              // Dark Mode Switch Row
              _buildSettingRow(
                icon: isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
                title: settings.strings.get('dark_mode'),
                subtitle: isDark ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: settings.isDarkMode,
                  activeThumbColor: AppColors.secondaryOrange,
                  onChanged: (val) {
                    settings.toggleDarkMode(val);
                  },
                ),
                showDivider: true,
                onTap: () {
                  settings.toggleDarkMode(!settings.isDarkMode);
                },
              ),
              // Language Switch Row
              _buildSettingRow(
                icon: Icons.language,
                title: settings.strings.get('language'),
                subtitle: settings.isArabic ? 'العربية (Arabic)' : 'English (US)',
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
                showDivider: false,
                onTap: () {
                  _showLanguageSelectionDialog(settings);
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('COMPANY BRANCHES & OFFICES (KSA)'),
            const SizedBox(height: 8),
            _buildCompanyOfficesCard(isDark),
            const SizedBox(height: 24),
            _buildSectionHeader(settings.strings.get('support_info')),
            const SizedBox(height: 8),
            _buildGroupedCard([
              _buildSettingRow(
                icon: Icons.info_outline,
                title: settings.strings.get('about'),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
                showDivider: true,
                onTap: () {
                  _showAboutDialog();
                },
              ),
              _buildSettingRow(
                icon: Icons.shield_outlined,
                title: settings.strings.get('privacy_policy'),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
                showDivider: true,
                onTap: () {
                  _showPrivacyPolicyDialog();
                },
              ),
              _buildSettingRow(
                icon: Icons.star_outline,
                title: settings.strings.get('rate_app'),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
                showDivider: true,
                onTap: () {
                  _rateApp();
                },
              ),
              _buildSettingRow(
                icon: Icons.share_outlined,
                title: settings.strings.get('share_app'),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
                showDivider: false,
                onTap: () {
                  _shareApp();
                },
              ),
            ]),
            const SizedBox(height: 28),
            const Center(
              child: Column(
                children: [
                  Text(
                    '${CompanyData.companyName} Calculator v2.0',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2026 ${CompanyData.legalName}',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryOrange,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.borderLight,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    bool showDivider = true,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryOrange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.secondaryOrange, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing,
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 0.5,
                color: isDark ? Colors.white12 : AppColors.borderLight,
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog(AppSettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.strings.get('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languageOptions.map((lang) {
            final isSelected = lang['code'] == settings.languageCode;
            return ListTile(
              title: Text(lang['name']!),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.secondaryOrange)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              onTap: () {
                settings.setLanguage(lang['code']!);
                Navigator.pop(context);
                _showSnackBar('Language updated');
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.strings.get('cancel')),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyOfficesCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Header Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: AppColors.secondaryOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CompanyData.companyName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        CompanyData.companySubtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _launchURL(CompanyData.websiteUrl),
                  icon: const Icon(Icons.language, size: 16, color: AppColors.secondaryOrange),
                  label: const Text(
                    'Website',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryOrange,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: AppColors.secondaryOrange.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.white12 : AppColors.borderLight,
          ),
          // Branches List
          ...CompanyData.branches.asMap().entries.map((entry) {
            final int index = entry.key;
            final BranchOffice branch = entry.value;
            final bool isLast = index == CompanyData.branches.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${branch.city} (${branch.region})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryOrange,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              branch.address,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.3,
                                color: isDark ? Colors.white70 : AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _launchURL('tel:${branch.phone.replaceAll(' ', '')}'),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: AppColors.secondaryOrange),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        branch.phone,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : AppColors.textDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => _launchURL('mailto:${branch.email}'),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 14, color: AppColors.secondaryOrange),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        branch.email,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : AppColors.textDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark ? Colors.white12 : AppColors.borderLight,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: CompanyData.companyName,
      applicationVersion: 'v2.0.0',
      applicationLegalese: '© 2026 ${CompanyData.legalName}',
      children: const [
        SizedBox(height: 8),
        Text(
          'Milen Trading Calculator is a professional metal weight & structural profile calculator designed for industrial engineers, fabricators, and metal trading specialists across Saudi Arabia.',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 12),
        Text(
          'Headquarters & Branches:\n• Jeddah (Western Region): Souq-7, Al Rawabi\n• Riyadh (Central Region): 2nd Industrial City\n• Dammam (Eastern Region): 3rd Industrial City\n\nWebsite: www.milantrades.com',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }

  void _showPrivacyPolicyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last updated: October 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Milen Trading values your privacy. This application is designed as an industrial calculation tool prioritizing user privacy and offline reliability.',
                        style: TextStyle(fontSize: 13.5, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _buildPolicySection(
                        '1. Local Data Storage & History',
                        'All calculations, custom profile dimensions, and calculation history records are stored strictly on your local device. We do not transmit or store your calculation records on any external cloud servers.',
                      ),
                      _buildPolicySection(
                        '2. Permissions Used',
                        '• Storage / Media: Used exclusively to generate, save, and export quotation PDFs or share them via WhatsApp/Email upon your request.\n• Internet Access: Used exclusively to open official communication channels (Website, WhatsApp inquiry).',
                      ),
                      _buildPolicySection(
                        '3. No Personal Data Collection',
                        'The app does not require account creation, login, or personal profile details. We do not collect, sell, or rent your private information or business data to third parties or advertising networks.',
                      ),
                      _buildPolicySection(
                        '4. Third-Party Sharing',
                        'No behavioral tracking or background analytics services profile your calculations. Inquiries sent via WhatsApp or email are initiated solely by your explicit user action.',
                      ),
                      _buildPolicySection(
                        '5. Contact Information',
                        'For any privacy inquiries or product quotations, contact us:\n• Milen Trading\n• Headquarters: Jeddah (Souq-7), Saudi Arabia\n• Email: info@milantrades.com\n• Phone: +966 597 67 87 97\n• Website: www.milantrades.com',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPolicySection(String heading, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open URL');
      }
    } catch (_) {
      _showSnackBar('Error opening URL');
    }
  }

  void _rateApp() {
    _launchURL('https://play.google.com/store/apps/details?id=com.milensteel.calculator');
  }

  void _shareApp() {
    Share.share(
      'Check out Milen Trading Calculator - Professional metal weight & engineering profile calculator!\nDownload now: https://play.google.com/store/apps/details?id=com.milensteel.calculator',
      subject: 'Milen Trading Calculator',
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
