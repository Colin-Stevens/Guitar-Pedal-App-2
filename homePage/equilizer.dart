import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/models/atribute_model.dart';
//import 'package:charts_flutter/flutter.dart' as charts;

class EquilizerWidget extends StatelessWidget {
  const EquilizerWidget({super.key});
  static const maxValue = (2 ^ 32) - 1;
  static const maxPixel = 180.0;
  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of<AppBloc>(context);

    List<Widget> eqVisual = [];

    for (double value
        in bloc.appRepository.connectionManager.activeDevice.eqData) {
      eqVisual.add(Expanded(
          child:Container(
                height: value,
                color: const Color.fromARGB(255, 228, 187, 111),
              )));
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("We got this data: \n "),
          SizedBox(
              height: 200,
              child:
                  Stack(alignment: AlignmentDirectional.bottomStart, children: [
                Container(
                  color: const Color.fromARGB(255, 84, 78, 77),
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: eqVisual)
              ]))
        ]);
  }
}

// Widget _buildChart() {
//   List<double> data = [1, 2, 3, 4, 5, 6];
//   return Container(
//       height: 300,
//       child: ShaderMask(
//         shaderCallback: (Rect bounds) {
//           return const LinearGradient(
//             begin: Alignment.bottomCenter,
//             end: Alignment.topCenter,
//             colors: [Color(0xFF51DE93), Color(0xFFFFB540), Color(0xFFFA4169)],
//             stops: [
//               0.0,
//               0.5,
//               1.0,
//             ],
//           ).createShader(bounds);
//         },
//         blendMode: BlendMode.srcATop,
//         child: charts.BarChart(
//           _createSampleData(),
//           animate: true,
//           primaryMeasureAxis: const charts.NumericAxisSpec(
//               renderSpec: charts.NoneRenderSpec(), showAxisLine: false),
//           domainAxis: const charts.OrdinalAxisSpec(
//               showAxisLine: false, renderSpec: const charts.NoneRenderSpec()),
//           layoutConfig: charts.LayoutConfig(
//               leftMarginSpec: charts.MarginSpec.fixedPixel(0),
//               topMarginSpec: charts.MarginSpec.fixedPixel(0),
//               rightMarginSpec: charts.MarginSpec.fixedPixel(0),
//               bottomMarginSpec: charts.MarginSpec.fixedPixel(0)),
//           defaultRenderer: charts.BarRendererConfig(
//               cornerStrategy: const charts.ConstCornerStrategy(30)),
//         ),
//       ));
// }

// /// Sample ordinal data type.
// class DataPoint {
//   final String xVal;
//   final double yVal;

//   DataPoint(this.xVal, this.yVal);
// }

// /// Create one series with sample hard coded data.
// List<charts.Series<DataPoint, String>> _createSampleData() {
//   final data = [
//     DataPoint('1', 1),
//     DataPoint('2', 3),
//     DataPoint('3', 2),
//   ];

//   return [
//     charts.Series<DataPoint, String>(
//       id: 'EQ_DATA',
//       domainFn: (DataPoint data, _) => data.xVal,
//       measureFn: (DataPoint data, _) => data.yVal,
//       data: data,
//     )
//   ];
// }
