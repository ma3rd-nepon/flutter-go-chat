import 'package:flutter/widgets.dart';

import '../fab/nova_floating_action_button.dart';
import '../icons/nova_icons.dart';
import '../menu/nova_popup_menu.dart';
import '../models/chat_models.dart';
import '../router/nova_router.dart';
import '../snackbar/nova_snack_bar.dart';
import '../text_field/nova_text_field.dart';
import '../../core/novacore.dart';
import '../embers/phoenix_embers.dart';
import 'nova_message_bubble.dart';
import 'nova_typing_indicator.dart';

class NovaChatScreen extends StatefulWidget {
  const NovaChatScreen({super.key, required this.chat});

  final NovaChatData chat;

  @override
  State<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends State<NovaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _typing = false;
  int _replyIndex = 0;

  static const List<String> _replies = [
    'принято',
    'огонь-огонь',
    'восстанем и сделаем',
    'скинь макет',
    'палитра согласен',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _now() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      widget.chat.messages.add(NovaMessage(text: text, me: true, time: _now()));
      _typing = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        widget.chat.messages.add(
          NovaMessage(
            text: _replies[_replyIndex % _replies.length],
            me: false,
            time: _now(),
          ),
        );
        _replyIndex++;
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        const Positioned.fill(child: PhoenixEmbers()),
        Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  bottom: BorderSide(color: colors.border, width: 2),
                ),
              ),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => NovaRouter.pop(context),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: NovaIconBack(color: colors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.chat.avatarColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.border, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            widget.chat.initials,
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontVariations: [FontVariation.weight(800)],
                              fontSize: 14,
                              color: colors.border,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: widget.chat.online ? colors.primary : colors.textDisabled,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.chat.name,
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontVariations: [FontVariation.weight(800)],
                            fontSize: 15,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.chat.online ? 'в сети' : 'не в сети',
                          style: TextStyle(
                            fontFamily: AppFonts.monoFont,
                            fontSize: 10,
                            color: widget.chat.online ? colors.primary : colors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                  NovaPopupMenuButton(
                    items: [
                      NovaMenuItem(
                        label: 'ОЧИСТИТЬ',
                        onSelected: () => setState(() => widget.chat.messages.clear()),
                      ),
                      NovaMenuItem(
                        label: 'В АРХИВ',
                        onSelected: () => NovaSnackBar.show(context, 'ЧАТ В АРХИВЕ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(24),
                children: [
                  for (final m in widget.chat.messages) ...[
                    NovaMessageBubble(message: m),
                    const SizedBox(height: 12),
                  ],
                  if (_typing) const NovaTypingIndicator(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(color: colors.border, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: NovaTextField(
                      controller: _controller,
                      label: 'сообщение',
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  NovaFloatingActionButton(
                    onPressed: _send,
                    child: NovaIconSend(color: colors.border),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}