import 'package:alarm_demo/application/presentation/data/data_provider/data_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:alarm_demo/domain/models/location_model/location_model.dart';

class LocationController extends GetxController {
  final location = Rxn<String>();
  final weatherService = WeatherService(); 

  @override
  void onInit() {
    super.onInit();
    _fetchLocation();
  }

 Future<void> _fetchLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      location.value = 'Location services are disabled. Please enable in Settings.';
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        location.value =
            'Location permissions are denied. Please grant permission in Settings.';
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      location.value =
          'Location permissions are permanently denied. Please grant permission in App Settings.';
      return;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print('Failed to get location: $e');
      location.value = 'Failed to get location. Please try again.';
      return;
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isEmpty) {
      print('Failed to get address from coordinates.');
      location.value = 'Failed to get address.';
      return;
    }

    Placemark placemark = placemarks.first;
    String address = '${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
    location.value = address;

    // Fetch weather data
    // await _fetchWeather(position.latitude, position.longitude);
  } catch (e) {
    print('Failed to fetch location: $e');
    location.value = 'Failed to get location.';
  }
}

  // Future<void> _fetchWeather(double latitude, double longitude) async {
  //   try {
  //     LocationModel weatherData = await weatherService.getWeather(latitude, longitude);
  //     // Update the location with weather data or use it as needed
  //     location.value = 'User Current location: ${weatherData.lat}';
  //   } catch (e) {
  //     print('Failed to fetch weather: $e');
  //     location.value = 'Failed to get weather';
  //   }
  // }
}
