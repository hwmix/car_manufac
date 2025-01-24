import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'car_mfr.dart';

class CarManufac extends StatefulWidget {
  const CarManufac({Key? key}) : super(key: key);

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  late Future<CarMfr> carMfrFuture;

  /// ฟังก์ชันดึงข้อมูลจาก API
  Future<CarMfr> getCarMfr() async {
    const String url =
        "https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return carMfrFromJson(response.body);
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    carMfrFuture = getCarMfr(); // เรียกใช้งานเพียงครั้งเดียว
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
      ),
      body: FutureBuilder<CarMfr>(
        future: carMfrFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // แสดง Loading Indicator
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final carMfr = snapshot.data!;
            return ListView.builder(
              itemCount: carMfr.results?.length ?? 0,
              itemBuilder: (context, index) {
                final result = carMfr.results![index];
                return ListTile(
                  leading: const Icon(Icons.car_rental),
                  title: Text(result.mfrName ?? "Unknown Manufacturer"),
                  subtitle: Text(result.country ?? "Unknown Country"),
                  trailing: Text("ID: ${result.mfrId ?? "-"}"),
                );
              },
            );
          }
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }
}
