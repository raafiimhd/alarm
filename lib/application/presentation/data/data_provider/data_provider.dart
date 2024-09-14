import 'package:alarm_demo/domain/models/location_model/location_model.dart';
import 'package:dio/dio.dart';

class WeatherService {
  final Dio _dio = Dio();

  final String _apiKey = '2a9d93ac983abfa37c321191e99bd95e';

  Future<LocationModel> getWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric'
        },
      );
      if(response.statusCode==200){
       return LocationModel.fromJson(response.data);
      }else{
        throw Exception('Failed to fetch User Loaction');
      }
      
    } catch (e) {
      print('Error fetching weather data: $e');
      throw e;
    }
  }
}
