import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';




//HOME SCREEN
class MaybeScreen extends StatefulWidget {
  const MaybeScreen({Key? key}) : super(key: key);
  @override
  State<MaybeScreen> createState() => _MaybeScreenState();
}

class _MaybeScreenState extends State<MaybeScreen> {
  @override
  Widget build(BuildContext context) {
    String result = "0";
    final swidth = MediaQuery.of(context).size.width;
    final sheight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: SafeArea(
        child: Row(
          children: [

            //Row ONE
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.all(const Radius.circular(30)),color: Colors.white),
                  height: sheight*0.99,
                  width: swidth*0.29,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:  [
                       Flexible(
                         child: Container(
                          //color: Colors.yellow,
                          height: sheight*0.33,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const[
                               Flexible(child: Text("A NAME",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 40 ),textAlign: TextAlign.center,)),
                            ],
                          )),
                       ),
                       
                       Flexible(
                         child: Container(
                          height: sheight*0.33,
                          //color: Colors.green,
                           child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                             children: [
                               Flexible(child: TextButton(onPressed: (){}, child: const Text("Generate Lists",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 30)))),
                               Flexible(child: TextButton(onPressed: (){}, child: const Text("Previous Lists",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 30)))),
                               Flexible(child: TextButton(onPressed: (){}, child: const Text("Generate",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 30)))),
                             ],
                           ),
                         ),
                       ), 


                     
                
                       Flexible(
                         child: Container(
                          height: sheight*0.3,
                          //color: Colors.purple,
                           child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.stretch,
                             children:const [
                                Flexible(child: Text("Exam Hall Seat Allocator",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 20 ),textAlign: TextAlign.center,)),
                                Flexible(child: Text("By ProtoRes",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 20 ),textAlign: TextAlign.left,)),
                             ],
                           ),
                         ),
                       ),
                    ],
                
                  )),
              ),
            ),


            //Row TWO
            Container(
              //color: Colors.blue,
              height: sheight,
              width: swidth*0.7,
              child: GenerateList(widths: (swidth*0.7), heights: sheight,),

              ),
          ],
        ),
      ),

    );
  }
}



//ROW CREATION WIDGET
class CreateRowWidget extends StatefulWidget {
  CreateRowWidget({Key? key}) : super(key: key);

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
        SizedBox(height: 10,),
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






//RIGHT WIDGET 1(hall LIST)

class GenerateList extends StatelessWidget {
  
  final double widths;
  final double heights;
  GenerateList({super.key, required this.widths, required this.heights});
  String result ="0";
  List<CreateRowWidget> rowlist = [];
  
  @override
  Widget build(BuildContext context) {
        return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        //color: Colors.amber,
        decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.all(const Radius.circular(30)),color: Colors.white),
        child:
        
        Column(
          children: [

            //Column ONE
            Flexible(
              child: Container(
                height: heights*0.2,
                alignment: Alignment.center,
                child: Text("Lists Generator",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 40 ),textAlign: TextAlign.center,))),

            const Flexible(child: SizedBox(height: 15,)),


            //Column TWO
            Flexible(
              child: Container(
                child: ToggleSwitch(
                  initialLabelIndex: 0,
                  cornerRadius: 15,
                  minWidth: widths*0.4,
                  minHeight: 45,
                  fontSize: 18,
                  radiusStyle: true,
                  inactiveBgColor: const Color(0xFF2B2D2E),
                  inactiveFgColor: Colors.white,
                  labels: const ["Halls","Subject"],
                  onToggle: (index){result = index.toString();},
                  
                ),
              ),
            ),


            //Column THREE
            StatefulBuilder(
              builder: (context,addRow) {
                return Flexible(
                  flex: 10,
                  child: Column(
                    children: [
                      Flexible(
                        child: Container(
                          height:heights*0.1,
                          child: TextButton.icon(onPressed:((){
                            addRow(() => rowlist.add(CreateRowWidget()),);
                          }), icon: const Icon(Icons.add), label: const Text("Add Halls")))),
                
                
                      //Column FOUR
                      Flexible(
                        flex: 10,
                        child: Container(
                        height:heights*0.7,
                        width:widths*0.8,
                        child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: rowlist.length,
                        itemBuilder: (context,index)=>rowlist[index]),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),

            //Column FIVE
            const Flexible(
             
              child: SizedBox(height: 15,)),


            //Column SIX
              Flexible(
                
                child: Container(
                  height: 50,
                  child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.send), label: const Text("Submit")))),


          ],
        ),
        


      ),
    );
    
  }
}