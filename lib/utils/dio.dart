import 'package:dio/dio.dart';
import 'dart:io';
import 'package:toasty/toasty.dart';
import 'package:dd_app/utils/db/user.dart';

class Fetch {
  static Fetch _instance;
  static Dio dio;
  static Fetch get instance {
    if (_instance == null) {
      _instance = new Fetch();
    }
    return _instance;
  }

  Fetch() {
    Options options = new Options(
        baseUrl: "https://dd.shmy.tech/api/client",
        // baseUrl: "http://172.27.35.17:1994/api/client",
        connectTimeout: 10000,
        receiveTimeout: 10000,
        contentType: ContentType.parse("application/x-www-form-urlencoded"),
        headers: {
          "App-Platform": Platform.operatingSystem,
        });
    dio = new Dio(options);
    dio.interceptor.request.onSend = (Options options) async {
      User userModel = await User.instance;
      // userModel.
      Map u = await userModel.findID1();
      if (options.headers["Authorization"] == null && u != null) {
        options.headers["Authorization"] = "Bearer " + u["token"];
      }
      print(options.path);
      print(options.data);
      return options;
    };
    dio.interceptor.response.onSuccess = (Response response) {
      Map data = response.data;
      bool success = data["success"];
      if (!success) {
        Toasty.error(data["message"]);
        return dio.resolve(null);
      }
      return dio.resolve(data["payload"]);
    };
    dio.interceptor.response.onError = (DioError e) {
      String msg = this.formatErrorMessage(e.type);
      if (e.response != null) {
        msg = e.response.data["message"];
      }
      if (msg != "") {
        Toasty.error(msg);
      }
      // 请求异常返回null
      return dio.resolve(null);
    };
  }
  // 克隆GET方法 做错误处理
  get(String path, {data, Options options, CancelToken cancelToken}) async {
    try {
      Response response = await dio.get(path,
          data: data, options: options, cancelToken: cancelToken);
      return response.data;
    } on DioError catch (e) {
      String msg = this.formatErrorMessage(e.type);
      if (msg != "") {
        Toasty.error(msg);
      }
      return dio.resolve(null);
    }
  }

  post(String path, {data, Options options, CancelToken cancelToken}) async {
    try {
      Response response = await dio.post(path,
          data: data, options: options, cancelToken: cancelToken);
      return response.data;
    } on DioError catch (e) {
      String msg = this.formatErrorMessage(e.type);
      if (msg != "") {
        Toasty.error(msg);
      }
      return dio.resolve(null);
    }
  }

  put(String path, {data, Options options, CancelToken cancelToken}) async {
    try {
      Response response = await dio.put(path,
          data: data, options: options, cancelToken: cancelToken);
      return response.data;
    } on DioError catch (e) {
      String msg = this.formatErrorMessage(e.type);
      if (msg != "") {
        Toasty.error(msg);
      }
      return dio.resolve(null);
    }
  }

  delete(String path, {data, Options options, CancelToken cancelToken}) async {
    try {
      Response response = await dio.delete(path,
          data: data, options: options, cancelToken: cancelToken);
      return response.data;
    } on DioError catch (e) {
      String msg = this.formatErrorMessage(e.type);
      if (msg != "") {
        Toasty.error(msg);
      }
      return dio.resolve(null);
    }
  }

  download(
    String urlPath,
    savePath, {
    OnDownloadProgress onProgress,
    CancelToken cancelToken,
    data,
    Options options,
  }) {
    Dio d = new Dio();
    d.onHttpClientCreate = (HttpClient client) {
      client.idleTimeout = new Duration(seconds: 0);
    };
    d.download(urlPath, savePath,
        onProgress: onProgress,
        cancelToken: cancelToken,
        data: data,
        options: options);
  }

  String formatErrorMessage(DioErrorType type) {
    switch (type) {
      case DioErrorType.DEFAULT:
        return "无法连接到服务器，请检查您的网络设置！";
      case DioErrorType.CONNECT_TIMEOUT:
        return "连接超时，请稍后再试！";
      case DioErrorType.RECEIVE_TIMEOUT:
        return "接收超时，请稍后再试！";
      case DioErrorType.RESPONSE:
        return "服务器睡着了，请稍后再试！";
      // case DioErrorType.CANCEL:
      //   return "";
      default:
        return "";
    }
  }
}

// dio.interceptor.response.onSuccess = (Response response) {
//      // 在返回响应数据之前做一些预处理
//      return response; // continue
//  };
