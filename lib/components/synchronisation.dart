import 'package:flutter/material.dart';
import 'package:rspi_timelapse_web/components/system_stats.dart';
import 'package:rspi_timelapse_web/main.dart';
import 'package:rspi_timelapse_web/models/synchronisation.dart';
import 'package:rspi_timelapse_web/pages/home/home.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:web_socket_channel/src/channel.dart';

typedef OnSyncStateChange = void Function(bool state);

class SynchronisationComponent extends StatefulWidget {
  SynchronisationComponent({Key? key, required this.homePage}) : super(key: key);

  final HomePage homePage;

  @override
  _SynchronisationComponentState createState() => _SynchronisationComponentState();
}

class _SynchronisationComponentState extends State<SynchronisationComponent> {
  String? selectedDirectory;
  bool enabled = true;
  SynchronisationSettings ?settings; // TODO: Zacząć używać tych settingsów i zwracać je do App by tam zarządzać synchronizacją

  Future<void> pickDirectoryForSync() async {
    String? _selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (_selectedDirectory != null) {
      setState(() {
        selectedDirectory = _selectedDirectory;
      });
    }
  }

  void stateChange(bool enabled) {
    if (enabled) {
      widget.homePage.subscribeToPhotos();
    } else {
      widget.homePage.unsubscribePhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextIconHeader(icon: Icons.sync, title: "Synchronisation"),
            const SizedBox(height:8),
            InkWell(
              onTap: () {
                setState(() {
                  enabled = !enabled;
                });
                stateChange(enabled);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IgnorePointer(
                      child: Checkbox(
                          value: enabled,
                          onChanged: (bool ?state) {
                            setState(() {
                              enabled = state!;
                            });
                            stateChange(enabled);
                          }),
                    ),
                    SizedBox(width:7),
                    Text("Enabled", style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            enabled ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Directory",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height:8),
                selectedDirectory != null
                    ? Text(selectedDirectory!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)))
                    : Container(),
                SizedBox(height: selectedDirectory != null ? 16 : 4),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          await pickDirectoryForSync();
                        },
                        child: Text(selectedDirectory == null ? "Select" : "Change")
                    ),
                    SizedBox(width: 10),
                    selectedDirectory != null ? ElevatedButton(
                        onPressed: () async {
                          launchUrlString('file://$selectedDirectory');
                        },
                        child: Text("Open")
                    ) : Container(),
                  ],
                ),
              ],
            ) : Container(),


          ],
        ),
      ),
    );
  }
}