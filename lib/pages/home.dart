import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const primaryColor = Color(0xff272343);
const sectionBgColor = Color(0xffF4F3F4);

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool loading = false;
  String buttonText = 'Paste Link';
  String searchVideoLink;

  void lookupLink(BuildContext context, String videoUrl) async {

    String APIKey = 'CTG7vBD8VNSxKFTLUNWMyCgOacRM8FIdklCGzyjo9GL2CajVnD';
    setState(() {
      buttonText = 'Fetching Video';
      loading = true;
    });
    var url = 'http://keepsaveit.com/api/?api_key=' + APIKey + '&url=' + videoUrl;
    print(url);

    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);

      setState(() {
        loading = false;
      });

      displayBottomSheet(
        context: context,
        thumbnailUrl: jsonResponse['response']['thumbnail'],
        title: jsonResponse['response']['title'],
        downloadUrl: jsonResponse['response']['links'][0]['url']
      );
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void displayBottomSheet({BuildContext context, String thumbnailUrl, String title, String downloadUrl}) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height  * 0.6,
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 223,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        image: NetworkImage(thumbnailUrl),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    title,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 40,),
                  FlatButton(
                    onPressed: () {
                      _launchURL(downloadUrl);
                    },
                    color: primaryColor,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _launchURL(String downloadUrl) async {
    if (await canLaunch(downloadUrl)) {
      await launch(downloadUrl);
    } else {
      throw 'Could not launch $downloadUrl';
    }
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;


    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            SafeArea(
              child: Container(
                padding: EdgeInsets.only(top: 22, left: 22, right: 22),
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Video Downloader',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30,),
                    TextField(
                      onChanged: (text) {
                        setState(() {
                          searchVideoLink = text;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        hintStyle: TextStyle(
                          color: primaryColor.withOpacity(0.8),
                          fontSize: 18,
                        ),
                        hintText: 'Paste video link here',
                        fillColor: sectionBgColor,
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: 20,),
                    FlatButton(
                      onPressed: () {
                        lookupLink(context, searchVideoLink);
                      },
                      color: primaryColor,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.5,
              builder: (BuildContext context, ScrollController controller) {
                return Container(
                  color: sectionBgColor,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 40, bottom: 10, left: 22, right: 22),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trending downloads',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
//                            Text(
//                              'View all',
//                              style: TextStyle(
//                                fontSize: 16,
//                              ),
//                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: GridView.count(
                            controller: controller,
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.5,
                            children: List.generate(100, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: (index % 2 == 0) ? AssetImage('assets/rihanna.jpg') : AssetImage('assets/malo.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            (loading) ? Container(
              color: Colors.grey.withOpacity(0.7),
              child: Center(child: CircularProgressIndicator()),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
