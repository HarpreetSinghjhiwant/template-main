import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AudioCropperPage extends StatefulWidget {
  final String url;
  final String name;
  var setAudio;   


  AudioCropperPage({super.key, required this.url, required this.name,required this.setAudio});

  @override
  State<AudioCropperPage> createState() => _AudioCropperPageState();
}

class _AudioCropperPageState extends State<AudioCropperPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<double> _currentTimeNotifier = ValueNotifier(0);
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isPlaying = false;
  double currentTime = 0;
  double totalDuration = 1;
  double start = 0;
  double end = 300;
  bool isDraggingStart = false;
  bool isDraggingEnd = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _startController.text = _formatTime(start);
    _endController.text = _formatTime(end);
  }

  void _initAudioPlayer() async {
    _audioPlayer.onPositionChanged.listen((Duration p) {
      _currentTimeNotifier.value = p.inMilliseconds.toDouble() / 1000;
      currentTime = _currentTimeNotifier.value;

      if (_currentTimeNotifier.value >= end) {
        _audioPlayer.pause();
        setState(() => isPlaying = false);
        _audioPlayer.seek(Duration(milliseconds: (start * 1000).toInt()));
      }

      // Auto-scroll to keep playhead visible
      _scrollToPlayhead();
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        totalDuration = d.inMilliseconds.toDouble() / 1000;
        end = min(totalDuration, end);
        _endController.text = _formatTime(end);
      });
    });
  }

  void _scrollToPlayhead() {
    if (!_scrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth * 2; // Adjust based on your zoom level
    final playheadPosition = (currentTime / totalDuration) * contentWidth;

    if (playheadPosition < _scrollController.offset ||
        playheadPosition > _scrollController.offset + screenWidth) {
      _scrollController.animateTo(
        playheadPosition - (screenWidth / 2),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateTimeFromText(bool isStart) {
    try {
      final text = isStart ? _startController.text : _endController.text;
      final timeValue = double.parse(text);

      setState(() {
        if (isStart) {
          start = timeValue.clamp(0, end - 1);
          _startController.text = _formatTime(start);
          if (isPlaying) {
            _audioPlayer.seek(Duration(milliseconds: (start * 1000).toInt()));
          }
        } else {
          end = timeValue.clamp(start + 1, totalDuration);
          _endController.text = _formatTime(end);
        }
      });
    } catch (e) {
      if (isStart) {
        _startController.text = _formatTime(start);
      } else {
        _endController.text = _formatTime(end);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _currentTimeNotifier.dispose();
    _startController.dispose();
    _endController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _playPauseMusic() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      final fileUri = Uri.file(widget.url).toString();
      await _audioPlayer.play(DeviceFileSource(fileUri));
      await _audioPlayer.seek(Duration(milliseconds: (start * 1000).toInt()));
    }
    setState(() => isPlaying = !isPlaying);
  }

  String _formatTime(double time) {
    final seconds = time.toInt();
    return seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Song Name: ${widget.name}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWaveformDisplay(),
                      const SizedBox(height: 10),
                      _buildTimeLabels(),
                      const SizedBox(height: 30),
                      _buildTimeControls(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatTime(start),
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            _formatTime(end),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformDisplay() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 2,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width * 2, 50),
                painter: WaveformPainter(
                  currentTime: _currentTimeNotifier.value,
                  totalDuration: totalDuration,
                  start: start,
                  end: end,
                ),
              ),
              _buildCropHandles(),
              ValueListenableBuilder<double>(
                valueListenable: _currentTimeNotifier,
                builder: (context, currentTime, _) {
                  return Positioned(
                    left: (currentTime / totalDuration) *
                        MediaQuery.of(context).size.width *
                        2,
                    child: Container(
                      width: 2,
                      height: 50,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropHandles() {
    return Stack(
      children: [
        Positioned(
          left: (start / totalDuration) * MediaQuery.of(context).size.width * 2,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                final newStart = start +
                    (details.delta.dx /
                            (MediaQuery.of(context).size.width * 2)) *
                        totalDuration;
                start = newStart.clamp(0, end - 1);
                _startController.text = _formatTime(start);
              });
            },
            child: Container(
              width: 5,
              height: 50,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          left: (end / totalDuration) * MediaQuery.of(context).size.width * 2 ,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                final newEnd = end +
                    (details.delta.dx /
                            (MediaQuery.of(context).size.width * 2)) *
                        totalDuration;
                end = newEnd.clamp(start + 1, totalDuration);
                _endController.text = _formatTime(end);
              });
            },
            child: Container(
              width: 5,
              height: 50,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeInput('Start', _startController, true),
        _buildTimeInput('End', _endController, false),
        _buildTimeDisplay('Duration', _formatTime(end - start)),
        _buildPlaybackControls(),
      ],
    );
  }

  Widget _buildTimeInput(
      String label, TextEditingController controller, bool isStart) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _updateTimeFromText(isStart),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _playPauseMusic,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Row(
              children: [
                Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40,
                  color: Colors.black,
                ),
                Text(!isPlaying ? 'Play' : 'Pause'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 14,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            fixedSize: MaterialStateProperty.all(Size(250, 45)),
            maximumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 3, 45)),
            side: MaterialStateProperty.all(
              BorderSide(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, color: Colors.grey[800]),
              Text('Back',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Times New Roman',
                  )),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
            fixedSize: MaterialStateProperty.all(Size(250, 45)),
            maximumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 3, 45)),
          ),
          child: Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double currentTime;
  final double totalDuration;
  final double start;
  final double end;

  WaveformPainter({
    required this.currentTime,
    required this.totalDuration,
    required this.start,
    required this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = Colors.blue[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final selectedPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final playheadPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final activePath = Path();
    final selectedPath = Path();

    for (var i = 0; i < size.width; i++) {
      final x = i.toDouble();
      final progress = i / size.width;
      final timeAtPoint = progress * totalDuration;
      final amplitude = _generateRandomAmplitude(timeAtPoint);
      final y = size.height / 2 + 30 * amplitude * sin(progress * 50);

      if (i == 0) {
        path.moveTo(x, y);
        activePath.moveTo(x, y);
        selectedPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        activePath.lineTo(x, y);
        selectedPath.lineTo(x, y);
      }
    }

    // Draw inactive waveform
    canvas.drawPath(path, paint);

    // Draw active region
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        (start / totalDuration) * size.width,
        0,
        (end / totalDuration) * size.width,
        size.height,
      ),
    );
    canvas.drawPath(selectedPath, selectedPaint);
    canvas.restore();

    // Draw current position line
    final playheadX = (currentTime / totalDuration) * size.width;
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      playheadPaint,
    );
  }

  double _generateRandomAmplitude(double seed) {
    final randomValue = (sin(seed * 5) * 0.5 + 0.5) * 0.8 + 0.2;
    return min(1.0, max(0.2, randomValue));
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      currentTime != oldDelegate.currentTime ||
      start != oldDelegate.start ||
      end != oldDelegate.end;
}
