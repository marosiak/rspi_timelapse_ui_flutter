import 'dart:convert';

class StatsResponse {
  Ram? ram;
  Cpu? cpu;
  Memory? memory;
  DateTime? lastPhotoTakenAt;

  StatsResponse({this.ram, this.cpu, this.memory, this.lastPhotoTakenAt});

  StatsResponse.fromJson(Map<dynamic, dynamic> json) {
    ram = json['ram'] != null ? Ram.fromJson(json['ram']) : null;
    cpu = json['cpu'] != null ? Cpu.fromJson(json['cpu']) : null;
    memory = json['memory'] != null ? Memory.fromJson(json['memory']) : null;
    lastPhotoTakenAt = json['lastPhotoTakenAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['lastPhotoTakenAt']*1000) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (ram != null) {
      data['ram'] = ram!.toJson();
    }
    if (cpu != null) {
      data['cpu'] = cpu!.toJson();
    }
    if (memory != null) {
      data['memory'] = memory!.toJson();
    }
    data['lastPhotoTakenAt'] = ((lastPhotoTakenAt?.millisecondsSinceEpoch)!/1000);
    return data;
  }
}

class Ram {
  int? _total;
  int? _used;
  int? _free;
  int? _swapTotal;
  int? _swapFree;

  Ram({int? total, int? used, int? free, int? pageFileFree, int? virtualTotal, int? SwapFree}) : _total = total, _used = used, _free = free, _swapTotal = virtualTotal, _swapFree = SwapFree;

  Ram.fromJson(Map<String, dynamic> json) {
    _total = json['Total'];
    _used = json['Used'];
    _free = json['Free'];
    _swapTotal = json['VirtualTotal'] ?? json['SwapTotal'];
    _swapFree = json['VirtualFree'] ?? json['SwapFree'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Total'] = this._total;
    data['Used'] = this._used;
    data['Free'] = this._free;
    data['VirtualTotal'] = this._swapTotal;
    data['VirtualFree'] = this._swapFree;
    return data;
  }

  String swapTotalToString() {
    int swapTotal = _swapTotal ?? _swapTotal ?? 0;
    return (swapTotal / (1024 * 1024)).toStringAsFixed(2);
  }

  String swapUsedToString() {
    int swapUsed = _swapFree ?? (_swapTotal! - this._swapFree!);
    return (swapUsed / (1024 * 1024)).toStringAsFixed(2);
  }

  String totalToGB() {
    return (this._total! / (1024 * 1024 * 1024)).toStringAsFixed(2);
  }

  String freeToGB() {
    return (this._free! / (1024 * 1024 * 1024)).toStringAsFixed(2);
  }

}

class Cpu {
  int? user;
  int? system;
  int? idle;

  Cpu({this.user, this.system, this.idle});

  Cpu.fromJson(Map<String, dynamic> json) {
    user = json['User'];
    system = json['System'];
    idle = json['Idle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['User'] = this.user;
    data['System'] = this.system;
    data['Idle'] = this.idle;
    return data;
  }

  String userToPercent() {
    return user!.toStringAsFixed(2);
  }

  String systemToPercent() {
    return system!.toStringAsFixed(2);
  }

  String idleToPercent() {
    return idle!.toStringAsFixed(2);
  }
}

class Memory {
  late final int _total;
  late final int _free;
  late final String? timeRemainingForTimelapse;

  Memory({required int total, required int free}) : _total = total, _free = free;


  Memory.fromJson(Map<String, dynamic> json) {
    _total = json['Total'];
    _free = json['Free'];
    timeRemainingForTimelapse = json['TimeRemainingForTimelapse'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['Total'] = _total;
    data['Free'] = _free;
    data['TimeRemainingForTimelapse'] = this.timeRemainingForTimelapse;
    return data;
  }
  String totalToGB() {
    return (_total! / (1024 * 1024 * 1024)).toStringAsFixed(2);
  }

  String freeToGB() {
    return (_free! / (1024 * 1024 * 1024)).toStringAsFixed(2);
  }
}
