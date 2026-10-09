import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/chat_copy.dart';
import '../models/models.dart';
import '../widgets/mc_widgets.dart';

const _palette = [0xFF6E82A6, 0xFFC08457, 0xFF8CA598, 0xFF9487B3, 0xFFA98E7B];

const _shortDays = [
  ['dl', 'dt', 'dc', 'dj', 'dv', 'ds', 'dg'],
  ['lu', 'ma', 'mi', 'ju', 'vi', 'sá', 'do'],
  ['mo', 'tu', 'we', 'th', 'fr', 'sa', 'su'],
  ['lu', 'ma', 'me', 'je', 've', 'sa', 'di'],
];

const _shortMonths = [
  ['gen', 'febr', 'març', 'abr', 'maig', 'juny', 'jul', 'ag', 'set', 'oct', 'nov', 'des'],
  ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'],
  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  ['janv', 'févr', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 'sept', 'oct', 'nov', 'déc'],
];

class CangurChatScreen extends StatefulWidget {
  const CangurChatScreen({this.openTeam = false, super.key});

  final bool openTeam;

  @override
  State<CangurChatScreen> createState() => _CangurChatScreenState();
}

class _CangurChatScreenState extends State<CangurChatScreen> {
  final _input = TextEditingController();
  StreamSubscription<List<ChatMessage>>? _messagesSub;
  List<ChatMessage>? _remote;
  Booking? _thread;
  var _team = false;
  var _sending = false;
  String _chatId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of(context).refreshChatPreviews();
      if (widget.openTeam) _openTeam();
    });
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _input.dispose();
    super.dispose();
  }

  Booking _teamBooking(String uid) {
    return Booking(
      id: 'equip-$uid',
      padreId: 'moncangur',
      padreNombre: 'Mon Cangur',
      tipoServicio: 'ocasional',
      fecha: DateTime.now(),
      horaInicio: '',
      horaFin: '',
      numeroNinos: 0,
      direccionServicio: '',
      canguroId: uid,
    );
  }

  Future<void> _open(Booking booking, {required bool team}) async {
    final state = AppScope.of(context);
    _messagesSub?.cancel();
    _input.clear();
    setState(() {
      _thread = booking;
      _team = team;
      _remote = null;
      _chatId = booking.id;
    });
    final id = await state.openChat(booking);
    if (!mounted || _thread?.id != booking.id) return;
    setState(() => _chatId = id);
    _messagesSub = state.watchMessages(id)?.listen((messages) {
      if (mounted && _thread?.id == booking.id) setState(() => _remote = messages);
    }, onError: (_) {});
  }

  void _openTeam() {
    final uid = AppScope.of(context).user?.id ?? '';
    _open(_teamBooking(uid), team: true);
  }

  void _closeThread() {
    _messagesSub?.cancel();
    setState(() {
      _thread = null;
      _team = false;
      _remote = null;
    });
  }

  Future<void> _send() async {
    final booking = _thread;
    final text = _input.text.trim();
    if (booking == null || text.isEmpty || _sending) return;
    final state = AppScope.of(context);
    setState(() => _sending = true);
    final error = await state.sendChatMessage(chatId: _chatId, reservaId: booking.id, texto: text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (error != null) {
      state.flash(state.tr(error));
      return;
    }
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lang = state.lang;
    final colors = _Look.of(context);
    final thread = _thread;
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
                _header(colors, lang),
                if (thread == null) ...[
                  Expanded(child: _inbox(colors, lang, state)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: colors.mentaD),
                        const SizedBox(width: 9),
                        Expanded(child: Text(cx(lang, 'inboxNote'), style: TextStyle(fontFamily: 'Nunito', fontSize: 12.5, height: 1.5, color: colors.text2))),
                      ],
                    ),
                  ),
                ] else
                  Expanded(child: _conversation(colors, lang, state, thread)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(_Look colors, AppLang lang) {
    final thread = _thread;
    final title = thread == null ? cx(lang, 'xat') : (_team ? cx(lang, 'team') : _familyName(thread));
    final status = thread == null ? '' : (_team ? cx(lang, 'teamStatus') : _status(lang, thread));
    final initial = _team ? '🦘' : (title.isEmpty ? '?' : title[0].toUpperCase());
    final color = _team ? 0xFF8CA598 : _colorOf(title);
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
                onTap: thread == null ? () => Navigator.pop(context) : _closeThread,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: colors.ink)),
              ),
            ),
            const SizedBox(width: 12),
            if (thread != null) ...[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Color(color), borderRadius: BorderRadius.circular(13)),
                child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, height: 1.1, color: colors.ink))),
                      if (_team) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: colors.menta, borderRadius: BorderRadius.circular(999)),
                          child: Text(cx(lang, 'equip').toUpperCase(), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.3, color: Color(0xFF2C3A33))),
                        ),
                      ],
                    ],
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(width: 7, height: 7, decoration: BoxDecoration(color: colors.ok, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Expanded(child: Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: colors.text2))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inbox(_Look colors, AppLang lang, dynamic state) {
    final families = [
      for (final booking in state.bookingsForCurrent())
        if (booking.canguroId != null && booking.canguroId!.isNotEmpty && booking.estado != 'denegada' && booking.estado != 'presupuesto') booking,
    ]..sort((a, b) {
        final left = state.chatPreviews[a.id]?.ultimoMensajeFecha ?? a.fecha;
        final right = state.chatPreviews[b.id]?.ultimoMensajeFecha ?? b.fecha;
        return right.compareTo(left);
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 2),
          child: Text(cx(lang, 'conversations').toUpperCase(), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.6, color: colors.mentaD)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            children: [
              for (var i = 0; i < families.length; i++) ...[
                if (i > 0) Divider(height: 1, color: colors.line),
                _row(colors, lang, state, families[i], team: false),
              ],
              if (families.isNotEmpty) Divider(height: 1, color: colors.line),
              _row(colors, lang, state, _teamBooking(state.user?.id ?? ''), team: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(_Look colors, AppLang lang, dynamic state, Booking booking, {required bool team}) {
    final preview = state.chatPreviews[booking.id];
    final name = team ? cx(lang, 'team') : _familyName(booking);
    final last = (preview?.ultimoMensaje ?? '').trim();
    final when = preview?.ultimoMensajeFecha;
    final messages = state.messagesFor(booking.id);
    final mine = state.user?.id ?? '';
    final unread = messages.where((message) => message.remitenteId != mine && !message.vistoPor.contains(mine)).length;
    final color = team ? 0xFF8CA598 : _colorOf(name);
    return InkWell(
      onTap: () => team ? _openTeam() : _open(booking, team: false),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Color(color), borderRadius: BorderRadius.circular(15)),
              child: Text(team ? '🦘' : name[0].toUpperCase(), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: colors.ink))),
                      if (team) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: colors.menta, borderRadius: BorderRadius.circular(999)),
                          child: Text(cx(lang, 'equip').toUpperCase(), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.3, color: Color(0xFF2C3A33))),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(last.isEmpty ? cx(lang, 'start') : last, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: colors.text2)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (when != null) Text(_clock(when), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, color: colors.text2)),
                if (unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: colors.mentaD, borderRadius: BorderRadius.circular(999)),
                    child: Text('$unread', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11.5, color: Colors.white)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _conversation(_Look colors, AppLang lang, dynamic state, Booking booking) {
    final messages = _remote ?? state.messagesFor(booking.id);
    final mine = state.user?.id ?? '';
    final priv = cx(lang, _team ? 'privTeam' : 'privCarer');
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
                decoration: BoxDecoration(color: colors.menta15, borderRadius: BorderRadius.circular(13)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline, size: 15, color: colors.mentaD),
                    const SizedBox(width: 9),
                    Expanded(child: Text.rich(_marked(priv, TextStyle(fontFamily: 'Nunito', fontSize: 12, height: 1.5, color: colors.text), TextStyle(fontFamily: 'Nunito', fontSize: 12, height: 1.5, fontWeight: FontWeight.w800, color: colors.ink)))),
                  ],
                ),
              ),
              ..._bubbles(colors, lang, messages, mine),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(color: colors.bg, border: Border(top: BorderSide(color: colors.line))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('cangur-chat-input'),
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 15, color: colors.ink),
                    decoration: InputDecoration(
                      hintText: cx(lang, 'placeholder'),
                      hintStyle: TextStyle(fontFamily: 'Nunito', color: colors.text2),
                      filled: true,
                      fillColor: colors.card,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: colors.line, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: colors.line, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: colors.menta, width: 1.5)),
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
        ),
      ],
    );
  }

  List<Widget> _bubbles(_Look colors, AppLang lang, List<ChatMessage> messages, String mine) {
    final items = <Widget>[];
    String? day;
    final today = DateTime.now();
    for (final message in messages) {
      final key = '${message.fecha.year}-${message.fecha.month}-${message.fecha.day}';
      if (key != day) {
        day = key;
        final sameDay = message.fecha.year == today.year && message.fecha.month == today.month && message.fecha.day == today.day;
        final label = sameDay ? cx(lang, 'today') : '${_shortDays[lang.index][message.fecha.weekday - 1]} ${message.fecha.day} ${_shortMonths[lang.index][message.fecha.month - 1]}';
        items.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11.5, color: colors.text2)),
        ));
      }
      items.add(_bubble(colors, message, message.remitenteId == mine));
    }
    return items;
  }

  Widget _bubble(_Look colors, ChatMessage message, bool outgoing) {
    final time = '${message.fecha.hour.toString().padLeft(2, '0')}:${message.fecha.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: outgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 3),
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
            Text(message.texto, style: TextStyle(fontFamily: 'Nunito', fontSize: 14.5, height: 1.45, color: outgoing ? Colors.white : colors.ink)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontFamily: 'Nunito', fontSize: 10.5, color: outgoing ? const Color(0x99FFFFFF) : colors.text2)),
          ],
        ),
      ),
    );
  }
}

String _familyName(Booking booking) {
  final name = booking.padreNombre.trim();
  return name.isEmpty ? 'Família' : name;
}

String _status(AppLang lang, Booking booking) {
  final day = _shortDays[lang.index][booking.fecha.weekday - 1];
  final month = _shortMonths[lang.index][booking.fecha.month - 1];
  final when = '$day ${booking.fecha.day} $month';
  final place = booking.direccionServicio.trim();
  final line = cx(lang, 'reservaStatus').replaceAll('{when}', when);
  return place.isEmpty ? line : '$line · $place';
}

String _clock(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

int _colorOf(String name) {
  if (name.isEmpty) return _palette[0];
  return _palette[name.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % _palette.length];
}

TextSpan _marked(String source, TextStyle base, TextStyle bold) {
  final parts = source.split('**');
  return TextSpan(children: [for (var i = 0; i < parts.length; i++) TextSpan(text: parts[i], style: i.isOdd ? bold : base)]);
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
    ok: Color(0xFF6F9E86),
  );

  static _Look of(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
  }
}
