class PedalAtribute {
  double minValue;
  double maxValue;
  double stepSize;
  double currValue;
  String name;

  PedalAtribute.setCurrentValue(
      this.minValue, this.maxValue, this.stepSize, this.currValue, this.name);
  PedalAtribute(this.name, this.maxValue, this.minValue, this.stepSize)
      : currValue = minValue;

  PedalAtribute.fromJson(Map<String, dynamic> json)
      : minValue = json['minValue'] as double,
        maxValue = json['maxValue'] as double,
        stepSize = json['stepSize'] as double,
        currValue = json['currValue'] as double,
        name = json['name'] as String;

  Map<String, dynamic> toJson() {
    return {
      'minValue': minValue,
      'maxValue': maxValue,
      'stepSize': stepSize,
      'currValue': currValue,
      'name': name
    };
  }
}
