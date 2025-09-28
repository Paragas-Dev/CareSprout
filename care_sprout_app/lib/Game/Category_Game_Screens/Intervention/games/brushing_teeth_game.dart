part of '../mini_game.dart';

class BrushingTeethGame extends MiniGame {
  final Map<String, String?> stepImages;
  final List<String?> mouthImages;
  final String? stainImage;

  const BrushingTeethGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.stepImages,
    required this.mouthImages,
    required this.stainImage,
    super.backgroundAsset,
  });

  @override
  State<BrushingTeethGame> createState() => _BrushingTeethGameState();
}

class _BrushingTeethGameState extends State<BrushingTeethGame> {
  // Sequence (right side)
  late final List<String> targetOrder;
  late final List<String?> placed;
  final Set<int> _wrong = {};
  bool get _sequenceComplete =>
      List.generate(targetOrder.length, (i) => placed[i] == targetOrder[i])
          .every((v) => v);

  // Stain cleaning (left side)
  late final String? _mouthAsset;
  late final int _stainCount;
  late final List<Offset> _stains;

  int get _gateCount => min(3, targetOrder.length);
  bool get _canBrush =>
      List.generate(_gateCount, (i) => placed[i] == targetOrder[i])
          .every((v) => v);

  bool get _stainsCleared => _stains.isEmpty;

  bool get _wetDone =>
      placed.isNotEmpty && placed[0] != null && placed[0] == targetOrder[0];

  String? get _brushAsset => widget.stepImages['Brush Teeth'];

  @override
  void initState() {
    super.initState();

    // sequence order as provided in the map literal
    targetOrder = widget.stepImages.keys.toList();
    final maxSteps = min(widget.diff.maxSteps + 1, targetOrder.length);
    if (targetOrder.length > maxSteps) {
      targetOrder.removeRange(maxSteps, targetOrder.length);
    }

    placed = List<String?>.filled(targetOrder.length, null);

    // pick a random mouth and 2–3 stains
    final r = Random();
    _mouthAsset = widget.mouthImages.isEmpty
        ? null
        : widget.mouthImages[r.nextInt(widget.mouthImages.length)];

    _stainCount = 2 + r.nextInt(2);
    _stains = List.generate(_stainCount, (_) {
      // keep stains around the center
      final dx = 0.25 + r.nextDouble() * 0.5;
      final dy = 0.25 + r.nextDouble() * 0.5;
      return Offset(dx, dy);
    });
  }

  void _checkDone() {
    if (_sequenceComplete && _stainsCleared) {
      Future.delayed(const Duration(milliseconds: 250), widget.onDone);
    }
  }

  void _wetBrush() {
    if (_wetDone || targetOrder.isEmpty) return;
    setState(() => placed[0] = targetOrder[0]);
    _checkDone();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 8);
    final showHints = widget.diff.hintsVisible;

    final isSmall = MediaQuery.of(context).size.width < 900;
    final targetW = isSmall ? 130.0 : 160.0;
    final targetH = isSmall ? 100.0 : 120.0;

