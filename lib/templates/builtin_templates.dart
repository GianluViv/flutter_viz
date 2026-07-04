import 'package:flutter/material.dart';
import 'package:flutter_viz/model/widget_model.dart';
import 'package:flutter_viz/templates/page_template.dart';
import 'package:flutter_viz/templates/template_builder.dart';
import 'package:flutter_viz/templates/template_theme.dart';
import 'package:flutter_viz/utils/AppConstant.dart';

/// Built-in page templates, authored as real widget trees. Every template uses
/// [kTemplateBaseColor] as its brand color so the wizard's theme picker can
/// recolor it. Layouts are inspired by the classic FlutterViz starter screens
/// (Login, Register, Welcome, Profile, Settings, List, Detail, Contact, About).

const Color _brand = kTemplateBaseColor;
const Color _white = Color(0xFFFFFFFF);
const Color _textDark = Color(0xFF212435);
const Color _textGrey = Color(0xFF9E9E9E);
const Color _cardBg = Color(0xFFF7F8FC);

const String _avatar = 'https://i.pravatar.cc/300';
const String _photo = 'https://picsum.photos/seed/flutterviz/600/400';

List<PageTemplate> builtinTemplates() {
  return [
    PageTemplate(id: 'builtin_login', category: 'Auth', name: 'Login', builtin: true, screenJsonData: _login()),
    PageTemplate(id: 'builtin_register', category: 'Auth', name: 'Register', builtin: true, screenJsonData: _register()),
    PageTemplate(id: 'builtin_welcome', category: 'Onboarding', name: 'Welcome', builtin: true, screenJsonData: _welcome()),
    PageTemplate(id: 'builtin_splash', category: 'Onboarding', name: 'Splash', builtin: true, screenJsonData: _splash()),
    PageTemplate(id: 'builtin_profile', category: 'Profilo', name: 'Profile', builtin: true, screenJsonData: _profile()),
    PageTemplate(id: 'builtin_settings', category: 'Profilo', name: 'Settings', builtin: true, screenJsonData: _settings()),
    PageTemplate(id: 'builtin_list', category: 'Contenuti', name: 'List', builtin: true, screenJsonData: _list()),
    PageTemplate(id: 'builtin_detail', category: 'Contenuti', name: 'Detail', builtin: true, screenJsonData: _detail()),
    PageTemplate(id: 'builtin_contact', category: 'Contenuti', name: 'Contact Us', builtin: true, screenJsonData: _contact()),
    PageTemplate(id: 'builtin_about', category: 'Contenuti', name: 'About Us', builtin: true, screenJsonData: _about()),
  ];
}

EdgeInsets _pad([double h = 28, double v = 32]) => EdgeInsets.symmetric(horizontal: h, vertical: v);

// ---------------------------------------------------------------------------

String _login() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(28, 44),
    children: [
      tRow(mainAxisAlignment: AxisAlignmentCenter, children: [tCircleImage(networkUrl: _avatar, radius: 52)]),
      tSizedBox(height: 24),
      tText('Login', fontSize: 30, fontWeight: FontWeightTypeBold, color: _textDark, textAlign: TextAlign.center),
      tSizedBox(height: 28),
      tTextField(hintText: 'Enter Email', prefixIcon: Icons.email_outlined),
      tSizedBox(height: 16),
      tTextField(hintText: 'Enter Password', obscureText: true, prefixIcon: Icons.lock_outline),
      tSizedBox(height: 10),
      tText('Forgot Password?', color: _brand, fontWeight: FontWeightTypeMedium, textAlign: TextAlign.end),
      tSizedBox(height: 26),
      tButton('Login', bgColor: _brand, fullWidth: true),
      tSizedBox(height: 20),
      tRow(mainAxisAlignment: AxisAlignmentCenter, children: [
        tText("Don't have an account? ", color: _textGrey),
        tText('Sign Up', color: _brand, fontWeight: FontWeightTypeBold),
      ]),
    ],
  );
  return buildScreenJson(root: root, scaffoldColor: _white);
}

