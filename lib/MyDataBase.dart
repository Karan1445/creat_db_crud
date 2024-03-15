import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
class MyDataBase{


  Future<Database> initDB() async {
    var db=await openDatabase("demo.db",onCreate: (db, version) {
      db.execute('CREATE TABLE demo1(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
    },version: 1
    );
    return db;
  }

 Future<List<Map<String,dynamic>>> getDataFromdemo1() async {
    Database db=await initDB();
    List<Map<String,dynamic>> table_data = await db.rawQuery('SELECT * FROM demo1');
    return table_data;
  }
  Future<int> insertNewDataToDemoTable(String userName) async {
    Database db=await initDB();
    int res=await db.rawInsert('INSERT INTO demo1(name)VALUES("'"$userName"'")');
    return res;
  }
 Future<int> deleteFromDemo1(int id) async {
    Database db=await initDB();
    int res=await db.rawDelete("delete from demo1 where id=$id");
    return res;
  }
  Future<int> updateDataFromDemo1(int id ,String newValue) async {
    Database db=await initDB();
     int res=await db.rawUpdate('''
    UPDATE demo1 
    SET name = ?
    WHERE id = ?
    ''',
         [newValue, id]);
     return res;
  }
}



class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();

}

class _HomepageState extends State<Homepage> {
  int count=0;
  String button_name="add";
  TextEditingController td= TextEditingController();
  TextEditingController popupController= TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(

        children: [
          Container(margin: EdgeInsets.only(top:55),
            child: Center(child: Column(
              children: [Container(margin: EdgeInsets.only(left: 25,right: 25),child: TextFormField(controller: td,decoration: InputDecoration(hintText: "Enter Name",border: OutlineInputBorder(borderRadius: BorderRadius.circular(40) )))),
                ElevatedButton(onPressed: () {
                      if(td!=null && td.value.text!=""){
                         MyDataBase().insertNewDataToDemoTable(td.value.text).then((value) {
                           setState(() {

                           });
                           td.clear();
                           return 1;
                         });
                      }
                },child: Text(button_name),),
              ],
            ),),
          ),



          FutureBuilder(future: MyDataBase().getDataFromdemo1(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                count++;
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length, itemBuilder: (context, index) {
                    return Container(margin: EdgeInsets.only(top:5,bottom :5,right: 10,left: 10),
                      child: ListTile(shape: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        leading: TextButton(onPressed: () {
                          openDialog(snapshot.data![index]["id"],snapshot.data![index]["name"]);
                        }, child: Text(snapshot.data![index]["name"]),)
                        ,trailing: GestureDetector(onTap: (){
                          MyDataBase().deleteFromDemo1(snapshot.data![index]["id"] as int);
                          setState(() {

                          });
                        }
                          ,child: Icon(Icons.delete,color: Colors.redAccent,)),),
                    );
                  },),
                );
              }
              else {
                return Center(child: const CircularProgressIndicator());
              }

            },

          ),
        ],
      ),
    );

  }
openDialog(int id,String value){
    return showDialog(context: context, builder: (context) => AlertDialog(title: Text("Update data"),
    content: TextFormField(controller:popupController ,decoration: InputDecoration(hintText: value),),
    actions: [
      TextButton(onPressed: (){
        if(popupController.value.text!=""){
          MyDataBase().updateDataFromDemo1(id, popupController.value.text);
          Navigator.pop(context);
          popupController.clear();
          setState(() {

          });
        }
      }, child: Text("UPDATE"))
    ],),
    );
}

}

