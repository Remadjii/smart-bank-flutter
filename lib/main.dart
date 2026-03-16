import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fl_chart/fl_chart.dart';

const String baseUrl = "http://localhost:3000/api";

void main() {
  runApp(BankApp());
}

class BankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Bank",
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text
      }),
    );

    final data = jsonDecode(response.body);

    if(data["id"] != null){

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Dashboard(user: data),
        ),
      );

    }else{

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed")),
      );

    }

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(title: Text("Login")),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            SizedBox(height:20),

            ElevatedButton(
              onPressed: login,
              child: Text("Login"),
            ),

            TextButton(
              child: Text("Register"),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterScreen(),
                  ),
                );
              },
            )

          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>{

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void register() async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Account created")),
    );

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(title: Text("Register")),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText:"Name"),
            ),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText:"Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText:"Password"),
            ),

            SizedBox(height:20),

            ElevatedButton(
              onPressed: register,
              child: Text("Register"),
            )

          ],
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {

  final Map user;

  Dashboard({required this.user});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>{

  List transactions = [];

  void loadTransactions() async {

    final response = await http.get(
      Uri.parse("$baseUrl/transactions/${widget.user["id"]}")
    );

    setState(() {
      transactions = jsonDecode(response.body);
    });

  }

  List<FlSpot> getChartData(){

    List<FlSpot> spots = [];

    for(int i=0;i<transactions.length;i++){

      double amount =
          double.parse(transactions[i]["amount"].toString());

      spots.add(
        FlSpot(i.toDouble(), amount)
      );

    }

    return spots;

  }

  @override
  void initState(){
    super.initState();
    loadTransactions();
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: Text("Dashboard")),

      body: SingleChildScrollView(

        child: Padding(
          padding: EdgeInsets.all(20),

          child: Column(

            children: [

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(25),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo,Colors.deepPurple]
                  ),
                  borderRadius: BorderRadius.circular(20)
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text("Bank Card",
                    style: TextStyle(color:Colors.white70)),

                    SizedBox(height:20),

                    Text(
                      "**** **** **** ${widget.user["id"]}",
                      style: TextStyle(
                        color:Colors.white,
                        fontSize:22,
                        letterSpacing:3
                      ),
                    ),

                    SizedBox(height:20),

                    Text("Balance",
                    style: TextStyle(color:Colors.white70)),

                    Text(
                      "\$${widget.user["balance"]}",
                      style: TextStyle(
                        color:Colors.white,
                        fontSize:30,
                        fontWeight:FontWeight.bold
                      ),
                    )

                  ],
                ),
              ),

              SizedBox(height:20),

              QrImageView(
                data: widget.user["id"].toString(),
                size:120,
              ),

              SizedBox(height:20),

              Container(
                height:200,

                child: LineChart(

                  LineChartData(

                    lineBarsData: [

                      LineChartBarData(
                        spots: getChartData(),
                        isCurved: true,
                        barWidth: 4,
                        color: Colors.indigo,
                      )

                    ]

                  ),

                ),

              ),

              SizedBox(height:20),

              ElevatedButton(

                child: Text("Send Money"),

                onPressed: (){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PinScreen(

                        onSuccess: (){

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransferScreen(user: widget.user),
                            ),
                          );

                        },

                      ),
                    ),
                  );

                },

              ),

              SizedBox(height:20),

              ListView.builder(

                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: transactions.length,

                itemBuilder: (context,index){

                  final t = transactions[index];

                  return Card(

                    child: ListTile(

                      leading: Icon(
                        t["type"]=="transfer"
                        ? Icons.arrow_upward
                        : Icons.arrow_downward
                      ),

                      title: Text("\$${t["amount"]}"),
                      subtitle: Text(t["type"]),

                    ),

                  );

                },

              )

            ],

          ),
        ),
      ),
    );
  }
}

class PinScreen extends StatefulWidget {

  final Function onSuccess;

  PinScreen({required this.onSuccess});

  @override
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>{

  final pinController = TextEditingController();

  void checkPin(){

    if(pinController.text=="1234"){

      Navigator.pop(context);
      widget.onSuccess();

    }else{

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wrong PIN"))
      );

    }

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: Text("Enter PIN")),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: pinController,
              obscureText: true,
              maxLength:4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText:"PIN"),
            ),

            ElevatedButton(
              onPressed: checkPin,
              child: Text("Verify"),
            )

          ],
        ),
      ),
    );
  }
}

class TransferScreen extends StatefulWidget{

  final Map user;

  TransferScreen({required this.user});

  @override
  _TransferScreenState createState()=>_TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>{

  final receiverController = TextEditingController();
  final amountController = TextEditingController();

  void transfer() async{

    final response = await http.post(
      Uri.parse("$baseUrl/transactions/transfer"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "sender_id":widget.user["id"],
        "receiver_id":int.parse(receiverController.text),
        "amount":double.parse(amountController.text)
      })
    );

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data["message"]))
    );

  }

  void scanQR() async{

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
    );

    if(result!=null){
      receiverController.text=result;
    }

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: Text("Transfer")),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: receiverController,
              decoration: InputDecoration(labelText:"Receiver ID"),
            ),

            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText:"Amount"),
            ),

            SizedBox(height:20),

            ElevatedButton(
              onPressed: scanQR,
              child: Text("Scan QR"),
            ),

            ElevatedButton(
              onPressed: transfer,
              child: Text("Send"),
            )

          ],
        ),
      ),
    );
  }
}

class ScanPage extends StatelessWidget{

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: Text("Scan QR")),

      body: MobileScanner(

        onDetect: (capture){

          final barcodes = capture.barcodes;

          for(final barcode in barcodes){

            final code = barcode.rawValue;

            if(code!=null){
              Navigator.pop(context,code);
              break;
            }

          }

        },

      ),

    );
  }
}