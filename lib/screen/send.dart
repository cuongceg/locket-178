import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:t178/screen/pages/color_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t178/constants.dart';
import 'package:t178/screen/pages/video_preview.dart';
import 'package:video_player/video_player.dart';

class Send extends StatefulWidget {
  const Send({super.key,required this.mediaPath,required this.controller});
  final String? mediaPath;
  final VideoPlayerController? controller;
  @override
  State<Send> createState() => _SendState();
}

class _SendState extends State<Send> {
  int currentFilterIndex=0;
  final List<List<double>> filters = [ORIGINAL_MATRIX,BRIGHTNESS_MATRIX,CONTRAST_MATRIX,SATURATION_MATRIX,GREYSCALE_MATRIX,SEPIA_MATRIX,VINTAGE_MATRIX,SWEET_MATRIX];
  final List<String> filterNames = ["Original","Brightness","Contrast","Saturation","Sepia","Greyscale","Vintage","Sweet"];
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black87
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Send',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
        centerTitle: true,
      ),
      backgroundColor: Colors.black87,
      body: SizedBox(
        width: width(context),
        height: height(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30,),
            (widget.controller == null && widget.mediaPath == null)?const SizedBox():Container(
                width: width(context)-20,
                height: height(context)*0.5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.grey,
                    width: 5.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: (widget.controller == null)?(
                  ColorFiltered(
                    colorFilter: ColorFilter.matrix(filters[currentFilterIndex]),
                    child: kIsWeb
                        ? Image.network(widget.mediaPath!)
                        : Image.file(File(widget.mediaPath!),
                      height: MediaQuery.sizeOf(context).height*0.5,
                      width: MediaQuery.sizeOf(context).width-20,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,)
                  )
                  ): VideoPreview().videoPreview(widget.controller!),
                )
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 5,),
                IconButton(
                    onPressed:(){
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_outlined,color: Colors.white,size: 55,)
                ),
                const SizedBox(width: 30,),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    shape: BoxShape.circle,
                    border: Border.all(width: 3)
                  ),
                  child: Transform.rotate(
                    angle: 9*pi/5,
                    child: IconButton(
                        onPressed:(){
                          debugPrint("On tap");
                        },
                        icon: const Icon(Icons.send_outlined,color: Colors.white,size: 50,),
                    ),
                  ),
                ),
                const SizedBox(width: 30,),
                IconButton(
                    onPressed:(){
                      debugPrint("On tap");
                    },
                    icon: const Icon(Icons.file_download_outlined,color: Colors.white,size: 55,),
                ),
              ],
            ),
            SizedBox(
              width: width(context),
              height: 150,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          currentFilterIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.matrix(filters[index]),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: FileImage(File(widget.mediaPath!)),
                              )
                            ),
                            const SizedBox(height: 10,),
                            Text(filterNames[index],style: const TextStyle(color: Colors.white,fontSize: 15),)
                          ],
                        ),
                      ),
                    );
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
}
