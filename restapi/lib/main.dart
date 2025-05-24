import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com')
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  @GET('/posts/1')
  Future<HttpResponse<dynamic>> getPost();
}

class _ApiService implements ApiService {
  final Dio dio;
  final String baseUrl;

  _ApiService(this.dio, {this.baseUrl = 'https://jsonplaceholder.typicode.com'}) {
    dio.options.baseUrl = baseUrl;
  }

  @override
  Future<HttpResponse<dynamic>> getPost() async {
    try {
      final response = await dio.get('/posts/1');
      return HttpResponse(response.data, response);
    } on DioException catch (e) {
      return HttpResponse(e.response?.data, e.response!);
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('API Requests Demo'),
          actions: [IconButton(icon: const Icon(Icons.clear), onPressed: () {})],
        ),
        body: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String httpData = '';
  String dioData = '';
  String retrofitData = '';

  void _clearResults() {
    setState(() {
      httpData = '';
      dioData = '';
      retrofitData = '';
    });
  }

  String _shortenResponse(String text) {
    if (text.length > 150) {
      return '${text.substring(0, 150)}...';
    }
    return text;
  }

  Widget _buildRequestButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Future<void> _makeHttpRequest() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      );
      setState(() {
        httpData = '''
Method: HTTP
Status: ${response.statusCode}
Time: ${stopwatch.elapsedMilliseconds}ms
Body: ${_shortenResponse(response.body)}
''';
      });
    } catch (e) {
      setState(() => httpData = 'HTTP Error: ${e.toString().split('\n').first}');
    }
  }

  Future<void> _makeDioRequest() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await Dio().get('https://jsonplaceholder.typicode.com/posts/1');
      setState(() {
        dioData = '''
Method: Dio
Status: ${response.statusCode}
Time: ${stopwatch.elapsedMilliseconds}ms
Body: ${_shortenResponse(response.data.toString())}
''';
      });
    } catch (e) {
      setState(() => dioData = 'Dio Error: ${e.toString().split('\n').first}');
    }
  }

  Future<void> _makeRetrofitRequest() async {
    final stopwatch = Stopwatch()..start();
    try {
      final dio = Dio();
      final client = ApiService(dio);
      final response = await client.getPost();
      setState(() {
        retrofitData = '''
Method: Retrofit
Status: ${response.response.statusCode}
Time: ${stopwatch.elapsedMilliseconds}ms
Body: ${_shortenResponse(response.data.toString())}
''';
      });
    } catch (e) {
      setState(() => retrofitData = 'Retrofit Error: ${e.toString().split('\n').first}');
    }
  }

  Widget _buildResultBox(String title, String content) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() {
                  if (title.contains('HTTP')) httpData = '';
                  if (title.contains('Dio')) dioData = '';
                  if (title.contains('Retrofit')) retrofitData = '';
                }),
              )
            ],
          ),
          const Divider(),
          Text(content, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildRequestButton('Make HTTP Request', _makeHttpRequest),
              const SizedBox(height: 8),
              _buildRequestButton('Make Dio Request', _makeDioRequest),
              const SizedBox(height: 8),
              _buildRequestButton('Make Retrofit Request', _makeRetrofitRequest),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All'),
                onPressed: _clearResults,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (httpData.isNotEmpty) _buildResultBox('HTTP Result:', httpData),
                if (dioData.isNotEmpty) _buildResultBox('Dio Result:', dioData),
                if (retrofitData.isNotEmpty)
                  _buildResultBox('Retrofit Result:', retrofitData),
              ],
            ),
          ),
        ),
      ],
    );
  }
}