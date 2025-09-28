// ignore_for_file: unused_field

part of '../mini_game.dart';

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
