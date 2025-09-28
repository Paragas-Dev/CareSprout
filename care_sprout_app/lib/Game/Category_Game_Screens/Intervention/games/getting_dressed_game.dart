part of '../mini_game.dart';

class GettingDressedGame extends MiniGame {
  // key -> (top body part image, bottom clothing image)
  final Map<String, ({String? top, String? bottom})> pairs;

  const GettingDressedGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.pairs,
    super.backgroundAsset,
  });

  @override
  State<GettingDressedGame> createState() =>
      _GettingDressedGameState();
}

class _GettingDressedGameState extends State<GettingDressedGame> {
  final _canvasKey = GlobalKey();
  final Map<String, GlobalKey> _topDotKeys = {};
  final Map<String, GlobalKey> _bottomDotKeys = {};

  late final List<String> _selectedKeys; // canonical order (no shuffle)
  late final List<String> _bottomKeys; // shuffled order
  final Set<String> _solved = {};

  @override
  void initState() {
    super.initState();

    final allKeys = widget.pairs.keys.toList(); // canonical order
    final take = min(widget.diff.maxSteps + 1, allKeys.length);

    // Top row: first N keys by design (no shuffle)
    _selectedKeys = allKeys.take(take).toList();

    // Bottom row: selected + decoys from the remaining pool (shuffled)
    final remaining = allKeys.skip(take).toList();
    final decoyCount = min(remaining.length, widget.diff.distractions * 2);
    final decoys = remaining.take(decoyCount).toList();
    _bottomKeys = [..._selectedKeys, ...decoys]..shuffle();

    // Build dot keys
    for (final k in _selectedKeys) {
      _topDotKeys[k] = GlobalKey();
    }
    for (final k in _bottomKeys) {
      _bottomDotKeys[k] = GlobalKey();
    }
  }

  bool get _completed => _solved.length == _selectedKeys.length;

  Offset? _dotCenter(GlobalKey key) {
    final canvasBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (canvasBox == null || box == null) return null;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: canvasBox);
    return topLeft + Offset(box.size.width / 2, box.size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 900;
    final rowH = isSmall ? 140.0 : 170.0;
    final imgH = rowH - 40; // leave space for dot
    final imgW = imgH * 1.1;
    const dotSize = 18.0;
    final hPad = isSmall ? 10.0 : 14.0;

    // Build line endpoints from current dot positions
    final lines = _selectedKeys
        .map((k) {
          final top = _dotCenter(_topDotKeys[k]!);
          final bottom = _dotCenter(_bottomDotKeys[k]!);
          final done = _solved.contains(k);
          return (k: k, top: top, bottom: bottom, done: done);
        })
        .where((e) => e.top != null && e.bottom != null)
        .toList();

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: Stack(
        key: _canvasKey,
        children: [
          Positioned.fill(child: CustomPaint(painter: _TBLinesPainter(lines))),
          Column(
            children: [
              // TOP: body parts (only selected keys)
              SizedBox(
                height: rowH,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 6),
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedKeys.length,
                  separatorBuilder: (_, __) => SizedBox(width: hPad),
                  itemBuilder: (_, i) {
                    final k = _selectedKeys[i];
                    final data = widget.pairs[k]!;
                    final solved = _solved.contains(k);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ImageTile(
                          asset: data.top,
                          width: imgW,
                          height: imgH,
                          dim: solved,
                          label: _prettyName(k),
                        ),
                        const SizedBox(height: 6),
                        _DotDraggableTB(
                          key: _topDotKeys[k],
                          dotSize: dotSize,
                          data: k,
                          enabled: !solved,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(),
              // BOTTOM: clothing (selected + decoys)
              SizedBox(
                height: rowH,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 6),
                  scrollDirection: Axis.horizontal,
                  itemCount: _bottomKeys.length,
                  separatorBuilder: (_, __) => SizedBox(width: hPad),
                  itemBuilder: (_, i) {
                    final k = _bottomKeys[i];
                    final data = widget.pairs[k]!;
                    final solved = _solved.contains(k);
                    final isPlayable = _selectedKeys.contains(k);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _DotTargetTB(
                          key: _bottomDotKeys[k],
                          dotSize: dotSize,
                          onAccept: (dragKey) {
                            if (dragKey == k) {
                              setState(() => _solved.add(k));
                              if (_completed) {
                                Future.delayed(
                                    const Duration(milliseconds: 200),
                                    widget.onDone);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 6),
                        _ImageTile(
                          asset: data.bottom,
                          width: imgW,
                          height: imgH,
                          dim: solved || !isPlayable,
                          label: _prettyName(k),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Dot widgets (top draggable / bottom target)
class _DotDraggableTB extends StatelessWidget {
  final double dotSize;
  final String data;
  final bool enabled;
  const _DotDraggableTB(
      {super.key,
      required this.dotSize,
      required this.data,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: dotSize,
      height: dotSize,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    );
    if (!enabled) return Opacity(opacity: 0.4, child: dot);
    return Draggable<String>(
      data: data,
      feedback: Material(color: Colors.transparent, child: dot),
      childWhenDragging: Opacity(opacity: 0.3, child: dot),
      child: dot,
    );
  }
}

class _DotTargetTB extends StatelessWidget {
  final double dotSize;
  final void Function(String) onAccept;
  const _DotTargetTB(
      {super.key, required this.dotSize, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAccept: onAccept,
      builder: (_, __, ___) => Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.white70, width: 2),
        ),
      ),
    );
  }
}

class _TBLinesPainter extends CustomPainter {
  final List<({String k, Offset? top, Offset? bottom, bool done})> lines;
  const _TBLinesPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paintDone = Paint()
      ..color = const Color(0xFF7BC67B)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final paintGuide = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final l in lines) {
      if (l.top == null || l.bottom == null) continue;
      canvas.drawLine(l.top!, l.bottom!, l.done ? paintDone : paintGuide);
    }
  }

  @override
  bool shouldRepaint(covariant _TBLinesPainter oldDelegate) =>
      oldDelegate.lines != lines;
}
