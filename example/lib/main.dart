import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:android_sms_kit/android_sms_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android SMS Kit Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _platformVersion = 'Unknown';
  String _permissionStatus = 'Unknown';
  List<Map<String, dynamic>> _smsMessages = [];
  List<Map<String, dynamic>> _simpleSms = [];
  List<Map<String, dynamic>> _transactionSms = [];
  bool _isLoading = false;
  int _selectedTab = 0;

  final _androidSmsKitPlugin = AndroidSmsKit();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    checkPermission();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _androidSmsKitPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> checkPermission() async {
    try {
      final status = await _androidSmsKitPlugin.checkSmsPermission();
      setState(() {
        _permissionStatus = status ?? 'Unknown';
      });
    } catch (e) {
      setState(() {
        _permissionStatus = 'Error: $e';
      });
    }
  }

  Future<void> requestPermission() async {
    try {
      final result = await _androidSmsKitPlugin.requestSmsPermission();
      setState(() {
        _permissionStatus = result ?? 'Unknown';
      });

      if (result == 'granted') {
        _showSnackBar(
          'Permission granted! You can now read SMS.',
          Colors.green,
        );
      } else {
        _showSnackBar('Permission denied.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error requesting permission: $e', Colors.red);
    }
  }

  Future<void> readAllSms() async {
    if (_permissionStatus != 'granted') {
      _showSnackBar('Please grant SMS permission first.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jsonString = await _androidSmsKitPlugin.readSms();
      final messages = _androidSmsKitPlugin.parseSmsJson(jsonString);

      setState(() {
        _smsMessages = messages;
        _isLoading = false;
        _selectedTab = 0;
      });

      _showSnackBar('Loaded ${messages.length} SMS messages', Colors.green);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error reading SMS: $e', Colors.red);
    }
  }

  Future<void> readSimpleSms() async {
    if (_permissionStatus != 'granted') {
      _showSnackBar('Please grant SMS permission first.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jsonString = await _androidSmsKitPlugin.getSimpleSms(limit: 50);
      final messages = _androidSmsKitPlugin.parseSmsJson(jsonString);

      setState(() {
        _simpleSms = messages;
        _isLoading = false;
        _selectedTab = 1;
      });

      _showSnackBar('Loaded ${messages.length} simple SMS', Colors.green);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error reading simple SMS: $e', Colors.red);
    }
  }

  Future<void> readTransactionSms() async {
    if (_permissionStatus != 'granted') {
      _showSnackBar('Please grant SMS permission first.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jsonString = await _androidSmsKitPlugin.getTransactionSms();
      final messages = _androidSmsKitPlugin.parseSmsJson(jsonString);

      setState(() {
        _transactionSms = messages;
        _isLoading = false;
        _selectedTab = 2;
      });

      _showSnackBar('Loaded ${messages.length} transaction SMS', Colors.green);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error reading transaction SMS: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Android SMS Kit Demo'), elevation: 2),
      body: Column(
        children: [
          _buildInfoCard(),
          _buildActionButtons(),
          _buildTabBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform: $_platformVersion',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Permission Status: ',
                  style: TextStyle(fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _permissionStatus == 'granted'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _permissionStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _permissionStatus == 'granted'
                          ? Colors.green.shade900
                          : Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: checkPermission,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Permission'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: requestPermission,
                  icon: const Icon(Icons.security),
                  label: const Text('Request Permission'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : readAllSms,
                  icon: const Icon(Icons.message),
                  label: const Text('All SMS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : readSimpleSms,
                  icon: const Icon(Icons.chat),
                  label: const Text('Simple SMS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : readTransactionSms,
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Transactions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('All SMS\n(${_smsMessages.length})', 0)),
          Expanded(child: _buildTab('Simple\n(${_simpleSms.length})', 1)),
          Expanded(
            child: _buildTab('Transactions\n(${_transactionSms.length})', 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Map<String, dynamic>> messages;
    switch (_selectedTab) {
      case 0:
        messages = _smsMessages;
        break;
      case 1:
        messages = _simpleSms;
        break;
      case 2:
        messages = _transactionSms;
        break;
      default:
        messages = [];
    }

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No messages loaded',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a button above to load SMS',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final sender = message['address'] ?? message['sender'] ?? 'Unknown';
    final body = message['body'] ?? message['message'] ?? '';
    final timestamp = message['date'] ?? message['timestamp'] ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sender,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