String _register() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(28, 40),
    children: [
      tSizedBox(height: 8),
      tText("Let's Get Started!", fontSize: 26, fontWeight: FontWeightTypeBold, color: _brand),
      tSizedBox(height: 8),
      tText('Create an account and start creating.', color: _textGrey, fontSize: 14),
      tSizedBox(height: 28),
      tTextField(hintText: 'Name', prefixIcon: Icons.person_outline),
      tSizedBox(height: 16),
      tTextField(hintText: 'Email Address', prefixIcon: Icons.email_outlined),
      tSizedBox(height: 16),
      tTextField(hintText: 'Password', obscureText: true, prefixIcon: Icons.lock_outline),
      tSizedBox(height: 16),
      tTextField(hintText: 'Confirm Password', obscureText: true, prefixIcon: Icons.lock_outline),
      tSizedBox(height: 26),
      tButton('Sign Up', bgColor: _brand, fullWidth: true),
      tSizedBox(height: 20),
      tRow(mainAxisAlignment: AxisAlignmentCenter, children: [
        tText('Already have an account? ', color: _textGrey),
        tText('Login', color: _brand, fontWeight: FontWeightTypeBold),
      ]),
    ],
  );
  return buildScreenJson(root: root, scaffoldColor: _white);
}

String _welcome() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(28, 48),
    children: [
      tRow(mainAxisAlignment: AxisAlignmentCenter, children: [
        tText('Flutter', fontSize: 26, fontWeight: FontWeightTypeBold, color: _textDark),
        tText('Viz', fontSize: 26, fontWeight: FontWeightTypeBold, color: _brand),
      ]),
      tSizedBox(height: 28),
      tText('Welcome to FlutterViz', fontSize: 20, fontWeight: FontWeightTypeBold, color: _textDark, textAlign: TextAlign.center),
      tSizedBox(height: 10),
      tText('To make attractive UI designs using FlutterViz.', color: _textGrey, textAlign: TextAlign.center),
      tSizedBox(height: 28),
      tRow(mainAxisAlignment: AxisAlignmentCenter, children: [tImage(networkUrl: _photo, width: 240, height: 180)]),
      tSizedBox(height: 36),
      tButton('Sign In', bgColor: _brand, fullWidth: true),
      tSizedBox(height: 14),
      tButton('Sign Up', bgColor: _white, textColor: _brand, borderColor: _brand, borderWidth: 1.5, fullWidth: true),
    ],
  );
  return buildScreenJson(root: root, scaffoldColor: _white);
}

String _splash() {
  final root = tColumn(
    mainAxisAlignment: AxisAlignmentCenter,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(32, 40),
    children: [
      tRow(mainAxisAlignment: AxisAlignmentCenter, children: [
        tContainer(
          bgColor: _white,
          shape: BoxShapeTypeCircle,
          width: 110,
          height: 110,
          alignment: AlignmentTypeCenter,
          children: [tIcon(Icons.bolt, color: _brand, size: 56)],
        ),
      ]),
      tSizedBox(height: 32),
      tText('We Have Special Food', fontSize: 24, fontWeight: FontWeightTypeBold, color: _white, textAlign: TextAlign.center),
      tSizedBox(height: 40),
      tRow(mainAxisAlignment: AxisAlignmentCenter, children: [
        tButton('Next', bgColor: _white, textColor: _brand, width: 160, borderRadius: 28),
      ]),
    ],
  );
  return buildScreenJson(root: root, scaffoldColor: _brand);
}

