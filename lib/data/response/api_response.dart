import 'package:flutter/material.dart';
import 'package:weather_app/data/response/status.dart';
class ApiResponse<T> {
  Status? status;
  T? data;
  String? message;
  ApiResponse([this.status, this.data, this.message]);
  ApiResponse.Loading() : status = Status.Loading {
    // TODO: implement ApiResponse.Loading
    throw UnimplementedError();
  }
  ApiResponse.Completed() : status = Status.Completed {
    // TODO: implement ApiResponse.Completed
    throw UnimplementedError();
  }
  ApiResponse.Error() : status = Status.Error {
    // TODO: implement ApiResponse.Loading
    throw UnimplementedError();
  }
  String toString() {
    return "Status: $status \n Message: $message \n Data: $data";
  }

}