import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/bloc/app_repository.dart';
import 'package:guitar_pedal_app/connectionSettings/connectionManager.dart';
import 'package:guitar_pedal_app/loadingScreen/loadingScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'homePage/homePage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppBloc(),
        child: BlocBuilder<AppBloc, AppState>(
            builder: (context, state) => HomePage()));
  }
}

class ScreenManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      if (state is DisplayLoadingScreen) {
        return const LoadingScreen();
      } else if (state is DisplayPedalBoardGrid) {
        return HomePage();
      } else {
        return HomePage();
      }
    });
  }
}
