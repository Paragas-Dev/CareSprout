import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'intervention_difficulty.dart';

// ----- Base types -----
typedef MiniGameDone = void Function();

enum InterventionGameId {
  brushingTeeth,
  handwashing,
  gettingDressed,
  shoesMatching,
  bedMaking,
  healthyEatingPlate,
  bathTime,
  sortingLaundry,
  roomCleaning,
  groceryShopping,
  crossingStreet,
  moneyMatching,
  recyclingSorter,
}

class GameEntry {
  final InterventionGameId id;
  final String title;
  const GameEntry(this.id, this.title);
}

const List<GameEntry> allInterventionGames = [
  GameEntry(InterventionGameId.brushingTeeth, 'Brushing Teeth'),
  GameEntry(InterventionGameId.handwashing, 'Handwashing'),
  GameEntry(InterventionGameId.gettingDressed, 'Getting Dressed'),
  GameEntry(InterventionGameId.shoesMatching, 'Shoes Matching'),
  GameEntry(InterventionGameId.bedMaking, 'Bed Making'),
  GameEntry(InterventionGameId.healthyEatingPlate, 'Healthy Eating Plate'),
  GameEntry(InterventionGameId.bathTime, 'Bath Time'),
  GameEntry(InterventionGameId.sortingLaundry, 'Sorting Laundry'),
  GameEntry(InterventionGameId.roomCleaning, 'Room Cleaning'),
  GameEntry(InterventionGameId.groceryShopping, 'Grocery Shopping'),
  GameEntry(InterventionGameId.crossingStreet, 'Crossing Street'),
  GameEntry(InterventionGameId.moneyMatching, 'Money Matching'),
  GameEntry(InterventionGameId.recyclingSorter, 'Recycling Sorter'),
];

abstract class MiniGame extends StatefulWidget {
  final InterventionDifficulty diff;
  final MiniGameDone onDone;
  final String title;

  // New: background image and toggle for images
  final String? backgroundAsset;
  final bool useImages;

  const MiniGame({
    super.key,
    required this.diff,
    required this.onDone,
    required this.title,
    this.backgroundAsset,
    this.useImages = true,
  });
}

// ----- UI helpers -----
const _h1 =
    TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white);
const _h2 =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

String _prettyName(String pathOrId) {
  final parts = pathOrId.split('/');
  final base = parts.isNotEmpty ? parts.last : pathOrId;
  return base.split('.').first.replaceAll('_', ' ').toUpperCase();
}

