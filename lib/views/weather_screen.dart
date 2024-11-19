import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app_1/views/DetailPage.dart';
import '/repositories/bmkg_repository.dart';
import '/services/bmkg_service.dart';
import '/models/bmkg_model.dart';
import '/views/add_location.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherScreen extends StatefulWidget {
  final String kode;
  const WeatherScreen({super.key, required this.kode});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  DateTime? lastPressed;
  List<BMKGModel> weather = [];

  final BmkgRepository _BMKGRepository = BmkgRepository();
  late final BmkgService _BMKGService;

  @override
  void initState() {
    super.initState();
    _BMKGService = BmkgService(_BMKGRepository);
    String kodeCuaca = widget.kode;
    _fetchDatasBMKG(kodeCuaca);
  }

  bool isLoading = false;

  Future<void> _fetchDatasBMKG(String kode) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<BMKGModel> fetchedDatasBMKG = await _BMKGService.fetchBMKG(kode);
      setState(() {
        weather = fetchedDatasBMKG;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load BMKG: $error');
      Navigator.pop(context, '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        const maxDuration = Duration(seconds: 2);

        if (lastPressed == null || now.difference(lastPressed!) > maxDuration) {
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press again to exit'),
              duration: maxDuration,
            ),
          );
          return false;
        } else {
          exit(0);
        }
      },
      child: Scaffold(
        appBar: isLoading
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight + 16.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 15.0),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: null,
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    title: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        weather.isNotEmpty ? weather[0].village : 'Kosong',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddLocation(kode: widget.kode),
                            ),
                          );
                        },
                      ),
                    ],
                    systemOverlayStyle: const SystemUiOverlayStyle(
                      statusBarBrightness: Brightness.dark,
                    ),
                  ),
                ),
              ),
        backgroundColor: const Color(0xFF312E81),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Tampilkan loading
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(3, -0.3),
                        child: Container(
                          height: 300,
                          width: 300,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-3, -0.3),
                        child: Container(
                          height: 300,
                          width: 300,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, -1.2),
                        child: Container(
                          height: 300,
                          width: 600,
                          decoration:
                              const BoxDecoration(color: Color(0xFFFFAB40)),
                        ),
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                        child: Container(
                          decoration:
                              const BoxDecoration(color: Colors.transparent),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.network(
                              weather[0].image,
                              fit: BoxFit.cover,
                              placeholderBuilder: (BuildContext context) =>
                                  const CircularProgressIndicator(),
                              width: 200,
                              height: 200,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${weather[0].temperature.toStringAsFixed(0)}°C',
                                  style: const TextStyle(
                                    fontSize: 80,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const Text(
                                        "",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        weather[0].weatherDescription,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            buildWeatherGrid(),
                            const SizedBox(height: 9),
                            const Text(
                              "Data Disediakan oleh BMKG (Badan Meteorologi, Klimatologi, dan Geofisika)",
                              style: TextStyle(color: Colors.white54),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String getHumidityDescription(double humidity) {
    if (humidity < 30) {
      return "Udara sangat kering";
    } else if (humidity <= 60) {
      return "Udara cukup nyaman";
    } else {
      return "Udara lembap, kemungkinan hujan";
    }
  }

  String getWindSpeedDescription(double windSpeed) {
    if (windSpeed <= 10) {
      return "Angin sangat ringan";
    } else if (windSpeed <= 20) {
      return "Angin sedang";
    } else if (windSpeed <= 40) {
      return "Angin kencang, potensi gangguan";
    } else {
      return "Angin sangat kencang, tetap di dalam ruangan";
    }
  }

  String getCloudCoverageDescription(String cloudCoverageStr) {
    double cloudCoverage = double.tryParse(cloudCoverageStr) ?? 0;

    if (cloudCoverage < 25) {
      return "Langit cerah";
    } else if (cloudCoverage <= 50) {
      return "Sebagian berawan";
    } else {
      return "Langit sepenuhnya tertutup awan";
    }
  }

  String getVisibilityDescription(String visibility) {
    double visibilityValue = double.tryParse(visibility) ?? 0;
    if (visibilityValue > 10) {
      return "Jarak pandang sangat baik";
    } else if (visibilityValue >= 5) {
      return "Jarak pandang cukup baik";
    } else {
      return "Jarak pandang buruk";
    }
  }

  Widget buildWeatherGrid() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
              flex: 6,
              child: buildCardFooter(
                "Kelembapan Udara",
                "${weather[0].humidity.toStringAsFixed(0)} %",
                "assets/humidity.png",
                "Kelembapan udara adalah ukuran jumlah uap air yang terkandung di atmosfer pada waktu tertentu. Biasanya dinyatakan dalam bentuk persentase, kelembapan udara menunjukkan seberapa dekat udara berada pada titik jenuhnya, di mana udara tidak lagi mampu menahan uap air tambahan. Kelembapan yang tinggi berarti udara mengandung banyak uap air, yang bisa membuat udara terasa lebih panas dan pengap. Sebaliknya, kelembapan rendah menunjukkan udara yang lebih kering, yang dapat menyebabkan kulit kering dan meningkatkan risiko dehidrasi. Kelembapan udara memengaruhi kenyamanan, kesehatan, dan aktivitas manusia, serta proses alam seperti pembentukan awan dan hujan.",
                getHumidityDescription(weather[0].humidity),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 6,
              child: buildCardFooter(
                "Kecepatan Angin",
                "${weather[0].windSpeed} Km/jam",
                "assets/air-quality.png",
                "Kecepatan angin adalah ukuran seberapa cepat udara bergerak di suatu wilayah pada waktu tertentu. Angin dihasilkan oleh perbedaan tekanan udara di atmosfer dan bergerak dari area bertekanan tinggi ke area bertekanan rendah. Kecepatan angin biasanya diukur dalam kilometer per jam (km/h) atau meter per detik (m/s), dan dapat mempengaruhi banyak aspek kehidupan, seperti kenyamanan saat berada di luar ruangan, navigasi udara dan laut, serta aktivitas sehari-hari lainnya. Dalam prediksi cuaca, kecepatan angin juga penting karena angin kencang bisa membawa cuaca ekstrem seperti badai atau hujan deras.",
                getWindSpeedDescription(weather[0].windSpeed),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
              flex: 6,
              child: buildCardFooter(
                "Tutupan Awan",
                "${weather[0].temperatureCondition} %",
                "assets/cloud.png",
                "Tutupan awan adalah istilah yang digunakan untuk menggambarkan persentase langit yang tertutupi oleh awan pada waktu tertentu di suatu lokasi. Tutupan awan sering kali diukur dalam delapanan (okta), dengan nilai 0 okta berarti langit cerah tanpa awan, dan 8 okta berarti langit tertutup seluruhnya oleh awan. Tutupan awan memengaruhi intensitas sinar matahari yang mencapai permukaan bumi, serta dapat menunjukkan adanya perubahan cuaca, seperti hujan atau badai yang akan datang. Awan juga memainkan peran penting dalam mengatur suhu bumi dengan memantulkan atau menyerap radiasi matahari.",
                getCloudCoverageDescription(weather[0].temperatureCondition),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 6,
              child: buildCardFooter(
                "Jarak Pandang",
                weather[0].visibilityText,
                "assets/visibility.png",
                "Jarak pandang adalah ukuran seberapa jauh seseorang dapat melihat objek yang jelas di atmosfer dalam kondisi cuaca tertentu. Jarak pandang biasanya diukur dalam kilometer atau meter dan sangat dipengaruhi oleh faktor-faktor seperti kabut, hujan, salju, debu, asap, atau polusi udara. Ketika jarak pandang berkurang, misalnya akibat kabut tebal atau hujan lebat, hal ini dapat mengganggu aktivitas seperti mengemudi, penerbangan, dan pelayaran. Dalam prediksi cuaca, informasi tentang jarak pandang sangat penting untuk keamanan perjalanan dan perencanaan aktivitas luar ruangan.",
                getVisibilityDescription(weather[0].visibilityText),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Method untuk membangun baris cuaca
  Widget buildCardFooter(String title, String value, String image,
      String description, String description2) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman deskripsi ketika card ditekan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              title: title,
              value: value,
              image: image,
              description: description,
              description2: description2,
            ),
          ),
        );
      },
      child: Row(
        children: [
          const SizedBox(width: 2),
          Expanded(
            flex: 6,
            child: Card(
              color: const Color(0xFF4C47A3),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(30.0)), // Atur radius di sini
              ),
              elevation: 5,
              child: Container(
                width: 170, // Sesuaikan ukuran Card
                height: 170,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              image,
                              height: 60,
                              width: 60,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
