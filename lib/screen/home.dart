import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:t178/screen/camera_options.dart';
import 'package:t178/screen/map.dart';
import 'package:t178/constants.dart';
import 'package:t178/screen/send.dart';
import 'package:t178/screen/pages/video_preview.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, TickerProviderStateMixin{
  DateTime today = DateTime.now();
  DateTime begin = DateTime(2023,11,27);
  late PageController _pageController;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  // camera variables
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  bool isPauseRecording = false;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  bool turnOnFlash = false;
  bool frontCamera = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  @override
  void initState(){
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black87
    ));
    // Register this widget as an observer to listen for lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  // handle AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    int numberOfLoveDays = today.difference(begin).inDays;
    return Scaffold(
      backgroundColor:Colors.black87,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        scrollDirection: Axis.vertical,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    clipBehavior: Clip.hardEdge,
                    child: Material(
                      color: Colors.white38,
                      child: IconButton(
                          onPressed: (){
                            if(kDebugMode){
                              debugPrint("On tap");
                            }
                          },
                          icon:Image.asset("images/profile-user.png",color: Colors.white,height: 35,width: 35,)
                      ),
                    ),
                  ),
                  const SizedBox(width:80,),
                  Text("$numberOfLoveDays days",
                    style: const TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.white,fontFamily:"CupertinoSystemDisplay" ),),
                  const SizedBox(width:80,),
                  ClipOval(
                    clipBehavior: Clip.hardEdge,
                    child: Material(
                      color: Colors.white38,
                      child: IconButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const MapScreen()));
                          },
                          icon:const Icon(Icons.location_on,color: Colors.white,size: 30,)
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50,),
              _cameraPreviewWidget(),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        turnOnFlash = !turnOnFlash;
                      });
                      if(controller != null && turnOnFlash){
                        onSetFlashModeButtonPressed(FlashMode.always);
                      }else if(controller != null && !turnOnFlash){
                        onSetFlashModeButtonPressed(FlashMode.off);
                      }
                    },
                    onDoubleTap: controller != null ? ()=>onSetFlashModeButtonPressed(FlashMode.auto):null,
                    onLongPress: controller != null ? ()=>onSetFlashModeButtonPressed(FlashMode.torch):null,
                    child: Image.asset(turnOnFlash?"images/turn-off.png":"images/flash.png",height: 50,width: 50,),
                  ),
                  const SizedBox(width: 35,),
                  GestureDetector(
                    onTap: () {onTakePictureButtonPressed();},
                    onLongPressStart: (details) {onVideoRecordButtonPressed();},
                    onLongPressEnd: (details) {onStopButtonPressed();},
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Inner white color
                        border: Border.all(
                          color: Colors.black, // Black border
                          width: 5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.lightBlue, // Outer yellow border
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 35,),
                  IconButton(
                    icon: Image.asset("images/camera.png",height:50,width: 50,),
                    onPressed: (){
                      if(cameras.isEmpty){
                        showInSnackBar("No camera found");
                      }else{
                        setState(() {
                          frontCamera = !frontCamera;
                        });
                        if(controller != null){
                          if(frontCamera){
                            controller!.setDescription(cameras[1]);
                          }else {
                            controller!.setDescription(cameras[0]);
                          }
                        }else{
                          _initializeCameraController(cameras[0]);
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              const Center(child: Icon(Icons.keyboard_arrow_up_rounded,color: Colors.white,size: 50,)),
              const Text("Scroll to see more",style:TextStyle(fontSize:18,color: Colors.white,fontWeight: FontWeight.bold),),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),
              _thumbnailWidget(),
              const SizedBox(height: 50,),
            ],
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
    });
    if (page != 0) {
      controller?.dispose();
      setState(() {
        controller = null;
      });
    } else {
      if(cameras.isNotEmpty){
        _initializeCameraController(cameras[0]);
      }
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _logError(String code, String? message) {
    debugPrint('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) {
          showInSnackBar('Picture saved to ${file.path}');
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Send(mediaPath: imageFile!.path,controller: videoController,)));
        }
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {
          isPauseRecording = false;
        });
      }
      if (file != null) {
        videoFile = file;
        _startVideoPlayer();
        showInSnackBar('Recording video successfully');
      }
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
      setState(() {
        isPauseRecording = true;
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(videoFile!.path))
        : VideoPlayerController.file(File(videoFile!.path));

    videoPlayerListener = () {
      if (videoController != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {});
        }
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.initialize();
    await vController.pause();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.pause();
    Navigator.push(context,MaterialPageRoute(builder: (context)=>Send(mediaPath: videoFile!.path,controller: vController,)));
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
        // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
        // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
          break;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;
    return Container(
        width: width(context)-20,
        height: height(context)*0.5,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color:
            controller != null && controller!.value.isRecordingVideo
                ? Colors.redAccent
                : Colors.grey,
            width: 5,
          ),
        ),
        child:(cameraController == null || !cameraController.value.isInitialized)?
        Center(
          child: IconButton(
            icon:const Icon(Icons.add,size:32,color: Colors.white,),
            onPressed: (){
              if(cameras.isNotEmpty){
                _initializeCameraController(cameras[0]);
              }
            },
          ),
        )
            :Listener(
          onPointerDown: (_) => _pointers++,
          onPointerUp: (_) => _pointers--,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: AspectRatio(
              aspectRatio: 4/3,
              child: CameraPreview(
                controller!,
                child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _handleScaleStart,
                        onScaleUpdate: _handleScaleUpdate,
                        onTapDown: (TapDownDetails details) =>
                            onViewFinderTap(details, constraints),
                      );
                    }),
              ),
            ),
          ),
        )
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    if (localVideoController == null && imageFile == null) {
      return Container();
    } else {
      return Container(
        width: width(context)-20,
        height: height(context)*0.5,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.grey,
            width: 5,
          ),
        ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: (localVideoController == null)?kIsWeb
                ? Image.network(imageFile!.path)
                : Image.file(File(imageFile!.path),
              height: MediaQuery.sizeOf(context).height*0.5,
              width: MediaQuery.sizeOf(context).width-20,
              fit: BoxFit.cover,
            ): VideoPreview().videoPreview(localVideoController),
          )
      );
    }
  }
}