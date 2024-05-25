import 'package:keuangan/components/item_list_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EndDrawer extends StatefulWidget {
  const EndDrawer({Key? key}) : super(key: key);

  @override
  State<EndDrawer> createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/vlead.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: storage.readAll(),
                builder: (context, AsyncSnapshot snapshot) {
                  final data = snapshot.data;
                  return Column(
                    children: <Widget>[
                      const SizedBox(height: 32),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade800,
                        radius: 35,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        data['username'],
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      (data['phone'] != null && data['phone'] != "")
                          ? const SizedBox(
                              height: 4,
                            )
                          : const SizedBox(),
                      (data['phone'] != null && data['phone'] != "")
                          ? Text(
                              data['phone'],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 17,
                              ),
                            )
                          : const SizedBox(),
                      (data['email'] != null && data['email'] != "")
                          ? const SizedBox(
                              height: 4,
                            )
                          : const SizedBox(),
                      (data['email'] != null && data['email'] != "")
                          ? Text(
                              data['email'],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 32,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // ItemListProfile(
                            //   icon: Icons.password,
                            //   text: "Ganti password",
                            //   onTap: () {
                            //     Navigator.push(
                            //       context,
                            //       PageTransition(
                            //         type: PageTransitionType.fade,
                            //         child: const ChangePasswordPage(),
                            //       ),
                            //     );
                            //   },
                            // ),
                            // const Divider(
                            //   height: 1,
                            // ),
                            // ItemListProfile(
                            //   icon: Icons.person,
                            //   text: "Edit Profil",
                            //   onTap: () {
                            //     Navigator.push(
                            //       context,
                            //       PageTransition(
                            //         type: PageTransitionType.fade,
                            //         child: const ProfilPage(),
                            //       ),
                            //     );
                            //   },
                            // ),
                            // const Divider(
                            //   height: 1,
                            // ),
                            ItemListProfile(
                              icon: Icons.theater_comedy,
                              text: "Tema (Terang)",
                            ),
                            // const Divider(
                            //   height: 1,
                            // ),
                            // ItemListProfile(
                            //   icon: Icons.logout,
                            //   text: "Logout",
                            //   color: Colors.red,
                            //   fontWeight: FontWeight.bold,
                            //   onTap: () async {
                            //     await storage.deleteAll();
                            //     Timer(
                            //       const Duration(milliseconds: 2000),
                            //       () => g.Get.offAll(
                            //         () => const SplashPage(),
                            //       ),
                            //     );
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
