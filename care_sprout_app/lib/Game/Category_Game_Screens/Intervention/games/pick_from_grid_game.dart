part of '../mini_game.dart';

class PickFromGridGame extends MiniGame {
  final List<String?> correctImages;
  final List<String?> decoyImages;
  const PickFromGridGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.correctImages,
    required this.decoyImages,
    super.backgroundAsset,
  });

  @override
  State<PickFromGridGame> createState() => _PickFromGridGameState();
}

class _PickFromGridGameState extends State<PickFromGridGame> {
  final Set<int> chosen = {};
  late final List<({String? asset, bool correct})> options;
  late final int neededCount;

  @override
  void initState() {
    super.initState();
    final steps = min(widget.diff.maxSteps + 1, widget.correctImages.length);
    final correct =
        widget.correctImages.take(steps).map((a) => (asset: a, correct: true));
    final decoys = widget.decoyImages
        .take(steps + (widget.diff.distractions * 2))
        .map((a) => (asset: a, correct: false));
    options = [...correct, ...decoys]..shuffle();
    neededCount = options.where((o) => o.correct).length;
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 900;
    final cross = isSmall ? 3 : 4;
    const spacing = 12.0;
    const aspect = 4 / 3;

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: GridView.builder(
        itemCount: options.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspect,
        ),
        itemBuilder: (_, i) {
          final opt = options[i];
          final active = chosen.contains(i);
          return LayoutBuilder(
            builder: (_, cell) => _ImageTile(
              asset: opt.asset,
              width: cell.maxWidth,
              height: cell.maxHeight,
              dim: active,
            ),
          );
        },
      ),
    );
  }
}