    // steps pool
    final pool = List<String>.from(targetOrder)..shuffle();

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: Row(
        children: [
          // LEFT: Mouth + stains
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;
                final size = min(w, h) * (isSmall ? 0.9 : 1.0);
                final leftPad = (w - size) / 2;
                final topPad = (h - size) / 2;

                final brushW = isSmall ? 88.0 : 100.0;
                final brushH = brushW * 0.66;

                return Stack(
                  children: [
                    // mouth image
                    Positioned(
                      left: leftPad,
                      top: topPad,
                      width: size,
                      height: size,
                      child: _ImageTile(
                        asset: _mouthAsset,
                        width: size,
                        height: size,
                        // label: null,
                      ),
                    ),
                    // stains (tap to clean only)
                    for (var i = 0; i < _stains.length; i++)
                      Positioned(
                        left: leftPad + _stains[i].dx * size - 28,
                        top: topPad + _stains[i].dy * size - 28,
                        width: 56,
                        height: 56,
                        child: IgnorePointer(
                          ignoring: !_canBrush,
                          child: GestureDetector(
                            onTap: () {
                              if (!_canBrush) return;
                              setState(() => _stains.removeAt(i));
                              _checkDone();
                            },
                            child: Opacity(
                              opacity: _canBrush ? 1.0 : 0.65,
                              child: _ImageTile(
                                asset: widget.stainImage,
                                width: 56,
                                height: 56,
                                circle: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!_canBrush)
                      Positioned(
                        left: leftPad,
                        top: topPad,
                        width: size,
                        height: size,
                        child: IgnorePointer(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Arrange first $_gateCount steps to start brushing',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Water target (drop the brush here to "Wet Brush")
                    Positioned(
                      left: leftPad + size - 84,
                      top: topPad - 8,
                      width: 72,
                      height: 72,
                      child: DragTarget<String>(
                        onWillAccept: (data) => data == 'BRUSH' && !_wetDone,
                        onAccept: (_) => _wetBrush(),
                        builder: (_, __, ___) => _WaterTarget(wet: _wetDone),
                      ),
                    ),

                    // Draggable toothbrush (uses the "Brush Teeth" PNG)
                    Positioned(
                      left: leftPad + (size - brushW) / 2,
                      top: topPad + size + 8,
                      width: brushW,
                      height: brushH,
                      child: _DraggableBrush(
                        asset: _brushAsset,
                        enabled: !_wetDone, // disable after wet
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // RIGHT: Step targets and pool
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Put the steps in order', style: _h1),
                gap,
                SizedBox(
                  height: targetH + 10,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: targetOrder.length,
                    itemBuilder: (context, i) {
                      final placedId = placed[i];
                      final isCorrect =
                          placedId != null && placedId == targetOrder[i];
                      final borderColor = _wrong.contains(i)
                          ? Colors.redAccent
                          : (isCorrect
                              ? const Color(0xFF7BC67B)
                              : Colors.white70);
                      return DragTarget<String>(
                        onWillAccept: (_) => placed[i] == null,
                        onAccept: (val) {
                          if (val == targetOrder[i]) {
                            setState(() => placed[i] = val);
                            _checkDone();
                          } else {
                            setState(() => _wrong.add(i));
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              if (mounted) setState(() => _wrong.remove(i));
                            });
                          }
                        },
                        builder: (_, __, ___) => GestureDetector(
                          onLongPress: () {
                            if (placed[i] != null) {
                              setState(() => placed[i] = null);
                            }
                          },
                          child: Container(
                            width: targetW,
                            height: targetH,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: _ImageTile(
                              asset: placedId != null
                                  ? widget.stepImages[placedId]
                                  : null, // empty slot until placed
                              width: targetW,
                              height: targetH,
                              label: showHints
                                  ? '${i + 1}. ${targetOrder[i]}'
                                  : '${i + 1}',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                gap,
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: pool.map((s) {
                      final used = placed.contains(s);
                      return SizedBox(
                        width: isSmall ? 120 : 150,
                        height: isSmall ? 90 : 110,
                        child: _DraggableImage(
                          id: s,
                          asset: widget.stepImages[s],
                          enabled: !used,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widgets for the brush/target
class _DraggableBrush extends StatelessWidget {
  final String? asset;
  final bool enabled;
  const _DraggableBrush({required this.asset, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final tile = _ImageTile(
      asset: asset,
      width: 100,
      height: 66,
      label: 'Brush',
    );
    if (!enabled) return Opacity(opacity: 0.5, child: tile);
    return Draggable<String>(
      data: 'BRUSH',
      feedback: Material(color: Colors.transparent, child: tile),
      childWhenDragging: Opacity(opacity: 0.3, child: tile),
      child: tile,
    );
  }
}

class _WaterTarget extends StatelessWidget {
  final bool wet;
  const _WaterTarget({required this.wet});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: wet
            ? const Color(0xFF4FC3F7).withOpacity(0.35)
            : const Color(0xFF4FC3F7).withOpacity(0.20),
        border: Border.all(
            color: wet ? Colors.blueAccent : Colors.white70, width: 2),
        boxShadow: [
          if (!wet)
            BoxShadow(
                color: Colors.blueAccent.withOpacity(0.25), blurRadius: 10)
        ],
      ),
      child: const Center(
        child: Icon(Icons.water_drop, color: Colors.white),
      ),
    );
  }
}
