part of '../mini_game.dart';

class HandWashingGame extends MiniGame {
  final Map<String, String?> stepImages;
  const HandWashingGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.stepImages,
    super.backgroundAsset,
  });

  @override
  State<StatefulWidget> createState() => _HandWashingGameState();
}

class _HandWashingGameState extends State<HandWashingGame> {
  late final List<String> targetOrder;
  late final List<String?> placed; // slots
  final Set<int> _wrong = {}; // flash red on wrong drop

  bool get _complete =>
      List.generate(targetOrder.length, (i) => placed[i] == targetOrder[i])
          .every((v) => v);

  @override
  void initState() {
    super.initState();
    targetOrder = widget.stepImages.keys.toList();
    final count = min(widget.diff.maxSteps + 1, targetOrder.length);
    if (targetOrder.length > count) {
      targetOrder.removeRange(count, targetOrder.length);
    }
    placed = List<String?>.filled(targetOrder.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final showHints = widget.diff.hintsVisible;

    final isSmall = MediaQuery.of(context).size.width < 900;
    final slotW = isSmall ? 130.0 : 160.0;
    final slotH = isSmall ? 100.0 : 120.0;
    final poolW = isSmall ? 120.0 : 150.0;
    final poolH = isSmall ? 90.0 : 110.0;

    // Pool: just the needed steps, shuffled (add decoys here if you want)
    final pool = List<String>.from(targetOrder)..shuffle();

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Arrange the handwashing steps in order', style: _h1),
          const SizedBox(height: 8),
          SizedBox(
            height: slotH + 10,
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
                  onWillAccept: (_) => placed[i] == null, // only empty slot
                  onAccept: (val) {
                    if (val == targetOrder[i]) {
                      setState(() => placed[i] = val);
                      if (_complete) {
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
                      width: slotW,
                      height: slotH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: _ImageTile(
                        asset: placedId != null
                            ? widget.stepImages[placedId]
                            : null,
                        width: slotW,
                        height: slotH,
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
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: pool.map((s) {
                final used = placed.contains(s);
                return SizedBox(
                  width: poolW,
                  height: poolH,
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
    );
  }
}
