import 'package:flutter/widgets.dart';

import 'novakit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'SuperNova',
      color: NovaTheme.background,
      home: const HomeScreen(),
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _tab = 0;
  bool _drawerOpen = false;
  bool _saving = false;
  bool _flightScene = false;
  bool _switchOn = true;
  bool _checked = false;
  int _channel = 0;
  double _volume = 0.4;
  final Set<String> _tags = {'код'};
  String _status = 'в сети';
  final List<String> _hashTags = ['феникс', 'огонь'];
  String _fireTheme = 'пламя';
  final List<NovaChatData> _chats = novaSampleChats();

  void _save() {
    setState(() => _saving = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saving = false);
    });
  }

  List<NovaNavigationItem> get _navItems => [
        NovaNavigationItem(
          icon: (c) => NovaIconFlame(color: c),
          label: 'профиль',
        ),
        NovaNavigationItem(
          icon: (c) => NovaIconChat(color: c),
          label: 'ЧАТЫ',
        ),
        NovaNavigationItem(
          icon: (c) => NovaIconGear(color: c),
          label: 'НАСТР.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Positioned.fill(
            child: _flightScene ? const PhoenixFlight() : const PhoenixEmbers(),
          ),
          Column(
            children: [
              NovaAppBar(
                leading: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _drawerOpen = true),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: NovaIconMenu(color: NovaTheme.paper),
                    ),
                  ),
                ),
                title: const Text('SUPERNOVA'),
                actions: [
                  NovaPopupMenuButton(
                    items: [
                      NovaMenuItem(
                        label: 'ПРОФИЛЬ',
                        onSelected: () => NovaSnackBar.show(context, 'ПРОФИЛЬ ОТКРЫТ'),
                      ),
                      NovaMenuItem(
                        label: 'АРХИВ',
                        onSelected: () => NovaSnackBar.show(context, 'АРХИВ ПЫЛАЕТ'),
                      ),
                      NovaMenuItem(
                        label: 'СЖЕЧЬ ВСЁ',
                        onSelected: () => NovaAlertDialog.show(
                          context,
                          title: 'СЖЕЧЬ ВСЁ?',
                          message:
                              'Все макеты будут преданы огню. Феникс восстанет',
                          confirmLabel: 'СЖЕЧЬ',
                          onConfirm: () => NovaSnackBar.show(context, 'ВСЁ СОЖЖЕНО'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  NovaChip(
                    label: Text(_status),
                    selected: true,
                    selectedColor: NovaTheme.gold,
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    NovaNavigationRail(
                      items: _navItems,
                      index: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                    Expanded(
                      child: _tab == 0
                          ? _buildShowcase()
                          : _tab == 1
                              ? _buildChats()
                              : _buildSettings(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: NovaFloatingActionButton(
              onPressed: () {
                late final OverlayEntry entry;
                entry = NovaBottomSheet.show(
                  context,
                  builder: (ctx) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'НОВЫЙ ЧАТ',
                        style: TextStyle(
                          fontFamily: NovaTheme.displayFont,
                          fontVariations: [FontVariation.weight(700)],
                          fontSize: 16,
                          letterSpacing: 3,
                          color: NovaTheme.paper,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const NovaTextField(label: 'имя чата'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          NovaButton(
                            size: ButtonSize.medium,
                            onPressed: () {
                              entry.remove();
                              NovaSnackBar.show(context, 'ЧАТ СОЗДАН');
                            },
                            child: const Text('СОЗДАТЬ'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              child: const NovaIconChat(color: NovaTheme.ink),
            ),
          ),
          NovaDrawer(
            open: _drawerOpen,
            onClose: () => setState(() => _drawerOpen = false),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'МЕНЮ',
                  style: TextStyle(
                    fontFamily: NovaTheme.displayFont,
                    fontVariations: [FontVariation.weight(700)],
                    fontSize: 18,
                    letterSpacing: 4,
                    color: NovaTheme.paper,
                  ),
                ),
                const SizedBox(height: 12),
                const NovaDivider(),
                NovaListTile(
                  leading: const NovaIconUser(color: NovaTheme.flame),
                  title: const Text('Профиль'),
                  subtitle: const Text('эмир@supernova'),
                  onTap: () => setState(() => _drawerOpen = false),
                ),
                NovaListTile(
                  leading: const NovaIconFlame(color: NovaTheme.gold),
                  title: const Text('Избранное'),
                  onTap: () => setState(() => _drawerOpen = false),
                ),
                NovaListTile(
                  leading: const NovaIconChat(color: NovaTheme.muted),
                  title: const Text('Архив'),
                  onTap: () => setState(() => _drawerOpen = false),
                ),
                const Spacer(),
                const NovaBarcode(height: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Super',
                  style: TextStyle(
                    fontFamily: NovaTheme.displayFont,
                    fontVariations: [FontVariation.weight(800)],
                    fontSize: 40,
                    color: NovaTheme.paper,
                  ),
                ),
                TextSpan(
                  text: 'Nova',
                  style: TextStyle(
                    fontFamily: NovaTheme.displayFont,
                    fontVariations: [FontVariation.weight(800)],
                    fontSize: 40,
                    color: NovaTheme.flame,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Stripes(),
          const SizedBox(height: 32),
          Transform.rotate(
            angle: -0.01,
            child: NovaCard(
              width: 340,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NovaTextFormField(
                      label: 'Имя',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Как тебя зовут?' : null,
                    ),
                    const SizedBox(height: 16),
                    const NovaTextField(
                      label: 'Пароль',
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    NovaButton(
                      size: ButtonSize.medium,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _formKey.currentState!.validate();
                      },
                      child: const Text('ВОЙТИ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NovaButton(
                onPressed: _save,
                isLoading: _saving,
                child: const Text('СОХРАНИТЬ ИЗМЕНЕНИЯ'),
              ),
              const SizedBox(width: 24),
              NovaButton(
                variant: ButtonVariant.secondary,
                size: ButtonSize.medium,
                onPressed: () {},
                child: const Text('ПРОДОЛЖИТЬ'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NovaButton(
                  variant: ButtonVariant.danger,
                  type: ButtonType.outlined,
                  size: ButtonSize.medium,
                  onPressed: () {},
                  child: const Text('УДАЛИТЬ'),
                ),
                const SizedBox(width: 24),
                NovaButton(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.small,
                  onPressed: () {},
                  child: const Text('ОТМЕНА'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                child: const NovaLinearProgress(value: 0.65),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 220,
                child: const NovaLinearProgress(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NovaCircularProgress(value: 0.65),
              const SizedBox(width: 24),
              const NovaCircularProgress(),
              const SizedBox(width: 32),
              NovaButton(
                variant: ButtonVariant.secondary,
                size: ButtonSize.medium,
                onPressed: () => NovaSnackBar.show(context, 'ЗДЕСЬ МОГЛА БЫ БЫТЬ ВАША РЕКЛАМА'),
                child: const Text('УВЕДОМЛЕНИЕ'),
              ),
              const SizedBox(width: 24),
              NovaTooltip(
                message: 'кнопка-призрак',
                child: NovaButton(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.small,
                  onPressed: () {},
                  child: const Text('НАВЕДИ'),
                ),
              ),
              const SizedBox(width: 24),
              NovaButton(
                variant: ButtonVariant.danger,
                size: ButtonSize.medium,
                onPressed: () {
                  late final OverlayEntry entry;
                  entry = NovaDialog.show(
                    context,
                    title: const Text('ВОССТАНИЕ'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Подтвердить запуск?',
                          style: TextStyle(
                            fontFamily: NovaTheme.bodyFont,
                            fontVariations: [FontVariation.weight(600)],
                            fontSize: 14,
                            color: NovaTheme.muted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const NovaLinearProgress(),
                      ],
                    ),
                    actions: [
                      NovaButton(
                        variant: ButtonVariant.ghost,
                        size: ButtonSize.small,
                        onPressed: () => entry.remove(),
                        child: const Text('ПОЗЖЕ'),
                      ),
                      NovaButton(
                        size: ButtonSize.small,
                        onPressed: () {
                          entry.remove();
                          NovaSnackBar.show(context, 'ВСЕ РАБОТАЕТ');
                        },
                        child: const Text('ПОДТВЕРДИТЬ'),
                      ),
                    ],
                  );
                },
                child: const Text('ДИАЛОГ'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final tag in ['дизайн', 'код', 'мемы'])
                NovaFilterChip(
                  label: tag,
                  selected: _tags.contains(tag),
                  onChanged: (v) => setState(() {
                    if (v) {
                      _tags.add(tag);
                    } else {
                      _tags.remove(tag);
                    }
                  }),
                ),
              for (final s in ['в сети', 'отошёл', 'не беспокоить'])
                NovaChoiceChip(
                  label: s,
                  selected: _status == s,
                  onSelected: (_) => setState(() => _status = s),
                ),
              for (final h in _hashTags)
                NovaChip(
                  label: Text('#$h'),
                  onDeleted: () => setState(() => _hashTags.remove(h)),
                ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildChats() {
    final totalUnread = _chats.fold<int>(0, (s, c) => s + c.unread);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Transform.rotate(
        angle: 0.012,
        child: NovaCard(
          width: 420,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  children: [
                    Text(
                      'ЧАТЫ',
                      style: TextStyle(
                        fontFamily: NovaTheme.displayFont,
                        fontVariations: [FontVariation.weight(700)],
                        fontSize: 16,
                        color: NovaTheme.paper,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _Stripes(width: 90, height: 10),
                    const Spacer(),
                    NovaChip(
                      label: Text('$totalUnread НОВЫХ'),
                      selected: true,
                      selectedColor: NovaTheme.gold,
                    ),
                  ],
                ),
              ),
              const NovaDivider(indent: 4, endIndent: 4),
              for (final chat in _chats)
                NovaChatTile(
                  initials: chat.initials,
                  avatarColor: chat.avatarColor,
                  name: chat.name,
                  message: chat.messages.isEmpty
                      ? 'нет сообщений'
                      : chat.messages.last.text,
                  time: chat.messages.isEmpty ? '--:--' : chat.messages.last.time,
                  unread: chat.unread,
                  online: chat.online,
                  onTap: () {
                    setState(() => chat.unread = 0);
    NovaRouter.push(context, NovaChatScreen(chat: chat));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'НАСТРОЙКИ',
            style: TextStyle(
              fontFamily: NovaTheme.displayFont,
              fontVariations: [FontVariation.weight(700)],
              fontSize: 24,
              color: NovaTheme.paper,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NovaSwitch(
                value: _switchOn,
                onChanged: (v) => setState(() => _switchOn = v),
              ),
              const SizedBox(width: 16),
              Text(
                'уведомления',
                style: TextStyle(
                  fontFamily: NovaTheme.bodyFont,
                  fontVariations: [FontVariation.weight(600)],
                  color: NovaTheme.paper,
                ),
              ),
              const SizedBox(width: 40),
              NovaCheckbox(
                value: _checked,
                onChanged: (v) => setState(() => _checked = v),
              ),
              const SizedBox(width: 16),
              Text(
                'автозапуск',
                style: TextStyle(
                  fontFamily: NovaTheme.bodyFont,
                  fontVariations: [FontVariation.weight(600)],
                  color: NovaTheme.paper,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NovaRadio<int>(
                value: 0,
                groupValue: _channel,
                onChanged: (v) => setState(() => _channel = v!),
              ),
              const SizedBox(width: 12),
              NovaRadio<int>(
                value: 1,
                groupValue: _channel,
                onChanged: (v) => setState(() => _channel = v!),
              ),
              const SizedBox(width: 16),
              Text(
                'канал уведомлений',
                style: TextStyle(
                  fontFamily: NovaTheme.bodyFont,
                  fontVariations: [FontVariation.weight(600)],
                  color: NovaTheme.paper,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 300,
            child: NovaSlider(
              value: _volume,
              onChanged: (v) => setState(() => _volume = v),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'громкость',
            style: TextStyle(
              fontFamily: NovaTheme.bodyFont,
              fontVariations: [FontVariation.weight(600)],
              color: NovaTheme.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NovaDropdownButton(
                value: _fireTheme,
                items: const ['ТЕМА1', 'ТЕМА2', 'ТЕМА3'],
                onChanged: (v) {
                  setState(() => _fireTheme = v);
                  NovaSnackBar.show(context, 'ТЕМА: ${v.toUpperCase()}');
                },
              ),
              const SizedBox(width: 16),
              Text(
                'тема огня',
                style: TextStyle(
                  fontFamily: NovaTheme.bodyFont,
                  fontVariations: [FontVariation.weight(600)],
                  color: NovaTheme.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          NovaButton(
            variant: ButtonVariant.ghost,
            size: ButtonSize.small,
            onPressed: () => setState(() => _flightScene = !_flightScene),
            child: Text(_flightScene ? 'ВЫБРАТЬ: УГОЛЬКИ' : 'ВЫБРАТЬ: ФЕНИКС'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Stripes extends StatelessWidget {
  const _Stripes({this.width = 260, this.height = 12});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _StripesPainter()),
    );
  }
}

class _StripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    for (var x = -size.height; x < size.width; x += 14) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height * 0.6, 0)
        ..lineTo(x + size.height * 0.6 + 7, 0)
        ..lineTo(x + 7, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = i.isEven ? NovaTheme.flame : NovaTheme.gold,
      );
      i++;
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) => false;
}