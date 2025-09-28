part of '../mini_game.dart';

class TapCleanGame extends MiniGame {
  final String? spotImage; // dirt/spot image
  final int spots;
  const TapCleanGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    this.spotImage,
    this.spots = 6,
    super.backgroundAsset,
  });

  @override
  State<TapCleanGame> createState() => _TapCleanGameState();
}

class _TapCleanGameState extends State<TapCleanGame> {
  late final Set<int> remaining;
  final rand = Random();

  @override
  void initState() {
    super.initState();
    final count = max(3, max(widget.diff.maxSteps, widget.spots));
    remaining = Set.of(List.generate(count, (i) => i));
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 900;
    final spotSize = isSmall ? 60.0 : 72.0;

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: LayoutBuilder(builder: (_, c) {
        final w = c.maxWidth, h = c.maxHeight;
        return Stack(
          children: [
            for (final i in remaining)
              Positioned(
                left: rand.nextDouble() * (w - spotSize - 20),
                top: rand.nextDouble() * (h - spotSize - 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() => remaining.remove(i));
                    if (remaining.isEmpty) widget.onDone();
                  },
                  child: _ImageTile(
                    asset: widget.spotImage,
                    width: spotSize,
                    height: spotSize,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
