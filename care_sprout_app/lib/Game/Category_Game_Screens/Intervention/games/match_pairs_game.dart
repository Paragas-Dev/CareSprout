part of '../mini_game.dart';

class MatchPairsGame extends MiniGame {
  // key -> pair of image paths
  final Map<String, (String? left, String? right)> pairs;
  const MatchPairsGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.pairs,
    super.backgroundAsset,
  });

  @override
  State<MatchPairsGame> createState() => _MatchPairsGameState();
}

class _MatchPairsGameState extends State<MatchPairsGame> {
  String? leftSel, rightSel;
  late final List<String> keys;
  final Set<String> done = {};

  @override
  void initState() {
    super.initState();
    keys = widget.pairs.keys.take(widget.diff.maxSteps + 1).toList()..shuffle();
  }

  bool get completed => done.length == keys.length;

  @override
  Widget build(BuildContext context) {
    final lefts = keys
        .map((k) => (k, widget.pairs[k]!.$1))
        .where((pair) => pair.$2 != null)
        .map((pair) => (pair.$1, pair.$2!))
        .toList();
    final rights = keys
        .map((k) => (k, widget.pairs[k]!.$2))
        .where((pair) => pair.$2 != null)
        .map((pair) => (pair.$1, pair.$2!))
        .toList()
      ..shuffle();

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: Row(
        children: [
          Expanded(child: _column(lefts, true)),
          Expanded(child: _column(rights, false)),
        ],
      ),
    );
  }

  Widget _column(List<(String k, String asset)> items, bool isLeft) {
    return LayoutBuilder(
      builder: (_, c) {
        final isSmall = c.maxWidth < 420;
        final w =
            (isSmall ? c.maxWidth - 24 : (c.maxWidth - 32)).clamp(150.0, 220.0);
        final h = (w * 0.55);

        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final (k, asset) = items[i];
            final selected = (isLeft ? leftSel : rightSel) == k;
            final solved = done.contains(k);
            return _ImageTile(
              asset: asset,
              width: w,
              height: h,
              dim: solved || selected,
              label: _prettyName(k),
            );
          },
        );
      },
    );
  }
}
