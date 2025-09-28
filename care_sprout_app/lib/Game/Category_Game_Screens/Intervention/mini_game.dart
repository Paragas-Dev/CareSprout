library intervention_mini_games;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'intervention_difficulty.dart';

part 'games/drag_sequence_game.dart';
part 'games/drag_to_bin_game.dart';
part 'games/tap_clean_game.dart';
part 'games/pick_from_grid_game.dart';
part 'games/match_pairs_game.dart';
part 'games/brushing_teeth_game.dart';
part 'games/hand_washing_game.dart';
part 'games/getting_dressed_game.dart';
part 'games/bed_making_game.dart';
part 'games/healthy_plate_game.dart';



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
        // NEW: background layer
        Positioned.fill(
          child: widget.backgroundAsset == null
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF74B9FF), Color(0xFFA29BFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                )
              : Image.asset(
                  widget.backgroundAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF74B9FF), Color(0xFFA29BFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
        ),
        // slight dim so UI text is readable
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.05)),
        ),
        // existing UI
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

// ----- Factory: build a mini-game with image assets and background -----
Widget buildInterventionMiniGame({
  required InterventionGameId id,
  required InterventionDifficulty diff,
  required VoidCallback onDone,
  String? backgroundAsset,
  bool useImages = true,
}) {
  switch (id) {
    case InterventionGameId.brushingTeeth:
      return BrushingTeethGame(
        diff: diff,
        onDone: onDone,
        title: 'Brushing Teeth',
        backgroundAsset: backgroundAsset,
        stepImages: const {
          'Wet Brush': 'assets/Intervention/brushing_teeth/toothbrush.png',
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
          'Wet Hands': 'assets/Intervention/handwashing/washing-hand.png',
          'Apply Soap': 'assets/Intervention/handwashing/apply-soap.png',
          'Scrub': 'assets/Intervention/handwashing/scrubbing.png',
          'Rinse': 'assets/Intervention/handwashing/rinse.png',
          'Towel Dry': 'assets/Intervention/handwashing/towel.png',
        },
      );
    case InterventionGameId.gettingDressed:
      return GettingDressedGame(
        title: 'Getting Dressed',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        pairs: const {
          'Feet': (
            top: 'assets/Intervention/dressed/foot.png',
            bottom: 'assets/Intervention/dressed/boots.png'
          ),
          'Head': (
            top: 'assets/Intervention/dressed/head.png',
            bottom: 'assets/Intervention/dressed/hat.png'
          ),
          'Torso': (
            top: 'assets/Intervention/dressed/torso.jpg',
            bottom: 'assets/Intervention/dressed/shirt.png'
          ),
          'Hands': (
            top: 'assets/Intervention/dressed/hands.png',
            bottom: 'assets/Intervention/dressed/gloves.png'
          ),
          'Neck': (
            top: 'assets/Intervention/dressed/neck.png',
            bottom: 'assets/Intervention/dressed/scarf.png'
          ),
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
            'assets/Intervention/shoes/left-red.png',
            'assets/Intervention/shoes/right-red.png'
          ),
          'blue': (
            'assets/Intervention/shoes/left-blue.png',
            'assets/Intervention/shoes/right-blue.png'
          ),
          'green': (
            'assets/Intervention/shoes/left-green.png',
            'assets/Intervention/shoes/right-green.png'
          ),
          'yellow': (
            'assets/Intervention/shoes/left-yellow.png',
            'assets/Intervention/shoes/right-yellow.png'
          ),
        },
      );
    case InterventionGameId.bedMaking:
      return BedMakingAssembleGame(
        title: 'Bed Making',
        diff: diff,
        onDone: onDone,
        backgroundAsset: backgroundAsset,
        bedBase: 'assets/Intervention/bed/bed.png',
        steps: const [
          _BedStep(
            id: 'bed_sheet',
            dragAsset: 'assets/Intervention/bed/bed_sheet.png',
            transitionAsset: 'assets/Intervention/bed/pulling_sheets.png',
            transitionDuration: Duration(seconds: 2),
            finalAsset: 'assets/Intervention/bed/pull_sheet.png',
          ),
          _BedStep(
            id: 'blanket',
            dragAsset: 'assets/Intervention/bed/blanket.png',
            finalAsset: 'assets/Intervention/bed/spread_blanket.png',
          ),
          _BedStep(
            id: 'smoothing_blanket',
            dragAsset: 'assets/Intervention/bed/smoothing_blanket.png',
            finalAsset: 'assets/Intervention/bed/smooth_blanket.png',
          ),
          _BedStep(
            id: 'pillow',
            dragAsset: 'assets/Intervention/bed/pillow.png',
            finalAsset: 'assets/Intervention/bed/place_pillow.png',
          ),
          _BedStep(
            id: 'tucking_corners',
            dragAsset: 'assets/Intervention/bed/tucking_corners.png',
            finalAsset: 'assets/Intervention/bed/tuck_corners.png',
          ),
        ],
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
      return DragToBinGame(
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
          'assets/Intervention/grocery/milk-box.png',
          'assets/Intervention/grocery/bread.png',
          'assets/Intervention/grocery/egg.png',
          'assets/Intervention/grocery/mangoes.png',
          'assets/Intervention/grocery/rice-sack.png',
          'assets/Intervention/grocery/fish.png',
        ],
        decoyImages: const [
          'assets/Intervention/grocery/rc-car.png',
          'assets/Intervention/grocery/tshirt.png',
          'assets/Intervention/grocery/pillows.png',
          'assets/Intervention/grocery/notebook.png',
          'assets/Intervention/grocery/bar-soap.png',
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
      return DragToBinGame(
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
          'Plastic': 'assets/Intervention/recycle/plastic-bin.png',
          'Metal': 'assets/Intervention/recycle/metal-bin.png',
          'Paper': 'assets/Intervention/recycle/paper-bin.png',
        },
        decoyImage: 'assets/Intervention/recycle/banana_peel.png',
      );
  }
}
