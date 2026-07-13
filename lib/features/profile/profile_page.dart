import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';
import 'package:flutter_go_chat/core/services/database/db_service.dart';
import 'package:flutter_go_chat/core/widgets/nova_design/nova_design.dart';
import 'package:flutter_go_chat/app/theme/theme_extension.dart';
import 'package:flutter_go_chat/features/settings/widgets/divider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = DatabaseService();
  User? user;

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {
    user = await _db.getUser(
      AppScope.read(context).authController.currentUserId ?? 1,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null)
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    final g = AppScope.of(context);
    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NovaContainer(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: colors.surfaceTransparent,
                            minRadius: 15,
                            maxRadius: 30,
                            child: Image.asset("assets/images/photo.jpg"),
                          ),
                          Text(
                            "${user!.displayName} ${user!.surname ?? "___"}",
                          ),
                          Text("@${user!.username}"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const NovaDivider(),

                    const SizedBox(height: 30),

                    NovaContainer(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text("ID: ${user!.id}"),
                          Text(
                            "Registered at: "
                            "${user!.createdAt.day}."
                            "${user!.createdAt.month}."
                            "${user!.createdAt.year}, "
                            "${user!.createdAt.hour}:"
                            "${user!.createdAt.minute}",
                          ),
                          const Text("Last seen at: Emir gde norm database"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    NovaContainer(
                      alignment: Alignment.center,
                      child: Column(
                        children: [Text(user!.bio ?? "no bio yet")],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NovaContainer(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Text("Statistics"),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: NovaContainer(
                                  child: const SizedBox(width: 40, height: 40),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: NovaContainer(
                                  child: const SizedBox(width: 40, height: 40),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: NovaContainer(
                                  child: const SizedBox(width: 40, height: 40),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: NovaContainer(
                                  child: const SizedBox(width: 40, height: 40),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: NovaContainer(
                                  child: const SizedBox(width: 40, height: 40),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: NovaContainer(
                                  child: const SizedBox(width: 40, height: 40),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const NovaDivider(),

                    const SizedBox(height: 30),

                    NovaContainer(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Text("Media"),
                          const SizedBox(height: 100, width: 100),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    NovaContainer(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Text("Actions"),
                          const SizedBox(height: 100, width: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return Scaffold(
    //   backgroundColor: Colors.transparent,
    //   body: SafeArea(
    //     child: Center(
    //       child: SingleChildScrollView(
    //         padding: const EdgeInsets.all(20),
    //         child: Row(
    //           children: [
    //             Column(
    //               mainAxisAlignment: .start,
    //               crossAxisAlignment: .start,
    //               spacing: 30,
    //               children: [
    //                 NovaContainer(
    //                   alignment: .center,
    //                   child: SizedBox(
    //                     width: double.infinity,
    //                     child: Column(
    //                     children: [
    //                       CircleAvatar(
    //                         backgroundColor: colors.surfaceTransparent,
    //                         minRadius: 15,
    //                         maxRadius: 30,
    //                         child: Image.asset("assets/images/photo.jpg"),
    //                       ),
    //                       Text(
    //                         "${user!.displayName} ${user!.surname ?? "___"}",
    //                       ),
    //                       Text("@${user!.username}"),
    //                     ],
    //                   ),
    //                 )),

    //                 const NovaDivider(),

    //                 NovaContainer(
    //                   alignment: .center,
    //                   child: Column(
    //                     children: [
    //                       Text("ID: ${user!.id}"),
    //                       Text(
    //                         "Registered at: ${user!.createdAt.day}.${user!.createdAt.month}.${user!.createdAt.year}, ${user!.createdAt.hour}:${user!.createdAt.minute}",
    //                       ),
    //                       Text("Last seen at: Emir gde norm database"),
    //                     ],
    //                   ),
    //                 ),

    //                 NovaContainer(
    //                   alignment: .center,
    //                   child: Column(
    //                     children: [Text("${user!.bio ?? "no bio yet"}")],
    //                   ),
    //                 ),
    //               ],
    //             ),

    //             const NovaDivider(),

    //             Column(
    //               mainAxisAlignment: .start,
    //               crossAxisAlignment: .start,
    //               spacing: 30,
    //               children: [
    //                 const SizedBox(height: 200),
    //                 NovaContainer(
    //                   alignment: .center,
    //                   child: Column(
    //                     children: [
    //                       Text("Statistics"),
    //                       Row(
    //                         children: [
    //                           NovaContainer(child: SizedBox(width: 40, height: 40)),
    //                           NovaContainer(child: SizedBox(width: 40, height: 40)),
    //                           NovaContainer(child: SizedBox(width: 40, height: 40)),
    //                         ],
    //                       ),

    //                       Row(
    //                         children: [
    //                           NovaContainer(child: SizedBox(width: 40, height: 40)),
    //                           NovaContainer(child: SizedBox(width: 40, height: 40)),
    //                           NovaContainer(child: SizedBox(width: 40, height: 40)),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                 ),

    //                 const NovaDivider(),

    //                 NovaContainer(
    //                   alignment: .center,
    //                   child: Column(
    //                     children: [Text("Media"), const SizedBox(height: 100, width: 100)],
    //                   ),
    //                 ),

    //                 NovaContainer(
    //                   alignment: .center,
    //                   child: Column(
    //                     children: [
    //                       Text("Actions"),
    //                       const SizedBox(height: 100, width: 40),
    //                     ],
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
