// ignore_for_file: unused_local_variable, prefer_final_fields, unnecessary_to_list_in_spreads

import 'dart:math';

import 'package:care_sprout/Components/game_background.dart';
import 'package:care_sprout/Game/Category_Game_Screens/Alphabet/alphabet_data.dart';
import 'package:care_sprout/Game/game_homescreen.dart';
import 'package:care_sprout/Helper/audio_service.dart';
import 'package:care_sprout/Helper/rive_button_loader.dart';
import 'package:care_sprout/Services/progress_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

class AlphabetGameScreen extends StatefulWidget {
  final String category;
  final int level;
  const AlphabetGameScreen({
    super.key,
    required this.category,
    required this.level,
  });

  @override
  State<AlphabetGameScreen> createState() => _AlphabetGameScreenState();
}

class _AlphabetGameScreenState extends State<AlphabetGameScreen> {
  rive.SMITrigger? backClick;
  rive.StateMachineController? backController;
  rive.Artboard? backArtboard;

  int _currentRound = 0;
  bool _isRoundCompleted = false;

  late List<String> _levelLetters;
  String _typedWord = '';

  late List<Map<String, dynamic>> _rounds;

  // New state for the matching game
  List<String> _gameLetters = [];
  List<String> _selectedLetters = [];
  List<String> _matchedPairs = [];

