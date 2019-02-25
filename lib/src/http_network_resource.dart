import 'dart:async';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:async_resource/async_resource.dart';

/// A [NetworkResource] over HTTP.
class HttpNetworkResource<T> extends NetworkResource<T> {
  HttpNetworkResource(
      {@required String url,
      @required LocalResource<T> cache,
      Duration maxAge,
      CacheStrategy strategy,
      Parser parser,
      this.client,
      this.headers,
      this.binary: false,
      this.acceptedResponses: const [200]})
      : assert(binary != null),
        assert(acceptedResponses != null),
        super(
            url: url,
            cache: cache,
            maxAge: maxAge,
            strategy: strategy,
            parser: parser);

  /// Optional. The [http.Client] to use, recommended if frequently hitting
  /// the same server. If not specified, [http.get()] will be used instead.
  final http.Client client;

  /// Optional. The HTTP headers to send with the request.
  final Map<String, String> headers;

  /// Whether the underlying data is binary or string-based.
  final bool binary;

  /// Acceptable HTTP response codes. The response body will only be returned if
  /// the status code matches one of these.
  final List<int> acceptedResponses;

  @override
  Future<dynamic> fetchContents() async {
    final response = await (client == null
        ? http.get(url, headers: headers)
        : client.get(url, headers: headers));
    return (response != null)
        ? (binary ? response.bodyBytes : response.body)
        : null;
  }
}

/// A [NetworkResource] over HTTP with response handler
class CustomHttpNetworkResource<T> extends NetworkResource<T> {
  CustomHttpNetworkResource(
      {@required String url,
      @required LocalResource<T> cache,
      Duration maxAge,
      CacheStrategy strategy,
      Parser<T> parser,
      this.client,
      this.headers,
      this.binary: false,
      @required this.responseHandler})
      : assert(binary != null),
        super(
            url: url,
            cache: cache,
            maxAge: maxAge,
            strategy: strategy,
            parser: parser);

  /// Optional. The [http.Client] to use, recommended if frequently hitting
  /// the same server. If not specified, [http.get()] will be used instead.
  final Client client;

  /// Optional. The HTTP headers to send with the request.
  final Map<String, String> headers;

  /// Whether the underlying data is binary or string-based.
  final bool binary;

  Function(Response) responseHandler;

  /// retrieve full response after get

  @override
  Future<dynamic> fetchContents() async {
    final response = await (client == null
        ? get(url, headers: headers)
        : client.get(url, headers: headers));

    responseHandler(response);

    return (response != null)
        ? (binary ? response.bodyBytes : response.body)
        : null;
  }
}
