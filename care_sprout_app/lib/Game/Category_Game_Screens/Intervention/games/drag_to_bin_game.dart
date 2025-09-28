part of '../mini_game.dart';

class DragToBinGame extends MiniGame {
  final Map<String, String> itemToBin; // item id -> bin name
  final List<String> binNames;

  final Map<String, String?> itemImages; // item id -> image
  final Map<String, String?> binImages; // bin name -> image
  final String? decoyImage;

  const DragToBinGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.itemToBin,
    required this.binNames,
    required this.itemImages,
    required this.binImages,
    this.decoyImage,
    super.backgroundAsset,
  });

  @override
  State<DragToBinGame> createState() => _DragToBinGameState();
}

class _DragToBinGameState extends State<DragToBinGame> {
  late final Map<String, String?> placed;
  late final List<String> items;

  @override
  void initState() {
    super.initState();
    items = widget.itemToBin.keys.toList()..shuffle();
    items
      ..retainWhere((_) => true)
      ..removeRange(min(items.length, widget.diff.maxSteps + 1), items.length);
    if (widget.diff.distractions > 0 && widget.decoyImage != null) {
      for (int i = 0; i < widget.diff.distractions; i++) {
        items.add('DECOY_$i');
      }
    }
    placed = {for (final it in items) it: null};
  }

  bool get completed {
    for (final it in items) {
      final correct = widget.itemToBin[it];
      if (correct == null) continue; // decoy
      if (placed[it] != correct) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 900;
    final itemW = isSmall ? 120.0 : 150.0;
    final itemH = isSmall ? 90.0 : 110.0;
    final binW = isSmall ? 160.0 : 190.0;
    final binH = isSmall ? 120.0 : 140.0;

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items.map((it) {
                final isDecoy = it.startsWith('DECOY_');
                final img = isDecoy ? widget.decoyImage : widget.itemImages[it];
                final done = !isDecoy && placed[it] == widget.itemToBin[it];
                return SizedBox(
                  width: itemW,
                  height: itemH,
                  child: _DraggableImage(
                      id: isDecoy ? 'Decoy' : it, asset: img, enabled: !done),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            width: isSmall ? 360 : 420,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.binNames.map((bin) {
                return DragTarget<String>(
                  onAccept: (it) {
                    setState(() => placed[it] = bin);
                    if (completed) {
                      Future.delayed(
                          const Duration(milliseconds: 200), widget.onDone);
                    }
                  },
                  builder: (_, __, ___) => _ImageTile(
                    asset: widget.binImages[bin],
                    width: binW,
                    height: binH,
                    label: bin,
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
