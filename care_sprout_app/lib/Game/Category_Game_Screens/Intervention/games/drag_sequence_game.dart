part of '../mini_game.dart';

class DragSequenceGame extends MiniGame {
  final Map<String, String?> stepImages; // step text -> asset path
  const DragSequenceGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.stepImages,
    super.backgroundAsset,
    super.useImages = true,
  });

  @override
  State<DragSequenceGame> createState() => _DragSequenceGameState();
}

class _DragSequenceGameState extends State<DragSequenceGame> {
  late final List<String> targetOrder;
  final List<String?> placed = [];
  final List<String> pool = [];
  final Set<int> _wrong = {};
  int get stepsCount => max(widget.diff.minSteps, min(widget.diff.maxSteps, 5));

  @override
  void initState() {
    super.initState();

    final keys = widget.stepImages.keys.toList();
    targetOrder = keys.take(stepsCount).toList();
    placed.addAll(List.filled(targetOrder.length, null));

    pool.addAll(targetOrder);
    if (widget.diff.distractions > 0) {
      final decoys =
          (widget.stepImages.keys.toList()..removeWhere(pool.contains))
            ..shuffle();
      pool.addAll(decoys.take(widget.diff.distractions * 2));
    }
    pool.shuffle();
  }

  bool get completed =>
      List.generate(targetOrder.length, (i) => placed[i] == targetOrder[i])
          .every((v) => v);

  @override
  Widget build(BuildContext context) {
    final showHints = widget.diff.hintsVisible;

    final isSmall = MediaQuery.of(context).size.width < 900;
    final targetW = isSmall ? 130.0 : 160.0;
    final targetH = isSmall ? 100.0 : 120.0;
    final poolW = isSmall ? 120.0 : 150.0;
    final poolH = isSmall ? 90.0 : 110.0;

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: Column(
        children: [
          const Text('Put the steps in order', style: _h1),
          const SizedBox(height: 8),
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
                    : (isCorrect ? const Color(0xFF7BC67B) : Colors.white70);

                return DragTarget<String>(
                  onWillAccept: (_) => placed[i] == null,
                  onAccept: (val) {
                    if (val == targetOrder[i]) {
                      setState(() => placed[i] = val);
                      if (completed) {
                        Future.delayed(
                            const Duration(milliseconds: 250), widget.onDone);
                      }
                    } else {
                      setState(() => _wrong.add(i));
                      Future.delayed(const Duration(milliseconds: 300), () {
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
                            : null,
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
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) {
                final itemW = poolW;
                final itemH = poolH;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: pool.map((s) {
                    final used = placed.contains(s);
                    return SizedBox(
                      width: itemW,
                      height: itemH,
                      child: _DraggableImage(
                        id: s,
                        asset: widget.stepImages[s],
                        enabled: !used,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