String _profile() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(20, 24),
    children: [
      tRow(mainAxisAlignment: AxisAlignmentSpaceBetween, children: [
        tIcon(Icons.arrow_back, color: _textDark),
        tText('Profile', fontSize: 18, fontWeight: FontWeightTypeBold, color: _textDark),
        tIcon(Icons.add, color: _textDark),
      ]),
      tSizedBox(height: 20),
      tRow(mainAxisAlignment: AxisAlignmentCenter, children: [tCircleImage(networkUrl: _avatar, radius: 50)]),
      tSizedBox(height: 14),
      tText('Rose', fontSize: 20, fontWeight: FontWeightTypeBold, color: _textDark, textAlign: TextAlign.center),
      tSizedBox(height: 4),
      tText('Las Vegas, USA', color: _textGrey, textAlign: TextAlign.center),
      tSizedBox(height: 22),
      tRow(mainAxisAlignment: AxisAlignmentSpaceEvenly, children: [
        _statCol('120', 'Post'),
        _statCol('500', 'Following'),
        _statCol('400', 'Followers'),
      ]),
      tSizedBox(height: 22),
      tButton('Follow', bgColor: _brand, fullWidth: true),
      tSizedBox(height: 24),
      tText('About', fontSize: 16, fontWeight: FontWeightTypeBold, color: _brand),
      tSizedBox(height: 8),
      tText('Lorem ipsum, or lipsum as it is sometimes known, is dummy text used in laying out print, graphic or web designs.', color: _textGrey, maxLines: 4),
    ],
  );
  return buildScreenJson(root: root, scaffoldColor: _white);
}

WidgetModel _statCol(String value, String label) {
  return tColumn(
    mainAxisSize: AxisMin,
    children: [
      tText(label, color: _textGrey, fontSize: 13),
      tSizedBox(height: 4),
      tText(value, color: _brand, fontSize: 18, fontWeight: FontWeightTypeBold),
    ],
  );
}

WidgetModel _settingsRow(IconData icon, String title) {
  return tContainer(
    fullWidth: true,
    padding: EdgeInsets.symmetric(vertical: 14),
    children: [
      tRow(mainAxisAlignment: AxisAlignmentSpaceBetween, children: [
        tRow(mainAxisSize: AxisMin, children: [
          tIcon(icon, color: _brand, size: 22),
          tSizedBox(width: 14),
          tText(title, color: _textDark, fontSize: 15),
        ]),
        tIcon(Icons.chevron_right, color: _textGrey, size: 22),
      ]),
    ],
  );
}

String _settings() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(20, 8),
    children: [
      tSizedBox(height: 8),
      tText('General Setting', color: _textGrey, fontSize: 13, fontWeight: FontWeightTypeMedium),
      _settingsRow(Icons.person_outline, 'Account'),
      tDivider(),
      _settingsRow(Icons.mail_outline, 'Gmail'),
      tDivider(),
      _settingsRow(Icons.sync, 'Sync Data'),
      tSizedBox(height: 16),
      tText('Network', color: _textGrey, fontSize: 13, fontWeight: FontWeightTypeMedium),
      _settingsRow(Icons.sim_card_outlined, 'Simcard & Network'),
      tDivider(),
      _settingsRow(Icons.wifi, 'Wi-fi'),
      tDivider(),
      _settingsRow(Icons.bluetooth, 'Bluetooth'),
    ],
  );
  return buildScreenJson(
    root: root,
    scaffoldColor: _white,
    appBar: tAppBar(title: 'Setting', backgroundColor: _brand, centerTitle: true),
  );
}

WidgetModel _listCard(String title, String subtitle, String price) {
  return tContainer(
    fullWidth: true,
    bgColor: _cardBg,
    borderRadius: 12,
    margin: EdgeInsets.only(bottom: 14),
    padding: EdgeInsets.all(10),
    children: [
      tRow(crossAxisAlignment: AxisAlignmentCenter, children: [
        tImage(networkUrl: _photo, width: 76, height: 76),
        tSizedBox(width: 12),
        tColumn(mainAxisSize: AxisMin, crossAxisAlignment: AxisAlignmentStart, expanded: true, children: [
          tText(title, color: _textDark, fontSize: 15, fontWeight: FontWeightTypeBold),
          tSizedBox(height: 4),
          tText(subtitle, color: _textGrey, fontSize: 12),
          tSizedBox(height: 6),
          tText(price, color: _brand, fontSize: 15, fontWeight: FontWeightTypeBold),
        ]),
        tIcon(Icons.more_vert, color: _textGrey, size: 20),
      ]),
    ],
  );
}