  void _initializeMatchingGame() {
    // Create a list of 4 random letters
    final alphabet = List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));
    alphabet.shuffle(Random());
    final selectedLetters = alphabet.take(4).toList();

    // Create pairs of uppercase and lowercase letters
    _gameLetters = [
      ...selectedLetters,
      ...selectedLetters.map((l) => l.toLowerCase()).toList()
    ]..shuffle(Random());

    _selectedLetters.clear();
    _matchedPairs.clear();
  }

  @override
  void initState() {
    super.initState();
    _loadRiveAssets();
    //Force landscape when this screen opens
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Create a list of all letters from A-Z
    final alphabet = List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));
    alphabet.shuffle(Random());

    // Select the first 10 unique, random letters for this level
    _levelLetters = alphabet.sublist(0, 10);

    // Define the game difficulty tiers
    final easyGames = <Widget Function(String)>[
      _buildTapTheLetterGame,
      _buildTraceTheLetterGame,
      _buildMatchingGame,
      _buildFindTheLetterGame,
    ];
    final mediumGames = <Widget Function(String)>[
      ...easyGames,
      _buildMatchTheSoundGame,
      _buildFindThePictureGame,
      _buildFillInTheBlankGame,
      _buildAlphabetPuzzleGame,
      _buildLetterSoundPopGame,
    ];
    final hardGames = <Widget Function(String)>[
      ...mediumGames,
      _buildSpellTheWordGame,
    ];

    // Select the pool of available games based on the level
    List<Widget Function(String)> availableGames;
    if (widget.level <= 3) {
      availableGames = easyGames;
    } else if (widget.level <= 6) {
      availableGames = mediumGames;
    } else {
      availableGames = hardGames;
    }

    // Create the rounds list with a random letter and a random game for each
    _rounds = List.generate(
      10, // A fixed count of 10 rounds per level
      (i) => {
        'letter': _levelLetters[i],
        'game': availableGames[Random().nextInt(availableGames.length)],
      },
    );
  }

  Future<void> _loadRiveAssets() async {
    try {
      final backBtn = await loadRiveButton(
        assetPath: 'assets/Rive_Files/backarrow.riv',
        stateMachineName: 'backArrow',
        triggerName: 'btn Click',
      );

      setState(() {
        backArtboard = backBtn.artboard;
        backController = backBtn.controller;
        backClick = backBtn.trigger;
      });
      debugPrint('Rive back button loaded successfully.');
    } catch (e) {
      debugPrint('Error loading Rive asset: $e');
      // Set artboard to null explicitly on failure to ensure widget is not built
      setState(() {
        backArtboard = null;
      });
    }
  }

  void _onTap() {
    if (backClick != null) {
      AudioService().playClickSound();
      backClick!.fire();
      debugPrint('Button Clicked!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Reset to portrait only when leaving game section
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GameHomescreen()),
          );
        }
      });
    }
  }

  void _nextRound() {
    if (_currentRound < _rounds.length - 1) {
      AudioService().playClickSound();
      setState(() {
        _currentRound++;
        _isRoundCompleted = false;
        _typedWord = '';
        // Re-initialize state for new round
        _initializeMatchingGame();
      });
    } else {
      ProgressManager.unlockNextLevelIfNeeded(
          widget.category, widget.level, 26);
      Navigator.pop(context, true);
    }
  }

  // --- Mini-Games ---
  Widget _buildRound() {
    final roundData = _rounds[_currentRound];
    final letter = roundData['letter'] as String;
    final gameBuilder = roundData['game'] as Widget Function(String);
    return gameBuilder(letter);
  }

  // Helper method to get the instruction text for the current game
  String _getInstructionTextForCurrentGame() {
    if (_rounds.isEmpty) return "";
    final currentRoundData = _rounds[_currentRound];
    final gameBuilder = currentRoundData['game'] as Widget Function(String);

    if (gameBuilder == _buildTapTheLetterGame) {
      return "TAP THE LETTER";
    } else if (gameBuilder == _buildTraceTheLetterGame) {
      return "TRACE THE LETTER";
    } else if (gameBuilder == _buildMatchingGame) {
      return "MATCH THE LETTERS";
    } else if (gameBuilder == _buildFindTheLetterGame) {
      return "FIND THE LETTER";
    } else if (gameBuilder == _buildMatchTheSoundGame) {
      return "TAP THE LETTER THAT MAKES THIS SOUND";
    } else if (gameBuilder == _buildFindThePictureGame) {
      return "FIND THE PICTURE";
    } else if (gameBuilder == _buildFillInTheBlankGame) {
      return "FILL IN THE BLANK";
    } else if (gameBuilder == _buildAlphabetPuzzleGame) {
      return "ARRANGE THE LETTERS";
    } else if (gameBuilder == _buildLetterSoundPopGame) {
      return "LISTEN AND TAP THE LETTER";
    } else {
      return "GAME INSTRUCTIONS";
    }
  }

  @override
  Widget build(BuildContext context) {
    String instructionText = _getInstructionTextForCurrentGame();
    return Scaffold(
      body: Stack(
        children: [
          const GameBackground(),
          SafeArea(
              child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    if (backArtboard != null)
                      GestureDetector(
                        onTap: _onTap,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: rive.Rive(
                            artboard: backArtboard!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                    // The dynamic instruction text
                    Expanded(
                      child: Center(
                        child: Text(
                          instructionText,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 102, 199, 13),
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Volume Button
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.volume_up,
                        size: 40,
                        color: Color.fromARGB(255, 237, 185, 96),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildRound(),
              ),
              if (_isRoundCompleted)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: _nextRound,
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildTapTheLetterGame(String letter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              AudioService().playClickSound();
              setState(() {
                _isRoundCompleted = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Correct!')),
              );
            },
            child: SizedBox(
              // You can adjust the width and height of the letter image here.
              width: 250,
              height: 250,
              child: Image.asset(
                'assets/images/alphabet/${letter.toUpperCase()}.png',
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTraceTheLetterGame(String letter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Trace the letter:",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onPanStart: (details) {
              // Simple "trace" start logic
              if (!_isRoundCompleted) {
                setState(() {
                  _isRoundCompleted = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Good job!')),
                );
              }
            },
            child: Container(
              // Adjust the container size to match the image size.
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/images/alphabet/${letter.toUpperCase()}.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchTheSoundGame(String letter) {
    // Generate a random incorrect letter
    final alphabet = List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));
    alphabet.remove(letter);
    alphabet.shuffle(Random());
    final incorrectLetter = alphabet.first;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 50),
            onPressed: () {
              // Placeholder for playing sound
              AudioService().playClickSound();
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImageButton(letter, () {
                setState(() {
                  _isRoundCompleted = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Correct!')),
                );
              }),
              const SizedBox(width: 20),
              _buildImageButton(incorrectLetter, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Try again!')),
                );
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFindThePictureGame(String letter) {
    String? pictureAsset = alphabetData[letter]?['picture_asset'];
    String word = alphabetData[letter]?['word'] ?? '';
    final allLetters = alphabetData.keys.toList()..shuffle();
    final incorrectWords = allLetters
        .where((element) => element != letter)
        .take(2)
        .map((e) => alphabetData[e]!['word'] as String)
        .toList();
    final allWords = [word, ...incorrectWords]..shuffle();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: allWords.map((wordOption) {
              final isCorrect = wordOption == word;
              return GestureDetector(
                onTap: () {
                  if (isCorrect) {
                    setState(() {
                      _isRoundCompleted = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Correct!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Try again!')),
                    );
                  }
                },
                child: Container(
                  // Adjust the container size to control image size.
                  width: 150,
                  height: 150,
                  color: Colors.blue,
                  child: Center(
                    child: alphabetData.values.firstWhere((data) =>
                                data['word'] == wordOption)['picture_asset'] !=
                            null
                        ? Image.asset(
                            alphabetData.values.firstWhere((data) =>
                                data['word'] == wordOption)['picture_asset'],
                            fit: BoxFit.contain,
                          )
                        : Text(
                            wordOption,
                            style: const TextStyle(
                                fontSize: 24, color: Colors.white),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellTheWordGame(String letter) {
    String word = alphabetData[letter]?['word'] ?? 'unknown';
    List<String> correctLetters = word.split('');
    List<String> shuffledLetters = List.from(correctLetters)..shuffle();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Spell the word: $word",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: correctLetters.asMap().entries.map((entry) {
              final index = entry.key;
              final typedLetter =
                  index < _typedWord.length ? _typedWord[index] : '';

              return Container(
                // Adjust this container size for the input letters.
                width: 80,
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: typedLetter.isNotEmpty
                      ? Image.asset(
                          _getLetterImagePath(typedLetter),
                          fit: BoxFit.contain,
                        )
                      : const Text(
                          '',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...shuffledLetters.map(
                  (shuffledLetter) => _buildImageButton(shuffledLetter, () {
                        setState(() {
                          _typedWord += shuffledLetter;
                        });
                        if (_typedWord == word) {
                          setState(() {
                            _isRoundCompleted = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Correct!')),
                          );
                        }
                      }))
            ],
          ),
        ],
      ),
    );
  }

  // New Game: Match the Letters (as seen in the image)
  Widget _buildMatchingGame(String letter) {
    // This logic ensures the game state is initialized only once per round
    if (_gameLetters.isEmpty) {
      _initializeMatchingGame();
    }

    // ignore: no_leading_underscores_for_local_identifiers
    void _handleTap(String tappedLetter) {
      if (_selectedLetters.length < 2 &&
          !_matchedPairs.contains(tappedLetter)) {
        setState(() {
          _selectedLetters.add(tappedLetter);
        });

        if (_selectedLetters.length == 2) {
          final first = _selectedLetters[0];
          final second = _selectedLetters[1];
          final isMatch = (first.toLowerCase() == second.toLowerCase()) &&
              (first != second);

          if (isMatch) {
            AudioService().playClickSound(); // Play correct sound
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Match!')),
            );
            setState(() {
              _matchedPairs.addAll(_selectedLetters);
              _selectedLetters.clear();
            });

            if (_matchedPairs.length == _gameLetters.length) {
              // All pairs matched
              setState(() {
                _isRoundCompleted = true;
              });
            }
          } else {
            AudioService().playClickSound(); // Play wrong sound
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Try again!')),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                _selectedLetters.clear();
              });
            });
          }
        }
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _gameLetters.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final letter = _gameLetters[index];
                final isSelected = _selectedLetters.contains(letter);
                final isMatched = _matchedPairs.contains(letter);

                return Opacity(
                  opacity: isMatched ? 0.3 : 1.0,
                  child: _buildImageButton(
                    letter,
                    () => _handleTap(letter),
                    isSelected: isSelected,
                    isMatched: isMatched,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // New Game: Fill in the Blank
  Widget _buildFillInTheBlankGame(String letter) {
    final word = alphabetData[letter]?['word'] ?? '';
    final blankIndex = Random().nextInt(word.length);
    final displayedWord = word.split('');

    final correctLetter = word[blankIndex];
    final alphabet = List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));
    alphabet.remove(correctLetter);
    alphabet.shuffle(Random());
    final incorrectLetters =
        alphabet.sublist(0, 2).map((e) => e.toUpperCase()).toList();
    final options = [correctLetter.toUpperCase(), ...incorrectLetters]
      ..shuffle(Random());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: displayedWord.asMap().entries.map((entry) {
              final index = entry.key;
              final displayChar = entry.value;

              if (index == blankIndex) {
                return const SizedBox(
                  width: 50,
                  height: 50,
                );
              } else {
                return SizedBox(
                  // Adjust the container size here.
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    _getLetterImagePath(displayChar),
                    fit: BoxFit.contain,
                  ),
                );
              }
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: options.map((option) {
              return _buildImageButton(option, () {
                if (option == correctLetter.toUpperCase()) {
                  setState(() {
                    _isRoundCompleted = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correct!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Try again!')),
                  );
                }
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  // New Game: Find the Letter
  Widget _buildFindTheLetterGame(String letter) {
    final alphabet = List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));
    alphabet.remove(letter);
    alphabet.shuffle(Random());
    final incorrectLetters = alphabet.sublist(0, 8);
    final options = [letter, ...incorrectLetters]..shuffle(Random());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Find the letter: '$letter'",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                return _buildImageButton(option, () {
                  if (option == letter) {
                    setState(() {
                      _isRoundCompleted = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Correct!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Try again!')),
                    );
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // New Game: Alphabet Puzzle
  Widget _buildAlphabetPuzzleGame(String letter) {
    final word = alphabetData[letter]?['word'] ?? '';
    final correctLetters = word.split('');
    final shuffledLetters = List.from(correctLetters)..shuffle(Random());

    List<String> typedLetters = [];

    void onLetterTapped(String tappedLetter) {
      if (typedLetters.length < correctLetters.length) {
        setState(() {
          typedLetters.add(tappedLetter);
        });
        if (typedLetters.join('') == word) {
          setState(() {
            _isRoundCompleted = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Correct!')),
          );
        }
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Arrange the letters to spell: '$word'",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: typedLetters.map((typedLetter) {
              return SizedBox(
                width: 80,
                height: 80,
                child: Image.asset(_getLetterImagePath(typedLetter)),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: shuffledLetters.map((shuffledLetter) {
              return _buildImageButton(
                  shuffledLetter, () => onLetterTapped(shuffledLetter));
            }).toList(),
          ),
        ],
      ),
    );
  }

  // New Game: Letter Sound Pop
  Widget _buildLetterSoundPopGame(String letter) {
    final sound = alphabetData[letter]?['sound'] ?? '';
    final alphabet = List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));
    alphabet.remove(letter);
    alphabet.shuffle(Random());
    final incorrectLetters = alphabet.sublist(0, 2);
    final options = [letter, ...incorrectLetters]..shuffle(Random());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 50),
            onPressed: () {
              AudioService().playClickSound();
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: options.map((option) {
              return _buildImageButton(option, () {
                if (option == letter) {
                  setState(() {
                    _isRoundCompleted = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correct!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Try again!')),
                  );
                }
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterButton(String letter, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          letter,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }

  String _getLetterImagePath(String letter) {
    if (letter.toLowerCase() == letter) {
      return 'assets/images/alphabet/lower_${letter.toLowerCase()}.png';
    } else {
      return 'assets/images/alphabet/${letter.toUpperCase()}.png';
    }
  }

  Widget _buildImageButton(String letter, VoidCallback onTap,
      {bool isSelected = false, bool isMatched = false, double size = 100}) {
    Color buttonColor;
    if (isSelected) {
      buttonColor = Colors.yellow.withOpacity(0.5);
    } else if (isMatched) {
      buttonColor = Colors.green.withOpacity(0.5);
    } else {
      buttonColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // The width and height of this container can be adjusted to change the image size.
        width: size,
        height: size,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isMatched ? Colors.green : Colors.grey,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            _getLetterImagePath(letter),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
