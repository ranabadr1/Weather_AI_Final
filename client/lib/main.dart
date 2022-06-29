import 'package:flutter/material.dart';
import 'package:weather_app/theme_class.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeClass.lightTheme,
      darkTheme: ThemeClass.darkTheme,
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    getHourlyWeather();
    getDailyWeather();
    getWeather();
    getHoursPrediction();
    getDaysPrediction();
  }

  String cityName = "Beirut"; //city name
  num currTemp = 30.0;
  num seonsorTemp = 28.0; // current temperature
  double maxTemp = 30.0; // today max temperature
  double minTemp = 2.0; // tod9ay min temperature
  List<double> Hourly_weather = [];
  List<double> Hourly_prediction = [];
  List<double> Daily_weather = [];
  List<double> Daily_prediction = [];

  

  Future<void> getHourlyWeather() async {
    Hourly_weather = [];
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=3c6e9a6b04b0403dbc0133211222606&q=Beirut&days=1&aqi=no&alerts=no'));
// store temp_c in Hourly_weather list for only items that have hour time = datetime.now() hour and 6 hrs after
    if (response.statusCode == 200) {
      print("after response");
      Map<String, dynamic> weather = jsonDecode(response.body);
      print("after maping");
      //print(DateTime.now().hour.toString());
      for (int i = 0;
          i < weather['forecast']['forecastday'][0]['hour'].length;
          i++) {
        // print(weather['forecast']['forecastday'][0]['hour'][18]['time'].substring(11,13));

        if (weather['forecast']['forecastday'][0]['hour'][i]['time']
                .substring(11, 13) ==
            DateTime.now().hour.toString()) {
          print("we are here");
          for (int j = 0; j < 7; j++) {
            Hourly_weather.add(
                weather['forecast']['forecastday'][0]['hour'][i + j]['temp_c']);
            if ((i + j) >= 23) {
              break;
            }
          }
        }
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather');
    }
    setState(() {});
  }

  Future<void> getDailyWeather() async {
    Daily_weather = [];
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=3c6e9a6b04b0403dbc0133211222606&q=Beirut&days=4&aqi=no&alerts=no'));
// store temp_c in Hourly_weather list for only items that have hour time = datetime.now() hour and 6 hrs after
    if (response.statusCode == 200) {
      print("after response");
      Map<String, dynamic> weather = jsonDecode(response.body);
      print("after maping");
      //add all daily weather to Daily_weather list
      for (int i = 0; i < weather['forecast']['forecastday'].length; i++) {
        Daily_weather.add(
            weather['forecast']['forecastday'][i]['day']['maxtemp_c']);
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather');
    }
    setState(() {});
  }

  Future<void> getWeather() async {
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=3c6e9a6b04b0403dbc0133211222606&q=Beirut&aqi=no'));
    final response1 = await http.get(Uri.parse(
        'https://io.adafruit.com/api/v2/tonialakik/feeds/temp/data/last?x-aio-key=aio_wQkR20kT1g9QcXm1rHGTFa3MHKoZ'));

    if (response.statusCode == 200 && response1.statusCode == 200) {
      Map<String, dynamic> weather = jsonDecode(response.body);
      Map<String, dynamic> sensor = jsonDecode(response1.body);
      await getHourlyWeather();
      await getDailyWeather();
      await getHoursPrediction();
      await getDaysPrediction();
      setState(() {
        currTemp = weather['current']['temp_c'];
        num n = double.parse(sensor['value']);
        n = num.parse(n.toStringAsFixed(1));
        seonsorTemp = n;
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather');
    }
  }

  Future<void> getHoursPrediction() async {
    Hourly_prediction = [];
    for (int i = 0; i < Hourly_weather.length; i++) {
      final response = await http.get(Uri.parse(
          'https://weather-app-nkach.herokuapp.com/predict/1/' +
              Hourly_weather[i].toString()));

          //   final response = await http.get(Uri.parse(
          // 'http://192.168.0.101:3000/predict/1/' +
          //     Hourly_weather[i].toString()));

      Hourly_prediction.add(double.parse(response.body));
    }
    setState(() {});
  }

  Future<void> getDaysPrediction() async {
    Daily_prediction = [];
    for (int i = 0; i < Daily_weather.length; i++) {
      final response = await http.get(Uri.parse(
          'https://weather-app-nkach.herokuapp.com/predict/13/' +
              Daily_weather[i].toString()));

          //       final response = await http.get(Uri.parse(
          // 'http://192.168.0.101:3000/predict/13/' +
          //      Daily_weather[i].toString()));


      Daily_prediction.add(double.parse(response.body));
    }
    setState(() {});
  }
 final globalKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    String hourformatter(DateTime date) {
      String formattedTime = DateFormat.H().format(date);
      return formattedTime;
    }

    String dateFormatter(DateTime date) {
      dynamic dayData =
          '{ "1" : "Mon", "2" : "Tue", "3" : "Wed", "4" : "Thu", "5" : "Fri", "6" : "Sat", "7" : "Sun" }';

      return json.decode(dayData)['${date.weekday}'];
    }


    

    return Scaffold(
      key: globalKey,
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 50.0, left: 20),
                child: Text('Settings',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                size: 30,
                color: Colors.black,
              ),
              title: const Text('Home',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(
              thickness: 2,
            ),
            ListTile(
              leading: Icon(
                Icons.refresh,
                size: 30,
                color: Colors.black,
              ),
              title: const Text('Calibrate',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              onTap: () async {
               final response = await http.get(Uri.parse(
          'https://weather-app-nkach.herokuapp.com/start_collecting'));
          if (response.statusCode == 200) {
          print("Colleecing started");
          }
          
            showAlert(context);
          
          
              },
            ),
            Divider(
              thickness: 2,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        //title: Text(widget.title),
        leading: Padding(
          padding: EdgeInsets.only(left: 20, top: 15),
          child: IconButton(
            hoverColor: Colors.transparent,
            onPressed: 
            //open app drawer on click
            () {

            },         
            icon: FaIcon(
              FontAwesomeIcons.bars,
            ),
          ),
        ),
        // actions: <Widget>[
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10.0, top: 0),
        //     child: IconButton(
        //       hoverColor: Colors.transparent,
        //       icon: const FaIcon(
        //         FontAwesomeIcons.temperatureHigh,
        //       ),
        //       onPressed: () async {},
        //     ),
        //   ),
        // ],
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: getWeather,
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.03,
                ),
                child: Align(
                  child: Text(
                    cityName,
                    style: GoogleFonts.questrial(
                      fontSize: size.height * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.08,
                ),
                child: Align(
                  child: Text(
                    "Now", //day
                    style: GoogleFonts.questrial(
                      fontSize: size.height * 0.035,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.01,
                ),
                child: Align(
                  child: Text(
                    '$currTemp˚C', //curent temperature
                    style: GoogleFonts.questrial(
                      color: Colors.pink,
                      fontSize: size.height * 0.06,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.25),
                child: const Divider(),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.005,
                ),
                child: Align(
                  child: Text(
                    'Sensor Temp', // weather
                    style: GoogleFonts.questrial(
                      fontSize: size.height * 0.03,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.01,
                ),
                child: Align(
                  child: Text(
                    '$seonsorTemp˚C', //curent temperature
                    style: GoogleFonts.questrial(
                      color: Colors.indigo,
                      fontSize: size.height * 0.06,
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.only(top: size.height * 0.08),
              // ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.02,
                            left: size.width * 0.03,
                          ),
                          child: Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              padding: EdgeInsets.all(size.width * 0.02),
                              child: Text(
                                'Today forecast',
                                style: GoogleFonts.questrial(
                                  fontSize: size.height * 0.025,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.005),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              buildForecast3days(
                                "Now",
                                currTemp,
                                size,
                              ),
                              //for each item in hourly_weather array buildForecast7day()
                              for (int i = 0; i < Hourly_weather.length; i++)
                                buildForecast3days(
                                  hourformatter(DateTime.now()
                                          .add(Duration(hours: i + 1))) +
                                      ":00",
                                  Hourly_weather[i],
                                  size,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.25),
                        child: const Divider(),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.02,
                            left: size.width * 0.03,
                          ),
                          child: Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              padding: EdgeInsets.all(size.width * 0.02),
                              child: Text(
                                'Today Prediction',
                                style: GoogleFonts.questrial(
                                  fontSize: size.height * 0.025,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.005),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          //sapce evenly between the icons
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildSensorPrediction3days(
                                "Now",
                                seonsorTemp,
                                size,
                              ),
                              //for each item in hourly_weather array buildForecast7day()
                              for (int i = 0; i < Hourly_prediction.length; i++)
                                buildSensorPrediction3days(
                                  hourformatter(DateTime.now()
                                          .add(Duration(hours: i + 1))) +
                                      ":00",
                                  Hourly_prediction[i],
                                  size,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.25),
                        child: const Divider(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.2),
                child: const Divider(
                  color: Colors.indigoAccent,
                ),
              ),
              const SizedBox(
                height: 30,
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.02,
                            left: size.width * 0.03,
                          ),
                          child: Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              padding: EdgeInsets.all(size.width * 0.02),
                              child: Text(
                                '3-day forecast',
                                style: GoogleFonts.questrial(
                                  fontSize: size.height * 0.025,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.005),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // ignore: todo
                            //TODO: change weather forecast from local to api get
                            for (int i = 0; i < Daily_weather.length; i++)
                              buildForecast3days(
                                dateFormatter(
                                    DateTime.now().add(Duration(days: i + 1))),
                                Daily_weather[i],
                                size,
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.25),
                        child: const Divider(),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.02,
                            left: size.width * 0.03,
                          ),
                          child: Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              padding: EdgeInsets.all(size.width * 0.02),
                              child: Text(
                                '3-day prediction',
                                style: GoogleFonts.questrial(
                                  fontSize: size.height * 0.025,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.005),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // ignore: todo
                            //TODO: change weather forecast from local to api get

                            for (int i = 0; i < Daily_prediction.length; i++)
                              buildSensorPrediction3days(
                                dateFormatter(
                                    DateTime.now().add(Duration(days: i + 1))),
                                Daily_prediction[i],
                                size,
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.25),
                        child: const Divider(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAlert(BuildContext context) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Container( width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.1,
                  child: Column(
                    children: [
                      Center(
                        child: Text("Collecting data ...", style:
                        GoogleFonts.questrial(
                            fontSize: MediaQuery.of(context).size.height * 0.035,
                            fontWeight: FontWeight.bold,
                           ),
                           
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                       Text("For the next 7 days", style:
                      GoogleFonts.questrial(
                          fontSize: MediaQuery.of(context).size.height * 0.035,
                          fontWeight: FontWeight.bold,
                         ),
                         
                      ),


                      
                      
                      
                    ],
                  )),
              ));
    }

  Widget buildForecast3days(String time, num temp, size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.025),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Text(
              time,
              style: GoogleFonts.questrial(
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            '$temp˚C',
            style: GoogleFonts.questrial(
                fontSize: size.height * 0.025,
                fontWeight: FontWeight.bold,
                color: Colors.pink),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget buildSensorPrediction3days(String time, num temp, size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.025),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Text(
              time,
              style: GoogleFonts.questrial(
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            '$temp˚C',
            style: GoogleFonts.questrial(
                fontSize: size.height * 0.025,
                fontWeight: FontWeight.bold,
                color: Colors.indigo),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