class _PlaceholderTile extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final bool dim;
  final bool circle;

  const _PlaceholderTile({
    required this.width,
    required this.height,
    required this.label,
    this.dim = false,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = dim ? Colors.black.withOpacity(0.25) : Colors.transparent;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        color: Colors.white.withOpacity(0.08),
        borderRadius: circle ? null : BorderRadius.circular(12),
        border: Border.all(color: Colors.white70, width: 2),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6AA35C).withOpacity(0.25),
                    const Color(0xFF7BC67B).withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(child: Container(color: overlay)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.image_not_supported,
                    color: Colors.white70, size: 28),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
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

class _ScaffoldFrame extends StatefulWidget {
  final String title;
  final int? timer;
  final VoidCallback onTimeUp;
  final Widget child;
  final String? backgroundAsset;
  const _ScaffoldFrame({
    required this.title,
    required this.timer,
    required this.onTimeUp,
    required this.child,
    required this.backgroundAsset,
  });

  @override
  State<_ScaffoldFrame> createState() => _ScaffoldFrameState();
}

class _ScaffoldFrameState extends State<_ScaffoldFrame> {
  int? remaining;

  @override
  void initState() {
    super.initState();
    remaining = widget.timer;
    if (remaining != null) {
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return false;
        setState(() => remaining = (remaining! - 1));
        if (remaining == 0) {
          widget.onTimeUp();
          return false;
        }
        return remaining! > 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                Text(widget.title, style: _h1),
                const Spacer(),
                if (remaining != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE57373),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${remaining!}s',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: widget.child),
          ],
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String? asset;
  final double width;
  final double height;
  final String? label; // small overlay label for hints
  final bool dim;
  final bool circle;

  const _ImageTile({
    required this.asset,
    this.width = 140,
    this.height = 100,
    this.label,
    this.dim = false,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelText = label ??
        (asset != null && asset!.isNotEmpty ? _prettyName(asset!) : 'IMAGE');
    if (asset == null || asset!.isEmpty) {
      return _PlaceholderTile(
          width: width,
          height: height,
          label: labelText,
          dim: dim,
          circle: circle);
    }

    final img = ColorFiltered(
      colorFilter: ColorFilter.mode(
        dim ? Colors.black.withOpacity(0.35) : Colors.transparent,
        BlendMode.darken,
      ),
      child: Image.asset(
        asset!,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _PlaceholderTile(
          width: width,
          height: height,
          label: labelText,
          dim: dim,
          circle: circle,
        ),
      ),
    );
    return Stack(
      children: [
        circle
            ? ClipOval(child: img)
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: img,
              ),
        if (label != null)
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(label!,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
      ],
    );
  }
}

class _DraggableImage extends StatelessWidget {
  final String id; // data to pass through drag
  final String? asset;
  final bool enabled;
  const _DraggableImage(
      {required this.id, required this.asset, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final tile = _ImageTile(
      asset: asset,
      width: 150,
      height: 110,
      dim: !enabled,
      label: _prettyName(id),
    );
    if (!enabled) return tile;
    return Draggable<String>(
      data: id,
      feedback: Material(color: Colors.transparent, child: tile),
      childWhenDragging: Opacity(opacity: 0.3, child: tile),
      child: tile,
    );
  }
}

// ----- 1) Drag steps to correct order -----
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

// ----- 2) Drag items to bins -----
class DragToBinsGame extends MiniGame {
  final Map<String, String> itemToBin; // item id -> bin name
  final List<String> binNames;

  final Map<String, String?> itemImages; // item id -> image
  final Map<String, String?> binImages; // bin name -> image
  final String? decoyImage;

  const DragToBinsGame({
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
  State<DragToBinsGame> createState() => _DragToBinsGameState();
}

class _DragToBinsGameState extends State<DragToBinsGame> {
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

// ----- 3) Tap to clean -----
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

// ----- 4) Pick from grid -----
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

// ----- 5) Match pairs -----
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

//BRUSHING TEETH GAME

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

// HAND WASHING GAME
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
  late final List<String> targetOrder; // canonical order as provided
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

//HEALTHY PLATE GAME

class HealthyPlateGame extends MiniGame {
  final List<String?> correctImages;
  final List<String?> decoyImages;
  final String? plateImage;

  final String? plateRiveAsset;
  final String? plateRiveStateMachine;
  final String? plateRiveTrigger;

  final double plateScale;
  final double plateRiveScale;

  const HealthyPlateGame({
    super.key,
    required super.diff,
    required super.onDone,
    required super.title,
    required this.correctImages,
    required this.decoyImages,
    this.plateImage,
    this.plateRiveAsset,
    this.plateRiveStateMachine,
    this.plateRiveTrigger,
    this.plateScale = 1.0,
    this.plateRiveScale = 1.0,
    super.backgroundAsset,
  });

  @override
  State<HealthyPlateGame> createState() => _HealthyPlateGameState();
}

class _HealthyPlateGameState extends State<HealthyPlateGame> {
  late final List<String?> slots;
  late final Map<String, ({String? asset, bool correct})> items;

  // Rive plate
  rive.Artboard? _plateArtboard;
  rive.StateMachineController? _plateCtrl;
  rive.SMITrigger? _dropTrig;

  String? _milkId;
  String? _milkPlaced;

  @override
  void initState() {
    super.initState();

    final needed = min(widget.diff.maxSteps + 1, widget.correctImages.length);
    final selectedCorrect = widget.correctImages.take(needed).toList();

    final decoyCount = min(
      widget.decoyImages.length,
      needed + (widget.diff.distractions * 2),
    );
    final selectedDecoys = widget.decoyImages.take(decoyCount).toList();

    String idFor(String? asset, int index, bool correct) {
      if (asset == null || asset.isEmpty) {
        return '${correct ? 'healthy' : 'decoy'}_$index';
      }
      final base = _prettyName(asset).toLowerCase().replaceAll(' ', '_');
      return base;
    }

    final map = <String, ({String? asset, bool correct})>{};
    for (var i = 0; i < selectedCorrect.length; i++) {
      final a = selectedCorrect[i];
      final id = idFor(a, i, true);
      map[id] = (asset: a, correct: true);
    }
    for (var i = 0; i < selectedDecoys.length; i++) {
      final a = selectedDecoys[i];
      final id = idFor(a, i, false);
      final finalId = map.containsKey(id) ? '${id}_d$i' : id;
      map[finalId] = (asset: a, correct: false);
    }
    items = map;

    slots = List<String?>.filled(selectedCorrect.length, null);

    for (final e in items.entries) {
      final isCorrect = e.value.correct;
      final idLc = e.key.toLowerCase();
      final assetLc = (e.value.asset ?? '').toLowerCase();
      if (isCorrect && (idLc.contains('milk') || assetLc.contains('milk'))) {
        _milkId = e.key;
        break;
      }
    }

    _loadPlateRive();
  }

  Future<void> _loadPlateRive() async {
    final asset = widget.plateRiveAsset;
    if (asset == null || asset.isEmpty) return;
    try {
      final data = await rootBundle.load(asset);
      final file = rive.RiveFile.import(data);
      final art = file.mainArtboard;
      rive.StateMachineController? ctrl;
      if (widget.plateRiveStateMachine != null &&
          widget.plateRiveStateMachine!.isNotEmpty) {
        ctrl = rive.StateMachineController.fromArtboard(
            art, widget.plateRiveStateMachine!);
        if (ctrl != null) {
          art.addController(ctrl);
          for (final input in ctrl.inputs) {
            if (input.name == widget.plateRiveTrigger &&
                input is rive.SMITrigger) {
              _dropTrig = input;
            }
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _plateArtboard = art;
        _plateCtrl = ctrl;
      });
    } catch (_) {
      // fallback silently to static plate image
    }
  }

  void _playPlateOnDrop() => _dropTrig?.fire();

  void _checkPlateDone() {
    final baseDone = slots.whereType<String>().length == slots.length;
    final milkDone = _milkId == null || _milkPlaced != null;
    if (baseDone && milkDone) {
      Future.delayed(const Duration(milliseconds: 250), widget.onDone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 900;

    // remaining items split left/right
    final placedIds = {
      ...slots.whereType<String>(),
      if (_milkPlaced != null) _milkPlaced!,
    };
    final available = items.entries
        .where((e) => !placedIds.contains(e.key))
        .map((e) => (id: e.key, asset: e.value.asset, correct: e.value.correct))
        .toList()
      ..shuffle();

    final half = (available.length / 2).ceil();
    final leftItems = available.take(half).toList();
    final rightItems = available.skip(half).toList();

    final itemW = isSmall ? 110.0 : 130.0;
    final itemH = isSmall ? 86.0 : 104.0;

    return _ScaffoldFrame(
      title: widget.title,
      timer: widget.diff.timeLimitSeconds,
      onTimeUp: widget.onDone,
      backgroundAsset: widget.backgroundAsset,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left column foods
          SizedBox(
            width: isSmall ? 220 : 260,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: leftItems.map((e) {
                  return SizedBox(
                    width: itemW,
                    height: itemH,
                    child: _DraggableImage(id: e.id, asset: e.asset),
                  );
                }).toList(),
              ),
            ),
          ),
          // Center: plate with drop targets
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) {
                final base = isSmall ? 0.85 : 0.9;
                final plateSize =
                    (min(c.maxWidth, c.maxHeight) * base * widget.plateScale)
                        .clamp(200.0, 1000.0);
                final cols = (slots.length <= 3) ? max(slots.length, 1) : 3;
                final rows = (slots.length / cols).ceil();
                final gridW = plateSize * 0.8;
                final gridH = plateSize * 0.8;
                final slotW = gridW / cols;
                final slotH = gridH / rows;

                final diameter = min(slotW, slotH);

                return Center(
                  child: SizedBox(
                    width: plateSize,
                    height: plateSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Plate image or placeholder
                        Positioned.fill(
                          child: (_plateArtboard != null)
                              ? Center(
                                  child: OverflowBox(
                                    maxWidth: plateSize * widget.plateRiveScale,
                                    maxHeight:
                                        plateSize * widget.plateRiveScale,
                                    child: SizedBox(
                                      width: plateSize * widget.plateRiveScale,
                                      height: plateSize * widget.plateRiveScale,
                                      child: rive.Rive(
                                          artboard: _plateArtboard!,
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                )
                              : _ImageTile(
                                  asset: widget.plateImage,
                                  width: plateSize,
                                  height: plateSize,
                                  label: 'PLATE',
                                ),
                        ),
                        // Slots grid overlay
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: slotW * cols,
                            height: slotH * rows,
                            child: Stack(
                              children: List.generate(slots.length, (i) {
                                final r = i ~/ cols;
                                final cIdx = i % cols;

                                final left =
                                    cIdx * slotW + (slotW - diameter) / 2;
                                final top = r * slotH + (slotH - diameter) / 2;

                                final placedId = slots[i];
                                final placedAsset = placedId == null
                                    ? null
                                    : items[placedId]?.asset;

                                return Positioned(
                                  left: left,
                                  top: top,
                                  width: diameter,
                                  height: diameter,
                                  child: DragTarget<String>(
                                    onWillAccept: (id) {
                                      if (id == null) return false;
                                      final info = items[id];
                                      return info != null &&
                                          info.correct &&
                                          slots[i] == null;
                                    },
                                    onAccept: (id) {
                                      setState(() => slots[i] = id);
                                      _playPlateOnDrop();
                                      _checkPlateDone();
                                    },
                                    builder: (_, __, ___) => Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(
                                              color: Colors.white70, width: 2),
                                        ),
                                      ),
                                      child: _ImageTile(
                                        asset: placedAsset,
                                        width: diameter,
                                        height: diameter,
                                        circle: true,
                                        label:
                                            placedAsset == null ? 'DROP' : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        if (_milkId != null)
                          Positioned(
                            right: -plateSize * 0.10,
                            top: (plateSize - (plateSize * 0.34)) / 2,
                            width: plateSize * 0.22,
                            height: plateSize * 0.34,
                            child: DragTarget<String>(
                              onWillAccept: (id) =>
                                  id != null &&
                                  _milkPlaced == null &&
                                  id == _milkId,
                              onAccept: (id) {
                                setState(() => _milkPlaced = id);
                                _playPlateOnDrop();
                                _checkPlateDone();
                              },
                              builder: (_, __, ___) {
                                final placedAsset = _milkPlaced == null
                                    ? null
                                    : items[_milkPlaced!]?.asset;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white70,
                                      width: 2,
                                    ),
                                  ),
                                  child: _ImageTile(
                                    asset: placedAsset,
                                    width: plateSize * 0.22,
                                    height: plateSize * 0.34,
                                    label: placedAsset == null ? 'MILK' : null,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Right column foods
          SizedBox(
            width: isSmall ? 220 : 260,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rightItems.map((e) {
                  return SizedBox(
                    width: itemW,
                    height: itemH,
                    child: _DraggableImage(id: e.id, asset: e.asset),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----- Factory: build a mini-game with image assets and background -----
MiniGame buildInterventionMiniGame({
  required InterventionGameId id,
  required InterventionDifficulty diff,
  required VoidCallback onDone,
  String? backgroundAsset,
  bool useImages = true,
}) {
  switch (id) {
    case InterventionGameId.brushingTeeth:
      return BrushingTeethGame(
        title: 'Brushing Teeth',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        stepImages: const {
          'Wet Brush': 'assets/Intervention/brushing_teeth/wet_brush.png',
          'Apply Toothpaste':
              'assets/Intervention/brushing_teeth/toothpaste.png',
          'Brush Teeth': 'assets/Intervention/brushing_teeth/toothbrush.png',
          'Rinse': 'assets/Intervention/brushing_teeth/rinse.png',
          'Wipe Mouth': 'assets/Intervention/brushing_teeth/towel.png',
        },
        mouthImages: const [
          'assets/Intervention/brushing_teeth/teeth1.jpg',
          'assets/Intervention/brushing_teeth/teeth2.jpg',
          'assets/Intervention/brushing_teeth/teeth3.jpg',
        ],
        stainImage: 'assets/Intervention/brushing_teeth/stain.png',
      );
    case InterventionGameId.handwashing:
      return HandWashingGame(
        title: 'Handwashing',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        stepImages: const {
          'Wet Hands': 'assets/Intervention/handwashing/wet.png',
          'Apply Soap': 'assets/Intervention/handwashing/soap.png',
          'Scrub': 'assets/Intervention/handwashing/scrub.png',
          'Rinse': 'assets/Intervention/handwashing/rinse.png',
          'Towel Dry': 'assets/Intervention/handwashing/towel.png',
        },
      );
    case InterventionGameId.gettingDressed:
      return DragSequenceGame(
        title: 'Getting Dressed',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        stepImages: const {
          'Underwear': 'assets/Intervention/dressed/underwear.png',
          'Shirt': 'assets/Intervention/dressed/shirt.png',
          'Pants': 'assets/Intervention/dressed/pants.png',
          'Socks': 'assets/Intervention/dressed/socks.png',
          'Shoes': 'assets/Intervention/dressed/shoes.png',
        },
      );
    case InterventionGameId.shoesMatching:
      return MatchPairsGame(
        title: 'Shoes Matching',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        pairs: const {
          'red': (
            'assets/Intervention/shoes/red_left.png',
            'assets/Intervention/shoes/red_right.png'
          ),
          'blue': (
            'assets/Intervention/shoes/blue_left.png',
            'assets/Intervention/shoes/blue_right.png'
          ),
          'green': (
            'assets/Intervention/shoes/green_left.png',
            'assets/Intervention/shoes/green_right.png'
          ),
          'yellow': (
            'assets/Intervention/shoes/yellow_left.png',
            'assets/Intervention/shoes/yellow_right.png'
          ),
        },
      );
    case InterventionGameId.bedMaking:
      return DragSequenceGame(
        title: 'Bed Making',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        stepImages: const {
          'Pull Sheet': 'assets/Intervention/bed/pull_sheet.png',
          'Spread Blanket': 'assets/Intervention/bed/blanket.png',
          'Place Pillow': 'assets/Intervention/bed/pillow.png',
          'Smooth Blanket': 'assets/Intervention/bed/smooth.png',
          'Tuck Corners': 'assets/Intervention/bed/tuck.png',
        },
      );
    case InterventionGameId.healthyEatingPlate:
      return HealthyPlateGame(
        title: 'Healthy Eating Plate',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        plateImage: 'assets/Intervention/foods/plate.png',
        plateRiveAsset: 'assets/Rive_Files/plate.riv',
        plateRiveStateMachine: 'dish',
        plateRiveTrigger: 'drop',
        plateScale: 1.2,
        plateRiveScale: 1.3,
        correctImages: const [
          'assets/Intervention/foods/apple.png',
          'assets/Intervention/foods/carrot.png',
          'assets/Intervention/foods/drumstick.png',
          'assets/Intervention/foods/rice.png',
          'assets/Intervention/foods/milk.png',
          'assets/Intervention/foods/fish.png',
        ],
        decoyImages: const [
          'assets/Intervention/foods/sweets.png',
          'assets/Intervention/foods/soda.png',
          'assets/Intervention/foods/chips.png',
          'assets/Intervention/foods/cake.png',
          'assets/Intervention/foods/donut.png',
          'assets/Intervention/foods/fries.png',
          'assets/Intervention/foods/pizza.png',
        ],
      );
    case InterventionGameId.bathTime:
      return DragSequenceGame(
        title: 'Bath Time',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        stepImages: const {
          'Turn On Water': 'assets/Intervention/bath/turn_on.png',
          'Wash Body': 'assets/Intervention/bath/wash.png',
          'Shampoo': 'assets/Intervention/bath/shampoo.png',
          'Rinse': 'assets/Intervention/bath/rinse.png',
          'Dry with Towel': 'assets/Intervention/bath/towel.png',
        },
      );
    case InterventionGameId.sortingLaundry:
      return DragToBinsGame(
        title: 'Sorting Laundry',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        itemToBin: const {
          'white_shirt': 'Whites',
          'blue_jeans': 'Colors',
          'red_tshirt': 'Colors',
          'towel': 'Whites',
        },
        binNames: const ['Whites', 'Colors'],
        itemImages: const {
          'white_shirt': 'assets/Intervention/laundry/white_shirt.png',
          'blue_jeans': 'assets/Intervention/laundry/blue_jeans.png',
          'red_tshirt': 'assets/Intervention/laundry/red_tshirt.png',
          'towel': 'assets/Intervention/laundry/towel.png',
        },
        binImages: const {
          'Whites': 'assets/Intervention/laundry/bin_whites.png',
          'Colors': 'assets/Intervention/laundry/bin_colors.png',
        },
        decoyImage: 'assets/Intervention/laundry/hat.png',
      );
    case InterventionGameId.roomCleaning:
      return TapCleanGame(
        title: 'Room Cleaning',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        spotImage: 'assets/Intervention/room/spot.png',
      );
    case InterventionGameId.groceryShopping:
      return PickFromGridGame(
        title: 'Grocery Shopping',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        correctImages: const [
          'assets/Intervention/grocery/milk.png',
          'assets/Intervention/grocery/bread.png',
          'assets/Intervention/grocery/eggs.png',
          'assets/Intervention/grocery/apples.png',
          'assets/Intervention/grocery/rice.png',
          'assets/Intervention/grocery/fish.png',
        ],
        decoyImages: const [
          'assets/Intervention/grocery/toy_car.png',
          'assets/Intervention/grocery/tshirt.png',
          'assets/Intervention/grocery/pillow.png',
          'assets/Intervention/grocery/notebook.png',
          'assets/Intervention/grocery/soap.png',
          'assets/Intervention/grocery/broom.png',
        ],
      );
    case InterventionGameId.crossingStreet:
      return DragSequenceGame(
        title: 'Crossing the Street',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        stepImages: const {
          'Stop at Curb': 'assets/Intervention/street/stop.png',
          'Look Left': 'assets/Intervention/street/left.png',
          'Look Right': 'assets/Intervention/street/right.png',
          'Listen': 'assets/Intervention/street/listen.png',
          'Walk Across': 'assets/Intervention/street/walk.png',
        },
      );
    case InterventionGameId.moneyMatching:
      return MatchPairsGame(
        title: 'Money Matching',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        pairs: const {
          'penny': (
            'assets/Intervention/money/1c.png',
            'assets/Intervention/money/penny.png'
          ),
          'nickel': (
            'assets/Intervention/money/5c.png',
            'assets/Intervention/money/nickel.png'
          ),
          'dime': (
            'assets/Intervention/money/10c.png',
            'assets/Intervention/money/dime.png'
          ),
          'quarter': (
            'assets/Intervention/money/25c.png',
            'assets/Intervention/money/quarter.png'
          ),
        },
      );
    case InterventionGameId.recyclingSorter:
      return DragToBinsGame(
        title: 'Recycling Sorter',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        itemToBin: const {
          'bottle': 'Plastic',
          'can': 'Metal',
          'newspaper': 'Paper',
          'box': 'Paper',
        },
        binNames: const ['Plastic', 'Metal', 'Paper'],
        itemImages: const {
          'bottle': 'assets/Intervention/recycle/bottle.png',
          'can': 'assets/Intervention/recycle/can.png',
          'newspaper': 'assets/Intervention/recycle/newspaper.png',
          'box': 'assets/Intervention/recycle/box.png',
        },
        binImages: const {
          'Plastic': 'assets/Intervention/recycle/bin_plastic.png',
          'Metal': 'assets/Intervention/recycle/bin_metal.png',
          'Paper': 'assets/Intervention/recycle/bin_paper.png',
        },
        decoyImage: 'assets/Intervention/recycle/banana_peel.png',
      );
  }
}
