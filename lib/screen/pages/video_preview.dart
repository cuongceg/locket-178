import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class VideoPreview{
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  Widget videoPreview(VideoPlayerController controller){
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: GestureDetector(
        onTap: () {
          controller.value.isPlaying ? controller.pause() : controller.play();
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(controller),
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<double>(
                initialValue: controller.value.playbackSpeed,
                onSelected: (double speed) {
                  controller.setPlaybackSpeed(speed);
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem<double>>[
                    for (final double speed in _examplePlaybackRates)
                      PopupMenuItem<double>(
                        value: speed,
                        child: Text('${speed}x'),
                      )
                  ];
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    // Using less vertical padding as the text is also longer
                    // horizontally, so it feels like it would need more spacing
                    // horizontally (matching the aspect ratio of the video).
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text('${controller.value.playbackSpeed}x',style: const TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            VideoProgressIndicator(controller, allowScrubbing: true,colors: const VideoProgressColors(
              playedColor: Colors.blue,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black,
            ),),
          ],
        ),
      ),
    );
  }
}