String _list() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(18, 16),
    children: [
      _listCard('Veg Frankie', 'In Signature Wraps', '\$26'),
      _listCard('Mexican Pasta', 'In Pasta', '\$12'),
      _listCard('Burger', 'In Burgers', '\$60'),
      _listCard('Paneer Masala', 'In Main Course', '\$80'),
    ],
  );
  return buildScreenJson(
    root: root,
    scaffoldColor: _white,
    appBar: tAppBar(title: 'Listing', backgroundColor: _white, textColor: _textDark, iconColor: _textDark),
  );
}

String _detail() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(20, 16),
    children: [
      tImage(networkUrl: _photo, fullWidth: true, height: 220),
      tSizedBox(height: 16),
      tRow(mainAxisAlignment: AxisAlignmentSpaceBetween, children: [
        tText('Sofa Set', fontSize: 20, fontWeight: FontWeightTypeBold, color: _textDark),
        tText('\$120', fontSize: 18, fontWeight: FontWeightTypeBold, color: _brand),
      ]),
      tSizedBox(height: 12),
      tText('Lorem ipsum, or lipsum as it is sometimes known, is dummy text used in laying out print, graphic or web designs. The passage is attributed to an unknown typesetter in the 15th century.', color: _textGrey, maxLines: 6),
      tSizedBox(height: 24),
      tButton('Add to cart', bgColor: _brand, fullWidth: true),
    ],
  );
  return buildScreenJson(
    root: root,
    scaffoldColor: _white,
    appBar: tAppBar(title: 'Details', backgroundColor: _white, textColor: _textDark, iconColor: _textDark, centerTitle: true),
  );
}

WidgetModel _contactRow(IconData icon, String text) {
  return tRow(mainAxisSize: AxisMin, children: [
    tIcon(icon, color: _brand, size: 20),
    tSizedBox(width: 12),
    tText(text, color: _textDark, fontSize: 14),
  ]);
}

String _contact() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(24, 32),
    children: [
      tText('Contact Us', fontSize: 26, fontWeight: FontWeightTypeBold, color: _brand),
      tSizedBox(height: 24),
      tContainer(
        fullWidth: true,
        borderRadius: 16,
        borderColor: _brand,
        borderWidth: 1.2,
        padding: EdgeInsets.all(18),
        children: [
          tColumn(mainAxisSize: AxisMin, crossAxisAlignment: AxisAlignmentStart, children: [
            _contactRow(Icons.phone, '+91 9876543210'),
            tSizedBox(height: 16),
            _contactRow(Icons.email_outlined, 'john@gmail.com'),
            tSizedBox(height: 16),
            _contactRow(Icons.location_on_outlined, '3554 Monroe Street, United States'),
          ]),
        ],
      ),
      tSizedBox(height: 20),
      tTextField(hintText: 'Name'),
      tSizedBox(height: 16),
      tTextField(hintText: 'Email'),
      tSizedBox(height: 16),
      tTextField(hintText: 'Message'),
      tSizedBox(height: 24),
      tButton('Send Message', bgColor: _brand, fullWidth: true),
    ],
  );
  return buildScreenJson(root: root, scaffoldColor: _white);
}

String _about() {
  final root = tColumn(
    scrollable: true,
    crossAxisAlignment: AxisAlignmentStretch,
    padding: _pad(20, 8),
    children: [
      tSizedBox(height: 8),
      _settingsRow(Icons.system_update, 'App Updates'),
      tDivider(),
      _settingsRow(Icons.policy_outlined, 'Data Policy'),
      tDivider(),
      _settingsRow(Icons.description_outlined, 'Terms of Use'),
      tDivider(),
      _settingsRow(Icons.code, 'Open Source Libraries'),
    ],
  );
  return buildScreenJson(
    root: root,
    scaffoldColor: _white,
    appBar: tAppBar(title: 'About', backgroundColor: _white, textColor: _textDark, iconColor: _textDark),
  );
}

