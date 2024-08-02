// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// Future<void> _initializeCameraController(
//     CameraDescription cameraDescription) async {
//   final CameraController cameraController = CameraController(
//     cameraDescription,
//     kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
//     enableAudio: enableAudio,
//     imageFormatGroup: ImageFormatGroup.jpeg,
//   );
//
//   controller = cameraController;
//
//   // If the controller is updated then update the UI.
//   cameraController.addListener(() {
//     if (mounted) {
//       setState(() {});
//     }
//     if (cameraController.value.hasError) {
//       showInSnackBar(
//           'Camera error ${cameraController.value.errorDescription}');
//     }
//   });
//
//   try {
//     await cameraController.initialize();
//     await Future.wait(<Future<Object?>>[
//       // The exposure mode is currently not supported on the web.
//       ...!kIsWeb
//           ? <Future<Object?>>[
//         cameraController.getMinExposureOffset().then(
//                 (double value) => _minAvailableExposureOffset = value),
//         cameraController
//             .getMaxExposureOffset()
//             .then((double value) => _maxAvailableExposureOffset = value)
//       ]
//           : <Future<Object?>>[],
//       cameraController
//           .getMaxZoomLevel()
//           .then((double value) => _maxAvailableZoom = value),
//       cameraController
//           .getMinZoomLevel()
//           .then((double value) => _minAvailableZoom = value),
//     ]);
//   } on CameraException catch (e) {
//     switch (e.code) {
//       case 'CameraAccessDenied':
//         showInSnackBar('You have denied camera access.');
//       case 'CameraAccessDeniedWithoutPrompt':
//       // iOS only
//         showInSnackBar('Please go to Settings app to enable camera access.');
//       case 'CameraAccessRestricted':
//       // iOS only
//         showInSnackBar('Camera access is restricted.');
//       case 'AudioAccessDenied':
//         showInSnackBar('You have denied audio access.');
//       case 'AudioAccessDeniedWithoutPrompt':
//       // iOS only
//         showInSnackBar('Please go to Settings app to enable audio access.');
//       case 'AudioAccessRestricted':
//       // iOS only
//         showInSnackBar('Audio access is restricted.');
//       default:
//         _showCameraException(e);
//         break;
//     }
//   }
//
//   if (mounted) {
//     setState(() {});
//   }
// }
//
// void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
//   if (controller == null) {
//     return;
//   }
//
//   final CameraController cameraController = controller!;
//
//   final Offset offset = Offset(
//     details.localPosition.dx / constraints.maxWidth,
//     details.localPosition.dy / constraints.maxHeight,
//   );
//   cameraController.setExposurePoint(offset);
//   cameraController.setFocusPoint(offset);
// }
//
// Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
//   if (controller != null) {
//     return controller!.setDescription(cameraDescription);
//   } else {
//     return _initializeCameraController(cameraDescription);
//   }
// }
//
// void _showCameraException(CameraException e,BuildContext context) {
//   _logError(e.code, e.description);
//   showInSnackBar('Error: ${e.code}\n${e.description}',context);
// }
//
// void _logError(String code, String? message) {
//   // ignore: avoid_print
//   debugPrint('Error: $code${message == null ? '' : '\nError Message: $message'}');
// }
//
// void showInSnackBar(String message,BuildContext context){
//   void showInSnackBar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }
// }