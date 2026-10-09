import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/chat_copy.dart';
import '../models/models.dart';
import '../services/child_photo.dart';
import '../widgets/mc_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.booking, super.key});

  final Booking booking;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  StreamSubscription<List<ChatMessage>>? _messagesSub;
  List<ChatMessage>? _remote;
  String _chatId = '';
  bool _sending = false;
  String? _note;

  @override
  void initState() {
    super.initState();
    _chatId = widget.booking.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bind());
  }

  Future<void> _bind() async {
    final state = AppScope.of(context);
    final id = await state.openChat(widget.booking);
    if (!mounted) return;
    setState(() => _chatId = id);
    _messagesSub?.cancel();
    _messagesSub = state.watchMessages(id)?.listen(
      (messages) {
        if (mounted) setState(() => _remote = messages);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    final state = AppScope.of(context);
    setState(() => _sending = true);
    final error = await state.sendChatMessage(chatId: _chatId, reservaId: widget.booking.id, texto: text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (error != null) {
      state.flash(state.tr(error));
      return;
    }
    _input.clear();
    setState(() => _note = null);
  }

  Future<void> _sendPhoto() async {
    if (_photoPerm() == 'red' || _sending) return;
    final photo = await pickChildPhoto();
    if (!mounted || photo == null) return;
    if (photo.length > 700000) {
      setState(() => _note = cx(AppScope.of(context).lang, 'photoBig'));
      return;
    }
    final state = AppScope.of(context);
    setState(() => _sending = true);
    final error = await state.sendChatMessage(chatId: _chatId, reservaId: widget.booking.id, texto: '', imageUrl: photo);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _note = error == null ? null : state.tr(error);
    });
    if (error != null) state.flash(state.tr(error));
  }

  String _photoPerm() {
    final value = AppScope.of(context).user?.perfil['consentimentImatge'];
    if (value == 'corporatiu') return 'green';
    if (value == 'cap') return 'red';
    return 'yellow';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _Look.of(context);
    final booking = widget.booking;
    final carerView = state.user?.role == UserRole.cangur;
    final family = booking.padreNombre.trim();
    final name = carerView ? (family.isEmpty ? cx(lang, 'theFamily') : family) : _name(state, booking);
    final color = state.profileFor(booking.canguroId ?? '')?.color ?? 0xFF6E82A6;
    final messages = _remote ?? state.messagesFor(booking.id);
    final perm = _photoPerm();
    return Scaffold(
      backgroundColor: colors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(color: colors.bg, border: Border(bottom: BorderSide(color: colors.line))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    child: Row(
                      children: [
                        Material(
                          color: colors.menta15,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: colors.ink)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Color(color), borderRadius: BorderRadius.circular(13)),
                          child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: colors.ink)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(width: 7, height: 7, decoration: BoxDecoration(color: colors.ok, shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '${cx(lang, carerView ? 'theFamily' : 'yourCangur')} · ${formatDate(booking.fecha)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: _permBanner(colors, lang, perm)),
                Expanded(child: _thread(colors, lang, messages, state.user?.id ?? '', carerView)),
                _composer(colors, lang, perm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _permBanner(_Look colors, AppLang lang, String perm) {
    final heading = cx(lang, perm == 'green' ? 'permGreenH' : (perm == 'red' ? 'permRedH' : 'permYellowH'));
    final detail = cx(lang, perm == 'green' ? 'permGreenD' : (perm == 'red' ? 'permRedD' : 'permYellowD'));
    final tone = perm == 'green' ? colors.ok : (perm == 'red' ? const Color(0xFFC0705F) : const Color(0xFFB9861F));
    final wash = perm == 'green' ? const Color(0x246F9E86) : (perm == 'red' ? const Color(0x26C0705F) : const Color(0x26D69E2E));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: wash, borderRadius: BorderRadius.circular(14), border: Border.all(color: tone.withValues(alpha: 0.5), width: 1.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tone.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(9)),
            child: Icon(perm == 'red' ? Icons.no_photography_outlined : Icons.photo_camera_outlined, size: 17, color: tone),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(heading, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 13.5, color: tone)),
                const SizedBox(height: 2),
                Text(detail, style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, height: 1.45, color: colors.text)),
                if (_note != null) ...[
                  const SizedBox(height: 6),
                  Text(_note!, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: tone)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thread(_Look colors, AppLang lang, List<ChatMessage> messages, String mine, bool carerView) {
    final items = <Widget>[
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(13)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, size: 15, color: colors.mentaD),
            const SizedBox(width: 9),
            Expanded(child: Text.rich(_marked(cx(lang, carerView ? 'privCarer' : 'priv'), TextStyle(fontFamily: 'Nunito', fontSize: 12, height: 1.5, color: colors.text), TextStyle(fontFamily: 'Nunito', fontSize: 12, height: 1.5, fontWeight: FontWeight.w800, color: colors.ink)))),
          ],
        ),
      ),
    ];
    String? day;
    for (final message in messages) {
      final key = '${message.fecha.year}-${message.fecha.month}-${message.fecha.day}';
      if (key != day) {
        day = key;
        final today = DateTime.now();
        final label = message.fecha.year == today.year && message.fecha.month == today.month && message.fecha.day == today.day
            ? cx(lang, 'today')
            : formatDate(message.fecha);
        items.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, color: colors.text2)),
        ));
      }
      items.add(_bubble(colors, message, message.remitenteId == mine));
    }
    return ListView(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      children: items.reversed.toList(),
    );
  }

  Widget _bubble(_Look colors, ChatMessage message, bool outgoing) {
    final bytes = _photoBytes(message.imageUrl);
    final time = '${message.fecha.hour.toString().padLeft(2, '0')}:${message.fecha.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: outgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: outgoing ? colors.mentaD : colors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(outgoing ? 18 : 6),
            bottomRight: Radius.circular(outgoing ? 6 : 18),
          ),
          border: outgoing ? null : Border.all(color: colors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bytes != null) Padding(padding: const EdgeInsets.only(bottom: 3), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(bytes, width: 210, fit: BoxFit.cover))),
            if (bytes == null && message.imageUrl.startsWith('http'))
              Padding(padding: const EdgeInsets.only(bottom: 3), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(message.imageUrl, width: 210, fit: BoxFit.cover))),
            if (message.texto.isNotEmpty) Text(message.texto, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.45, color: outgoing ? Colors.white : colors.ink)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontFamily: 'Nunito', fontSize: 10.5, color: outgoing ? const Color(0xCCFFFFFF) : colors.text2)),
          ],
        ),
      ),
    );
  }

  Widget _composer(_Look colors, AppLang lang, String perm) {
    final blocked = perm == 'red';
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.bg, border: Border(top: BorderSide(color: colors.line))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Material(
              color: colors.card,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: blocked ? null : _sendPhoto,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: blocked ? colors.line : colors.brun, width: 1.5),
                  ),
                  child: Icon(blocked ? Icons.no_photography_outlined : Icons.photo_camera_outlined, color: blocked ? colors.text2 : colors.brun, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                key: const Key('chat-input'),
                controller: _input,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
                decoration: InputDecoration(
                  hintText: cx(lang, 'placeholder'),
                  filled: true,
                  fillColor: colors.card,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: colors.line, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: colors.menta, width: 1.6)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: colors.mentaD,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _sending ? null : _send,
                customBorder: const CircleBorder(),
                child: const SizedBox(width: 46, height: 46, child: Icon(Icons.send, color: Colors.white, size: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _name(dynamic state, Booking booking) {
  final stored = booking.canguroNombre?.trim() ?? '';
  if (stored.isNotEmpty) return stored;
  final profile = state.profileFor(booking.canguroId ?? '');
  final name = profile?.nombre as String? ?? '';
  return name.trim().isEmpty ? 'Cangur' : name.trim();
}

TextSpan _marked(String source, TextStyle base, TextStyle bold) {
  final parts = source.split('**');
  return TextSpan(
    children: [
      for (var i = 0; i < parts.length; i++) TextSpan(text: parts[i], style: i.isOdd ? bold : base),
    ],
  );
}

Uint8List? _photoBytes(String photo) {
  if (!photo.contains(',')) return null;
  try {
    return base64Decode(photo.split(',').last);
  } catch (_) {
    return null;
  }
}

class _Look {
  const _Look({
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

  static const light = _Look(
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
  );

  static const dark = _Look(
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
  );

  static _Look of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}
