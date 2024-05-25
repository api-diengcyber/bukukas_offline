import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      centerTitle: true,
      title: const Text(
        'Edit Profil',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 28,
          horizontal: 32,
        ),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: storage.readAll(),
            builder: (context, AsyncSnapshot snapshot) {
              final data = snapshot.data;
              return FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormBuilderTextField(
                      name: 'username',
                      initialValue: data['username'],
                      decoration: InputDecoration(
                        labelText: "Username",
                        labelStyle: const TextStyle(
                          fontSize: 17,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.min(4),
                      ]),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    FormBuilderTextField(
                      name: 'name',
                      initialValue: data['name'],
                      decoration: InputDecoration(
                        labelText: "Nama",
                        labelStyle: const TextStyle(
                          fontSize: 17,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    FormBuilderPhoneField(
                      name: 'phone',
                      initialValue:
                          (data['phone'] != null && data['phone'] != "")
                              ? data['phone'].substring(1)
                              : "",
                      decoration: InputDecoration(
                        labelText: 'Nomor HP',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 7,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      dialogTitle: const Text('Pilih Kode Negara'),
                      priorityListByIsoCode: const ['ID'],
                      countryFilterByIsoCode: const ['ID'],
                      defaultSelectedCountryIsoCode: 'ID',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(7),
                      ]),
                      keyboardType: TextInputType.number,
                      enabled: !(data['phone'] != null && data['phone'] != ""),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    FormBuilderTextField(
                      name: 'email',
                      initialValue: data['email'],
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(
                          fontSize: 17,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    FormBuilderTextField(
                      name: 'password',
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.min(4),
                      ]),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                          }
                        },
                        child: const Text("Simpan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
