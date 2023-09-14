import 'package:ehsa_frontend/constants/contributordata.dart';
import 'package:ehsa_frontend/widgets/stateless/contributor_tile.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContributorGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 1;

    double width = 2000;

    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 350) {
      crossAxisCount = 1; // Display 3 columns on desktop size
      width = 400;
    }

    if (screenWidth > 750) {
      crossAxisCount = 2; // Display 3 columns on desktop size
      width = 700;
    }

    if (screenWidth > 900) {
      crossAxisCount = 3; // Display 3 columns on desktop size
      width = 1000;
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.170,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EHSA',
                  style: TextStyle(
                    height: 1,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "by protoRes",
                  style: TextStyle(
                    height: 0.8,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  "Contributors",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width,
            child: Scrollbar(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 2.9,
                ),
                itemCount: CONTRIBUTOR_DATA.length,
                itemBuilder: (context, index) {
                  return GridItem(data: CONTRIBUTOR_DATA[index]);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final dynamic data;

  const GridItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrl(Uri.parse(data.profile));
      },
      child: ContributorTile(
        name: data.name,
        role: data.role,
        profile: data.profile,
        avatar: data.avatar,
      ),
    );
  }
}
