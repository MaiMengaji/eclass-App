import 'package:cached_network_image/cached_network_image.dart';
import 'package:eclass/provider/home_data_provider.dart';
import 'package:eclass/provider/visible_provider.dart';
import 'package:eclass/services/http_services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import '../common/apidata.dart';
import '../provider/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Widget drawerHeader(UserProfile user) {
    return DrawerHeader(
      child: Container(
        padding: EdgeInsets.all(1.0),
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 38.0,
              backgroundColor: Colors.white,
              backgroundImage: user.profileInstance.userImg == null
                  ? AssetImage("assets/placeholder/avatar.png")
                  : CachedNetworkImageProvider(
                      APIData.userImage + "${user.profileInstance.userImg}",
                    ),
            ),
            SizedBox(
              height: 5.0,
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                user.profileInstance.fname + " " + user.profileInstance.lname,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                user.profileInstance.email,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: user.profileInstance.email.length > 35
                      ? 11.0
                      : user.profileInstance.email.length > 20
                          ? 14
                          : 16.0,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF996E01),
              Color(0xFFeeb11b),
            ]),
        boxShadow: [
          BoxShadow(
            color: Color(0x1c2464).withOpacity(0.30),
            blurRadius: 15.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
    );
  }

  UserProfile user;

  @override
  Widget build(BuildContext context) {
    UserProfile user = Provider.of<UserProfile>(context);
    HomeDataProvider homeDataProvider = Provider.of<HomeDataProvider>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          drawerHeader(user),
          ListTile(
            title: Text(
              translate("Purchase_History"),
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/purchaseHistory");
            },
          ),
          ListTile(
            title: Text(
              translate("Blogs_"),
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/blogList");
            },
          ),
          ListTile(
            title: Text(
              translate("Language_"),
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/languageScreen");
            },
          ),
          ListTile(
            title: Text(
              translate("Currency_"),
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/currency");
            },
          ),
          ListTile(
            title: Text(
              translate("Downloads_"),
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/downloads");
            },
          ),
          ListTile(
            title: Text(
              translate("FAQ_"),
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/userFaq");
            },
          ),
          if (homeDataProvider.homeModel.settings.donationEnable == '1')
            ListTile(
              title: Text(
                translate("Donate_"),
                style: TextStyle(fontSize: 16.0),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/donate");
              },
            ),
          ListTile(
            trailing: Icon(
              Icons.share_sharp,
            ),
            title: Text(
              translate("Share_this_App"),
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();
              String appName = packageInfo.appName;
              String packageName = packageInfo.packageName;
              Navigator.pop(context);
              await Share.share(
                'Download $appName App \nhttps://play.google.com/store/apps/details?id=$packageName',
                subject: 'Download $appName App',
              );
            },
          ),
          logoutSection(Colors.yellow[800]),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool logoutLoading = false;
  //logout of current session
  Widget logoutSection(Color headingColor) {
    return Container(
      child: FlatButton(
        onPressed: () async {
          setState(() {
            logoutLoading = true;
          });
          bool result = await HttpService().logout();
          setState(() {
            logoutLoading = false;
          });
          if (result) {
            Provider.of<Visible>(context, listen: false).toggleVisible(false);
            Navigator.of(context).pushNamed('/SignIn');
          } else {
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text(translate("Logout_failed"))));
          }
        },
        child: logoutLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(headingColor),
              )
            : Text(
                translate("LOG_OUT"),
                style: TextStyle(
                    color: headingColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
