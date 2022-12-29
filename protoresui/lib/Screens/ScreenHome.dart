import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
String result = "0";
class HomeScreen extends StatefulWidget {
   HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    List<CreateRowWidget> rowlist = [];

  addRow()
    {
      rowlist.add( CreateRowWidget());
      setState((){});
      print(rowlist);
    }

  @override
  Widget build(BuildContext context) {
    final one = MediaQuery.of(context).size.width;
    final two = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              Flexible(
                child: Container(
                  height: double.infinity,
                  width: 500,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          color: Colors.grey,
                          height: double.infinity,
                          width: double.infinity,                              
                          child: const Text("A NAME",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35 ),textAlign: TextAlign.center,))),
                
                      Flexible(
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,   
                          color: Colors.purple,
                          child: Column(
                          children: [
                            TextButton(onPressed: (){}, child: const Text("Generate Lists",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 20))),
                            TextButton(onPressed: (){}, child: const Text("Previous Lists",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 20))),
                            TextButton(onPressed: (){}, child: const Text("Generate",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 20))),  
                            Text(one.toString()),
                            Text(two.toString()),                    
                          ],
                          ),
                        ),
                      ),
                
                
                
                      Flexible(
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.blueGrey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:const [
                               Text("Exam Hall",style: TextStyle(fontWeight: FontWeight.w200,fontSize: 15 ),textAlign: TextAlign.left,),
                               Text("Seat Allocator",style: TextStyle(fontWeight: FontWeight.w200,fontSize: 15 ),textAlign: TextAlign.left,),
                                Text("By ProtoRes",style: TextStyle(fontWeight: FontWeight.w200,fontSize: 15 ),textAlign: TextAlign.center,),                       
                            ],
                          ),
                        ),
                      ),
                 
                
                    ],
                  ),
                ),
              ),
          
      
              Flexible(
                flex: 3,
                child: Container(
                  color: Colors.brown,
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    
                    children: [
                        
                      //Child two
                      const SizedBox(height: 10,),
                        
                      //Child three
                      Flexible(
                        child: ToggleSwitch(
                          initialLabelIndex: 0,
                          cornerRadius: 15,
                          minWidth: 225,
                          
                          fontSize: 18,
                          radiusStyle: true,
                          inactiveBgColor: const Color(0xFF2B2D2E),
                          inactiveFgColor: Colors.white,
                          labels: const ["Halls","Subject"],
                          onToggle: (index){result = index.toString();},
                        ),
                      ),
                        
                      //Child four
                      const SizedBox(height: 10,),
                        
                      //child five
                      Flexible(
                        child: Container(
                          height: 900,
                          width: 600,
                          child: ListView.builder(
                              //scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: rowlist.length,
                              itemBuilder: (context,index)=>rowlist[index]),
                        ),
                      ),
                      //Child Six
                      ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(primary: const Color(0xFFF5A8FA),minimumSize: Size(50, 50)), child: const Text("Submit",style: TextStyle(color: Colors.black),),)
                        
                    ],
                  )               
                  ),
              ),
          
          
          
              
            ],
          ),
        )),
      floatingActionButton: FloatingActionButton(onPressed: () {addRow();},child: const Icon(Icons.add),),
    );
  }
}





class CreateRowWidget extends StatefulWidget {
  const CreateRowWidget({Key? key}) : super(key: key);

  @override
  State<CreateRowWidget> createState() => _CreateRowWidgetState();
}

class _CreateRowWidgetState extends State<CreateRowWidget> {

  TextEditingController control1 = TextEditingController();
  TextEditingController control2 = TextEditingController();
  TextEditingController control3 = TextEditingController();
  bool cond = true;

  switching(val)
  {
    if (val==0)
    {
      cond = false;
      setState(() {});
    }
    else
    {
      cond = true;
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return 
     Column(
       children: [
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          
              children: [
                  Flexible(
                    child: TextFormField(enabled: cond,controller: control1,decoration: const InputDecoration(border: OutlineInputBorder(),labelText: "Field1",),)),
                           
                  const SizedBox(width :10),
                  Flexible(
                    child: TextFormField(enabled: cond,controller: control2,decoration: const InputDecoration(border: OutlineInputBorder(),labelText: "Field2",),)),
                  const SizedBox(width :10),
                  Flexible(
                    child: TextFormField(enabled: cond,controller: control3,decoration: const InputDecoration(border: OutlineInputBorder(),labelText: "Field3",),)),

                  IconButton(onPressed: (){switching(1);}, icon: const Icon(Icons.edit_outlined)),
                  IconButton(onPressed: (){switching(0);}, icon: const Icon(Icons.arrow_forward_outlined)),
                    ],
                    ),

       SizedBox(height: 10,),
       ],
     );
  }
}