import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:instaclone_app/firebase_options.dart';
import 'package:instaclone_app/splesh_screen/instaclone_splesh.dart';
import 'controller/comment_controller/comment_servise.dart';
import 'controller/login_and_registesion_service/registesion_and_login_controller.dart';
import 'controller/videeo_service/videos_service.dart';
 void main()async{
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
   Get.put(FllowingController());
   Get.put(VideoUploadController());
   Get.put(AuthService());
   runApp(Myapp());
 }
class Myapp extends StatefulWidget {
  const Myapp({super.key});

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home:InstaSplaceScreen() ,
    );
  }
}
