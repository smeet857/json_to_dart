import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:json_to_dart/utils/toast_utils.dart';

class JsonToDartScreen extends StatefulWidget {
  const JsonToDartScreen({super.key});

  @override
  State<JsonToDartScreen> createState() => _JsonToDartScreenState();
}

class _JsonToDartScreenState extends State<JsonToDartScreen> {
  final inputJsonTextController = TextEditingController(text: jsonEncode({
    "id": 4,
    "question_id": 1,
    "question_option": {
      "id" : 3,
      "question_id" : 3,
      "created_at": "2025-03-24T07:58:18.000000Z",
      "updated_at": "2025-03-24T07:58:34.000000Z",
    },
    "status": 1,
    "created_at": "2025-03-24T07:58:18.000000Z",
    "updated_at": "2025-03-24T07:58:34.000000Z",
  }));
  final classNameTextController = TextEditingController();
  String outputText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Json To Dart")),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _inputJson()),
                VerticalDivider(),
                Expanded(child: _outputJson()),
              ],
            ),
          ),
          SizedBox(
            width: 500,
            child: TextFormField(
              controller: classNameTextController,
              onFieldSubmitted: (_) => _convert(),
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
                hintText: "Enter Class Name",
                hintStyle: TextStyle(color: Colors.black45)
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _validateJson,style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ), child: Text("Validate Json"),),
              SizedBox(width: 20),
              ElevatedButton(onPressed: _convert,style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ), child: Text("Convert"),),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _inputJson() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: inputJsonTextController,
        maxLines: 100,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(10),
          hintText: "Enter json here...",
            hintStyle: TextStyle(color: Colors.black45)
        ),
      ),
    );
  }

  Widget _outputJson() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
          child: SelectableText(outputText, style: TextStyle(color: Colors.black,))),
    );
  }

  void _convert() {
    try{
      if(classNameTextController.text.trim().isEmpty){
        ToastUtils.show(msg: "Enter Class Name");
      }else if(inputJsonTextController.text.trim().isEmpty){
        ToastUtils.show(msg: "Enter Json");
      }else{

        final res = _createModel((jsonDecode(inputJsonTextController.text.trim())) as Map<String,dynamic>);

        setState(() {
          outputText = res;
        });
      }

    }on FormatException catch (e,trace) {
      ToastUtils.show(msg: "Invalid Json");
      log('Invalid Json \n Error : ${e.toString()}\n Trace : ${trace.toString()}');
    }catch(e,trace){
      ToastUtils.show(msg: "Invalid Json");
      log("Error on convert \n Error : ${e.toString()}\n Trace : ${trace.toString()}");
    }
  }

  String _createModel(Map<String,dynamic> json){

    String str = "class ${classNameTextController.text}{\n";

    for (var e in json.entries) {
      if(getType(e.value) == "List"){
        str = "$str  List<${toPascalCase(e.key)}> ${toCamelCase(e.key)} = ${getDefaultValue(e.value)};\n";
      }else if(getType(e.value) == "Map"){
        str = "$str  ${toPascalCase(e.key)} ${toCamelCase(e.key)} = ${toPascalCase(e.key)}();\n";
      }else{
        str = "$str  ${getType(e.value)} ${toCamelCase(e.key)} = ${getDefaultValue(e.value)};\n";
      }
    }

    str = "$str\n${classNameTextController.text}.fromJson(dynamic json){\n";

    for (var e in json.entries) {
      if(getType(e.value) == "List"){
        str = "$str  ${toCamelCase(e.key)} = ((json[\"${e.key}\"] ?? ${getDefaultValue(e.value)}) as List<dynamic>).map((e) => ${toPascalCase(e.key)}.fromJson(e)).toList();\n";
      }else if(getType(e.value) == "Map"){
        str = "$str  ${toCamelCase(e.key)} = ${toPascalCase(e.key)}.fromJson(json[\"${e.key}\"] ?? {});\n";
      }else{
        str = "$str  ${toCamelCase(e.key)} = json[\"${e.key}\"] ?? ${getDefaultValue(e.value)};\n";
      }
    }

    return "$str }\n}";
  }
  void _validateJson(){
    try{
      inputJsonTextController.text = const JsonEncoder.withIndent(' ').convert(jsonDecode(inputJsonTextController.text.trim()));
    }catch(e,trace){
      ToastUtils.show(msg: "Invalid Json");
      log("Error on validate json \n Error : ${e.toString()}\n Trace : ${trace.toString()}");
    }
  }

  String getType(dynamic v){
    if(v.runtimeType == String){
      return "String";
    }else if(v.runtimeType == bool){
      return "bool";
    }else if(v.runtimeType == int){
      return "int";
    }else if(v.runtimeType == double){
      return "double";
    }else if(v.runtimeType == List){
      return "List";
    }else if(v is Map){
      return "Map";
    }else{
      return "String";
    }
  }

  String getDefaultValue(dynamic v){
    if(v.runtimeType == String){
      return "\"\"";
    }else if(v.runtimeType == bool){
      return "false";
    }else if(v.runtimeType == int){
      return "0";
    }else if(v.runtimeType == double){
      return "0";
    }else if(v.runtimeType == List){
      return "[]";
    }else{
      return "String";
    }
  }

  String toCamelCase(String text) {
    List<String> words = text.split('_');
    return words.first + words.skip(1).map((word) => word[0].toUpperCase() + word.substring(1)).join('');
  }

  String toPascalCase(String text) {
    List<String> words = text.split('_');
    return words.map((word) => word[0].toUpperCase() + word.substring(1)).join('');
  }
}
