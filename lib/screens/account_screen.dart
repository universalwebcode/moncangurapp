import 'package:flutter/material.dart';

import '../l10n/app_copy.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/mc_widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.admin = false, this.cangur = false});

  final bool admin;
  final bool cangur;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _loadedFor;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _load(AppUser user) {
    if (_loadedFor == user.id) return;
    _loadedFor = user.id;
    _name.text = user.nombre;
    _phone.text = user.telefono;
    _address.text = user.direccion;
    _emergencyName.text = user.contactoEmergenciaNombre;
    _emergencyPhone.text = user.contactoEmergenciaTelefono;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.user;
    if (user == null) return const SizedBox.shrink();
    _load(user);
    return PageWidth(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            children: [
              Expanded(child: Text(state.tr('accountInfo'), style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 30))),
              const LanguageMenu(),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.admin ? state.tr('adminHint') : state.tr('contactLong'), style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(labelText: state.tr('yourName')),
                  onChanged: (v) => user.nombre = v,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phone,
                  decoration: InputDecoration(labelText: state.tr('phone')),
                  onChanged: (v) => user.telefono = v,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _address,
                  decoration: InputDecoration(labelText: state.tr('homeAddress')),
                  onChanged: (v) => user.direccion = v,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emergencyName,
                  decoration: InputDecoration(labelText: state.tr('emergencyName')),
                  onChanged: (v) => user.contactoEmergenciaNombre = v,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emergencyPhone,
                  decoration: InputDecoration(labelText: state.tr('emergencyPhone')),
                  onChanged: (v) => user.contactoEmergenciaTelefono = v,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(state.tr('preferredLanguages'), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final language in languageOptions)
                      FilterChip(
                        label: Text(language),
                        selected: user.idiomasCanguro.contains(language),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              user.idiomasCanguro = [...user.idiomasCanguro, language];
                            } else {
                              user.idiomasCanguro = user.idiomasCanguro.where((l) => l != language).toList();
                            }
                          });
                          state.updateAccount(user);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(state.tr('changePassword'), style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(state.tr('passwordHint'), style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                TextField(controller: _current, obscureText: true, decoration: InputDecoration(labelText: state.tr('currentPassword'))),
                const SizedBox(height: 8),
                TextField(controller: _next, obscureText: true, decoration: InputDecoration(labelText: state.tr('newPassword'))),
                const SizedBox(height: 8),
                TextField(controller: _confirm, obscureText: true, decoration: InputDecoration(labelText: state.tr('confirmNew'))),
                if (state.banner != null) ...[
                  const SizedBox(height: 8),
                  Text(state.banner!, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    final ok = state.changePassword(_current.text, _next.text, _confirm.text);
                    if (ok) {
                      _current.clear();
                      _next.clear();
                      _confirm.clear();
                    }
                  },
                  child: Text(state.tr('save')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.tr('contact'), style: const TextStyle(height: 1.4)),
                const SizedBox(height: 8),
                Text(widget.cangur ? state.tr('cangurSignOut') : widget.admin ? state.tr('adminOut') : state.tr('signOut')),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    state.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                  child: Text(state.tr('signOut')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
