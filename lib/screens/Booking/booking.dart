// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mojalan/model/tourguide_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mojalan/screens/Home/home.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:mojalan/utilities/colors.dart";

class Booking extends StatefulWidget {
  final TourGuideInfo tourGuideInfo;

  const Booking({Key? key, required this.tourGuideInfo}) : super(key: key);

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  LatLng markerLocation = LatLng(-8.713058466453584, 115.16771384904149);

  late int startedPrice;
  late TextEditingController daysController;

  int totalPrice = 0;

  @override
  void initState() {
    super.initState();

    final priceString = widget.tourGuideInfo.price
        .toString()
        .replaceAll(RegExp(r'[^0-9]'), '');

    startedPrice = int.tryParse(priceString) ?? 0;
    daysController = TextEditingController();

    daysController.addListener(_calculatePrice);
  }

  void _calculatePrice() {
    final days = int.tryParse(daysController.text) ?? 0;

    setState(() {
      totalPrice = startedPrice * days;
    });
  }

  @override
  void dispose() {
    daysController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesan"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// MAP
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: markerLocation,
                  initialZoom: 15,
                  onPositionChanged: (camera, hasGesture) {
                    setState(() {
                      markerLocation = camera.center;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),

                  /// MARKER
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: markerLocation,
                        child: Icon(
                          Icons.location_on,
                          color: primaryColor,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                  /// ATTRIBUTION
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => _launchUrl(
                            'https://openstreetmap.org/copyright'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// FORM
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// INPUT HARI
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Berapa hari?',
                      floatingLabelStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                /// HARGA PER HARI
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, bottom: 10, top: 10),
                  child: Row(
                    children: [
                      Text(
                        "Harga: ",
                        style:
                            TextStyle(fontSize: 17, color: blackColor),
                      ),
                      Text(
                        "Rp${NumberFormat('#,###', 'id_ID').format(widget.tourGuideInfo.price)} / Hari",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color.fromARGB(255, 126, 224, 129),
                        ),
                      ),
                    ],
                  ),
                ),

                /// TOTAL HARGA
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, bottom: 20),
                  child: Row(
                    children: [
                      Text(
                        "Total: ",
                        style:
                            TextStyle(fontSize: 17, color: blackColor),
                      ),
                      Text(
                        "Rp${NumberFormat('#,###', 'id_ID').format(totalPrice)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                /// BUTTON
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: whiteColor,
                    backgroundColor: primaryColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(0)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Home(),
                      ),
                    );
                  },
                  child: const Text(
                    'Pesan',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}