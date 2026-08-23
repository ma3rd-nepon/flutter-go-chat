import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaMessage {
  const NovaMessage({required this.text, required this.me, required this.time});

  final String text;
  final bool me;
  final String time;
}

class NovaChatData {
  NovaChatData({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.online = false,
    this.unread = 0,
    List<NovaMessage>? messages,
  }) : messages = messages ?? [];

  final int id;
  final String name;
  final String initials;
  final Color avatarColor;
  final bool online;
  int unread;
  final List<NovaMessage> messages;
}

List<NovaChatData> novaSampleChats() {
  return [
    NovaChatData(
      id: 1,
      name: 'Данил',
      initials: 'ДП',
      avatarColor: NovaTheme.flame,
      online: true,
      unread: 2,
      messages: [
        const NovaMessage(text: 'кнопки всё ещё выглядят как гугловские', me: false, time: '11:40'),
        const NovaMessage(text: 'ща перекрашу в огонь', me: true, time: '11:41'),
        const NovaMessage(text: 'палитра должна быть родственной', me: false, time: '11:52'),
      ],
    ),
    NovaChatData(
      id: 2,
      name: 'Команда SuperNova',
      initials: 'SN',
      avatarColor: NovaTheme.gold,
      unread: 1,
      messages: [
        const NovaMessage(text: 'релиз в пятницу, всё по плану?', me: false, time: '11:47'),
      ],
    ),
    NovaChatData(
      id: 3,
      name: 'Феникс',
      initials: 'Ф',
      avatarColor: NovaTheme.ember,
      online: true,
      messages: [
        const NovaMessage(text: 'я восстал', me: false, time: '09:14'),
        const NovaMessage(text: 'добро пожаловать обратно', me: true, time: '09:15'),
      ],
    ),
  ];
}