import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:weather_app/data/app_exception.dart';
import 'package:weather_app/data/network/base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getGetApiResponse(String url) async {
    dynamic responseJson;

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException("No network connection");
    }

    return responseJson;
  }

  @override
  Future<dynamic> getPostApiResponse(String url, dynamic data,) async {
    dynamic responseJson;

    try {
      final response = await http.post(Uri.parse(url),
        body: data,
      )
          .timeout(
        const Duration(seconds: 10),
      );

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException("No network connection");
    }

    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;

      case 400:
        throw BadRequestException(
          response.statusCode.toString(),
        );

      case 401:
        throw UnauthorizedException(
          response.statusCode.toString(),
        );

      case 404:
        throw FetchDataException(
          "Resource not found",
        );

      default:
        throw FetchDataException(
          "Error occurred while communicating with server "
              "with status code ${response.statusCode}",
        );
    }
  }
}