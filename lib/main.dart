import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobil Programlama Final Ödevi',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF8B5CF6),
          secondary: const Color(0xFFA78BFA),
          surface: const Color(0xFF1F2937),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2937),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1F2937),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final List<IconData> ikonlar = [
    Icons.star,
    Icons.directions_car,
    Icons.pets,
    Icons.shopping_bag,
    Icons.directions_run,
    Icons.movie,
    Icons.restaurant,
    Icons.flight_takeoff,
    Icons.local_hospital,
    Icons.palette,
  ];

  final TextEditingController _baslikTutucu = TextEditingController();
  final TextEditingController _icerikTutucu = TextEditingController();

  DateTime _secilenTarih = DateTime.now();
  IconData _secilenIkon = Icons.star;

  void _todoEklemePaneli() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 25,
                right: 25,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 55,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Yeni Görev Oluştur",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        "İkon Seçiniz:",
                        style: TextStyle(color: Colors.white70),
                      ),
                      DropdownButton<IconData>(
                        dropdownColor: const Color(0xFF374151),
                        value: _secilenIkon,
                        underline: const SizedBox(),
                        items: ikonlar.map((IconData ikon) {
                          return DropdownMenuItem(
                            value: ikon,
                            child: Icon(ikon, color: const Color(0xFF8B5CF6)),
                          );
                        }).toList(),
                        onChanged: (yeniDeger) {
                          modalState(() => _secilenIkon = yeniDeger!);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _baslikTutucu,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Başlık",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF374151),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _icerikTutucu,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Detay Bilgisi",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF374151),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF8B5CF6),
                    ),
                    title: Text(
                      "Tarih: ${DateFormat('dd/MM/yyyy').format(_secilenTarih)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      DateTime? takvimdenSecilen = await showDatePicker(
                        context: context,
                        initialDate: _secilenTarih,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (takvimdenSecilen != null) {
                        modalState(() => _secilenTarih = takvimdenSecilen);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        if (_baslikTutucu.text.isNotEmpty) {
                          FirebaseFirestore.instance.collection('todos').add({
                            'title': _baslikTutucu.text,
                            'subTitle': _icerikTutucu.text,
                            'date': _secilenTarih,
                            'iconIndex': ikonlar.indexOf(_secilenIkon),
                            'isDone': false,
                          });
                          Navigator.pop(context);
                          _baslikTutucu.clear();
                          _icerikTutucu.clear();
                        }
                      },
                      child: const Text(
                        "Listeye Ekle",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Görevlerim")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('todos')
            .orderBy('date')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var veri = snapshot.data!.docs[index];
              bool tamamlandi = veri['isDone'];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: tamamlandi
                        ? Colors.grey
                        : const Color(0xFF8B5CF6),
                    child: Icon(
                      ikonlar[veri['iconIndex']],
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    veri['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      decoration: tamamlandi
                          ? TextDecoration.lineThrough
                          : null,
                      color: tamamlandi ? Colors.grey : Colors.white,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "${veri['subTitle']}\n${DateFormat('dd.MM.yyyy').format(veri['date'].toDate())}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),

                  trailing: Checkbox(
                    activeColor: const Color(0xFF8B5CF6),
                    value: tamamlandi,
                    onChanged: (deger) {
                      FirebaseFirestore.instance
                          .collection('todos')
                          .doc(veri.id)
                          .update({'isDone': deger});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5CF6),
        onPressed: _todoEklemePaneli,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
