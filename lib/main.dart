import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(MoodMateApp());

class MoodMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoodMate',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.lightGreen.shade100,
      ),
      home: MoodSelectionScreen(),
    );
  }
}

class MoodSelectionScreen extends StatefulWidget {
  @override
  _MoodSelectionScreenState createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  String? _selectedMood;

  final Map<String, String> _moodQuotes = {
    "Happy": "The most important thing is to enjoy your life-to be happy-it's all that matters.",
    "Sad": "Happiness can be found even in the darkest of times if one remembers to turn on the light.",
    "Angry": "For every minute you are angry you lose sixty seconds of happiness.",
    "Relaxed": "Take it easy, life’s too short to stress.",
    "Excited": "Excitement fuels the soul.",
    "Confused": "Never be limited by other people's limited imaginations.",
    "Grateful": "When one door of happiness closes, another opens.",
    "Lonely": "Yes, I am going through the hardest phase of life, that’s loneliness.",
    "Motivated": "Keep your face always toward the sunshine, and shadows will fall behind you.",
    "Bored": "You don't burn out from going too fast. You burn out from going too slow and getting bored.",
  };

  final Map<String, String> _moodEmojis = {
    "Happy": "😊",
    "Sad": "😢",
    "Angry": "😡",
    "Relaxed": "😌",
    "Excited": "🤩",
    "Confused": "😕",
    "Grateful": "🙏",
    "Lonely": "😔",
    "Motivated": "💪",
    "Bored": "😐",
  };

  final Map<String, String> _moodMusic = {
    "Happy": 'assets/happy.mp3',
    "Sad": 'assets/sad.mp3',
    "Angry": 'assets/angry.mp3',
    "Relaxed": 'assets/relaxed.mp3',
    "Excited": 'assets/excited.mp3',
    "Confused": 'assets/confused.mp3',
    "Grateful": 'assets/grateful.mp3',
    "Lonely": 'assets/lonely.mp3',
    "Motivated": 'assets/motivated.mp3',
    "Bored": 'assets/bored.mp3',
  };

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadMoodMusic() async {
    _playlist.clear();
    _moodMusic.values.forEach((path) {
      _playlist.add(AudioSource.asset(path));
    });
    await _player.setAudioSource(_playlist);
  }

  Future<void> _playMoodMusic() async {
    try {
      _player.play();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'MoodMate',
          style: TextStyle(
            color: Color(0xFFFAF9F6),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.green.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Welcome to MoodMate",
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Select Your Mood:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              hint: const Text("Choose a mood"),
              value: _selectedMood,
              items: _moodQuotes.keys.map((String mood) {
                return DropdownMenuItem<String>(
                  value: mood,
                  child: Text(mood),
                );
              }).toList(),
              onChanged: (String? newMood) {
                setState(() {
                  _selectedMood = newMood;
                  _loadMoodMusic();
                });
              },
            ),
            const SizedBox(height: 30),
            if (_selectedMood != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      _moodEmojis[_selectedMood!]!,
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _moodQuotes[_selectedMood!]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _audioPlayerControls(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _audioPlayerControls() {
    return Column(
      children: [
        StreamBuilder<Duration?>(
          stream: _player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final total = _player.duration ?? Duration.zero;
            return Slider(
              min: 0,
              max: total.inSeconds.toDouble(),
              value: position.inSeconds.toDouble().clamp(0, total.inSeconds.toDouble()),
              onChanged: (value) {
                _player.seek(Duration(seconds: value.toInt()));
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous),
              onPressed: () {
                if (_player.hasPrevious) _player.seekToPrevious();
              },
            ),
            StreamBuilder<bool>(
              stream: _player.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (isPlaying) {
                      _player.pause();
                    } else {
                      _playMoodMusic();
                    }
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.skip_next),
              onPressed: () {
                if (_player.hasNext) _player.seekToNext();
              },
            ),
          ],
        ),
      ],
    );
  }
}
