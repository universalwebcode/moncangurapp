import 'package:flutter/material.dart';

import '../l10n/cangur_copy.dart';
import '../l10n/chat_copy.dart';
import '../l10n/menu_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).refreshChatPreviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _ChatColors.of(context);
    final threads = [
      for (final booking in state.bookingsForCurrent())
        if (booking.canguroId != null && booking.canguroId!.isNotEmpty) booking,
    ]..sort((a, b) => b.fecha.compareTo(a.fecha));
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _ChatTop(
                  colors: colors,
                  title: state.user?.role == UserRole.cangur ? cg(lang, 'chatParents') : mn(lang, 'chat'),
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: threads.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
                          child: Column(
                            children: [
                              Text(cx(lang, 'empty'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: colors.ink)),
                              const SizedBox(height: 8),
                              Text(
                                cx(lang, state.user?.role == UserRole.cangur ? 'emptySubCarer' : 'emptySub'),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Nunito', fontSize: 14, height: 1.5, color: colors.text2),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                          itemCount: threads.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final booking = threads[index];
                            final preview = state.chatPreviews[booking.id];
                            final name = state.user?.role == UserRole.cangur ? _familyName(booking) : _carerName(state, booking);
                            final last = preview?.ultimoMensaje ?? '';
                            return Material(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(booking: booking)));
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: colors.line, width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      _ChatAvatar(name: name, color: _carerColor(state, booking), size: 52, radius: 16),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink)),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${formatDate(booking.fecha)} · ${booking.horaInicio}',
                                              style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, color: colors.text2),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              last.isEmpty ? cx(lang, 'start') : last,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5, color: last.isEmpty ? colors.text2 : colors.text),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right, color: colors.text2),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _familyName(Booking booking) {
  final name = booking.padreNombre.trim();
  return name.isEmpty ? 'Família' : name;
}

String _carerName(dynamic state, Booking booking) {
  final stored = booking.canguroNombre?.trim() ?? '';
  if (stored.isNotEmpty) return stored;
  final profile = state.profileFor(booking.canguroId ?? '');
  final name = profile?.nombre?.trim() ?? '';
  return name.isEmpty ? 'Cangur' : name;
}

int _carerColor(dynamic state, Booking booking) {
  final profile = state.profileFor(booking.canguroId ?? '');
  return profile?.color ?? 0xFF6E82A6;
}

class _ChatTop extends StatelessWidget {
  const _ChatTop({required this.colors, required this.title, required this.onBack});

  final _ChatColors colors;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.bg, border: Border(bottom: BorderSide(color: colors.line))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Row(
          children: [
            Material(
              color: colors.menta15,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: colors.ink)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink))),
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.name, required this.color, required this.size, required this.radius});

  final String name;
  final int color;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Color(color), borderRadius: BorderRadius.circular(radius)),
      child: Text(initial, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: size * 0.38, color: Colors.white)),
    );
  }
}

class _ChatColors {
  const _ChatColors({
    required this.bg,
    required this.card,
    required this.menta,
    required this.mentaD,
    required this.menta15,
    required this.ink,
    required this.text,
    required this.text2,
    required this.line,
    required this.brun,
    required this.ok,
    required this.shadow,
  });

  final Color bg;
  final Color card;
  final Color menta;
  final Color mentaD;
  final Color menta15;
  final Color ink;
  final Color text;
  final Color text2;
  final Color line;
  final Color brun;
  final Color ok;
  final Color shadow;

  static const light = _ChatColors(
    bg: Color(0xFFFAF8F5),
    card: Color(0xFFFFFFFF),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x26B3CFC4),
    ink: Color(0xFF1A1A1A),
    text: Color(0xFF5A5550),
    text2: Color(0xFF6B6560),
    line: Color(0x14000000),
    brun: Color(0xFFA98E7B),
    ok: Color(0xFF6F9E86),
    shadow: Color(0x0D000000),
  );

  static const dark = _ChatColors(
    bg: Color(0xFF181511),
    card: Color(0xFF221F1B),
    menta: Color(0xFFB3CFC4),
    mentaD: Color(0xFF8CA598),
    menta15: Color(0x1FB3CFC4),
    ink: Color(0xFFF7F3EE),
    text: Color(0xFFC9C3BA),
    text2: Color(0xFFA49D93),
    line: Color(0x1AFFFFFF),
    brun: Color(0xFFA98E7B),
    ok: Color(0xFF6F9E86),
    shadow: Color(0x66000000),
  );

  static _ChatColors of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}
