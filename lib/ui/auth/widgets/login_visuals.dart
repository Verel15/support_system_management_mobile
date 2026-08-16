import 'package:flutter/material.dart';

import '../../core/theme/brand_colors.dart';

/// "Support Management System" brand logo.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/logo/logo-sms.png', width: 200);
  }
}

/// A frosted pill-shaped text field with a leading icon.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.autocorrect = true,
    this.errorText,
    this.trailing,
  });

  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final String? errorText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            obscureText: obscureText,
            keyboardType: keyboardType,
            autocorrect: autocorrect,
            onChanged: onChanged,
            style: const TextStyle(color: BrandColors.navy),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: BrandColors.fieldIcon),
              prefixIcon: Icon(icon, color: BrandColors.fieldIcon, size: 20),
              suffixIcon: trailing,
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// "──── or ────" section divider.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: BrandColors.fieldIcon)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: BrandColors.muted.withValues(alpha: 0.8))),
        ),
        const Expanded(child: Divider(color: BrandColors.fieldIcon)),
      ],
    );
  }
}

/// Outlined "Continue with X" button. Purely presentational — [onPressed]
/// wiring (real OAuth) is not implemented yet.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label, style: const TextStyle(color: BrandColors.navy, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.7),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
