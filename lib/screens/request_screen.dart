import 'package:flutter/material.dart';

import '../l10n/app_copy.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/mc_widgets.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({required this.service, super.key});

  final ServiceOffer service;

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _address = TextEditingController();
  final _period = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  String _start = '17:00';
  String _end = '21:00';
  String _eventType = eventTypeKeys.first;
  final Set<String> _ages = {};
  int _children = 8;
  String? _done;
  String? _error;

  bool get _isEvent => widget.service.tipoServicio == 'eventos';

  @override
  void dispose() {
    _address.dispose();
    _period.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = AppScope.of(context);
    if (_address.text.trim().isEmpty) {
      setState(() => _error = state.tr('address'));
      return;
    }
    final lang = state.lang;
    final buffer = StringBuffer()
      ..writeln(serviceName(lang, widget.service.tipoServicio))
      ..writeln('${state.tr('date')}: ${formatDate(_date)} $_start–$_end')
      ..writeln('${state.tr('children')}: $_children')
      ..writeln('${state.tr('address')}: ${_address.text.trim()}');
    if (_isEvent) {
      buffer
        ..writeln('${state.tr('eventType')}: ${eventTypeName(lang, _eventType)}')
        ..writeln('${state.tr('childrenInfo')}: ${_ages.map((k) => ageBandName(lang, k)).join(', ')}');
    } else if (_period.text.trim().isNotEmpty) {
      buffer.writeln('${state.tr('period')}: ${_period.text.trim()}');
    }
    if (_notes.text.trim().isNotEmpty) buffer.writeln(_notes.text.trim());
    final quote = state.submitQuote(tipo: widget.service.tipoServicio, resumen: buffer.toString());
    if (quote == null) return;
    setState(() {
      _error = null;
      _done = _isEvent ? state.tr('eventSuccess') : state.tr('fixedSuccess');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageWidth(
          maxWidth: 720,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(state.tr('back')),
              ),
              Text(
                _isEvent ? state.tr('eventTitle') : state.tr('fixedTitle'),
                style: const TextStyle(fontFamily: 'CyGroteskKey', fontSize: 30),
              ),
              const SizedBox(height: 8),
              Text(
                _isEvent ? state.tr('eventIntro') : state.tr('fixedIntro'),
                style: const TextStyle(height: 1.4, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(state.tr('afterSubmit'), style: const TextStyle(height: 1.4)),
              const SizedBox(height: 14),
              if (_done != null)
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 36),
                      const SizedBox(height: 8),
                      Text(_done!, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4)),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () => Navigator.pop(context), child: Text(state.tr('close'))),
                    ],
                  ),
                )
              else
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isEvent) ...[
                        Text(state.tr('eventType'), style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final key in eventTypeKeys)
                              ChoiceChip(
                                label: Text(eventTypeName(state.lang, key)),
                                selected: _eventType == key,
                                onSelected: (_) => setState(() => _eventType = key),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(state.tr('ageHint')),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final key in ageBandKeys)
                              FilterChip(
                                label: Text(ageBandName(state.lang, key)),
                                selected: _ages.contains(key),
                                onSelected: (v) => setState(() {
                                  if (v) {
                                    _ages.add(key);
                                  } else {
                                    _ages.remove(key);
                                  }
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        TextField(controller: _period, decoration: InputDecoration(labelText: state.tr('period'))),
                        const SizedBox(height: 8),
                        Text(state.tr('bandsHint'), style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                      ],
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 540)),
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                        child: Text('${_isEvent ? state.tr('eventWhen') : state.tr('date')}: ${formatDate(_date)}'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _time(state.tr('start'), _start, (v) => setState(() => _start = v))),
                          const SizedBox(width: 8),
                          Expanded(child: _time(state.tr('end'), _end, (v) => setState(() => _end = v))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${state.tr('children')}: $_children'),
                      Slider(
                        value: _children.toDouble(),
                        min: 1,
                        max: 25,
                        divisions: 24,
                        label: '$_children',
                        onChanged: (v) => setState(() => _children = v.round()),
                      ),
                      Text(state.tr(caregiverNeed(widget.service, _children))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _address,
                        decoration: InputDecoration(
                          labelText: _isEvent ? state.tr('eventLocation') : state.tr('address'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notes,
                        maxLines: 3,
                        decoration: InputDecoration(labelText: state.tr('comment')),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                      ],
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _submit, child: Text(state.tr('send'))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String caregiverNeed(ServiceOffer service, int children) {
    return AppScope.of(context).tr(
      children <= 2
          ? 'oneCaregiver'
          : children <= 4
              ? 'maybeMore'
              : children <= 12
                  ? 'mediumGroup'
                  : 'largeGroup',
    );
  }

  Widget _time(String label, String value, ValueChanged<String> onPick) {
    return OutlinedButton(
      onPressed: () async {
        final next = await pickTime(context, value);
        if (next != null) onPick(next);
      },
      child: Text('$label $value'),
    );
  }
}
