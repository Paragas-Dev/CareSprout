part of '../mini_game.dart';

class BedMakingAssembleGame extends MiniGame {
  // Base bed image at center
  final String? bedBase;

  // Ordered steps to complete the bed
  final List<_BedStep> steps;

  const BedMakingAssembleGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.bedBase,
    required this.steps,
    super.backgroundAsset,
  });

  @override
  State<BedMakingAssembleGame> createState() => _BedMakingAssembleGameState();
}

class _BedMakingAssembleGameState extends State<BedMakingAssembleGame> {
  late String? _displayAsset; // currently shown bed state
  int _idx = 0; // next required step index
  bool _wrongFlash = false; // flash red on wrong drop
  final Set<String> _used = {}; // draggables already applied

  @override
  void initState() {
    super.initState();
    _displayAsset = widget.bedBase;
  }

  _BedStep get _currentStep => widget.steps[_idx];
  bool get _isDone => _idx >= widget.steps.length;

  Future<void> _applyStep(_BedStep step) async {
    setState(() => _used.add(step.id));

    // Optional transition (e.g., pulling_sheets for 2s)
    if (step.transitionAsset != null) {
      setState(() => _displayAsset = step.transitionAsset);
      await Future.delayed(
          step.transitionDuration ?? const Duration(seconds: 2));
    }

    // Final image for this stage
    setState(() => _displayAsset = step.finalAsset);

    // Advance
    _idx++;
    if (_isDone) {
      Future.delayed(const Duration(milliseconds: 250), widget.onDone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showHints = widget.diff.hintsVisible;

    final isSmall = MediaQuery.of(context).size.width < 900;
    final bedSizeFactor = isSmall ? 0.9 : 1.0;
    final dropW = isSmall ? 180.0 : 220.0;
    final dropH = isSmall ? 90.0 : 110.0;

    // Remaining draggables split into left/right columns
    final remaining = widget.steps.where((s) => !_used.contains(s.id)).toList();
    final mid = (remaining.length / 2).ceil();
    final left = remaining.take(mid).toList();
    final right = remaining.skip(mid).toList();

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BedSideColumn(steps: left, showHints: showHints),
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) {
                final size = min(c.maxWidth, c.maxHeight) * bedSizeFactor;
                return Center(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Center bed state
                        _ImageTile(
                          asset: _displayAsset,
                          width: size,
                          height: size,
                        ),

                        // Drop slot near the top area of the bed
                        Positioned(
                          top: size * 0.06,
                          child: DragTarget<String>(
                            onWillAccept: (data) =>
                                !_isDone && data == _currentStep.id,
                            onAccept: (data) async {
                              if (data == _currentStep.id) {
                                await _applyStep(_currentStep);
                              } else {
                                setState(() => _wrongFlash = true);
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  if (mounted) {
                                    setState(() => _wrongFlash = false);
                                  }
                                });
                              }
                            },
                            builder: (_, __, ___) => AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: dropW,
                              height: dropH,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _wrongFlash
                                      ? Colors.redAccent
                                      : Colors.white70,
                                  width: 2,
                                ),
                              ),
                              child: _ImageTile(
                                asset: null,
                                width: dropW,
                                height: dropH,
                                label: showHints && !_isDone
                                    ? 'DROP: ${_prettyName(_currentStep.id)}'
                                    : 'DROP HERE',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _BedSideColumn(steps: right, showHints: showHints),
        ],
      ),
    );
  }
}

// Left/Right column with draggable items
class _BedSideColumn extends StatelessWidget {
  final List<_BedStep> steps;
  final bool showHints;
  const _BedSideColumn({required this.steps, required this.showHints});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 900;
    final itemW = isSmall ? 130.0 : 150.0;
    final itemH = isSmall ? 96.0 : 110.0;

    return SizedBox(
      width: isSmall ? 190 : 220,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: steps.map((s) {
            final tile = _ImageTile(
              asset: s.dragAsset,
              width: itemW,
              height: itemH,
              label: showHints ? _prettyName(s.id) : null,
            );
            return SizedBox(
              width: itemW,
              height: itemH,
              child: Draggable<String>(
                data: s.id,
                feedback: Material(color: Colors.transparent, child: tile),
                childWhenDragging: Opacity(opacity: 0.3, child: tile),
                child: tile,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Step definition
class _BedStep {
  final String id; // e.g., 'bed_sheet'
  final String? dragAsset; // the item you drag from the side
  final String? transitionAsset; // optional temporary state image
  final Duration? transitionDuration;
  final String? finalAsset; // resulting center image after drop

  const _BedStep({
    required this.id,
    required this.dragAsset,
    this.transitionAsset,
    this.transitionDuration,
    required this.finalAsset,
  });
}
