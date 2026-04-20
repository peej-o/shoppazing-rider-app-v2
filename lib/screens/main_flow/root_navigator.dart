import 'package:flutter/material.dart';
import 'home_screen.dart'; // Use regular HomeScreen
import 'dashboard_screen.dart';
import 'account_screen.dart';

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  int _selectedIndex = 0;

  static const List<String> _pageTitles = ['Orders', 'Dashboard', 'Account'];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(key: PageStorageKey('home')),
      const DashboardScreen(key: PageStorageKey('dashboard')),
      const AccountScreen(key: PageStorageKey('account')),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Color(0xFF00509D),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00509D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'home_screen.dart';
// import 'dashboard_screen.dart';
// import 'account_screen.dart';
// import '../../providers/order_providers.dart';

// class RootNavigatorRiverpod extends ConsumerStatefulWidget {
//   const RootNavigatorRiverpod({super.key});

//   @override
//   ConsumerState<RootNavigatorRiverpod> createState() =>
//       _RootNavigatorRiverpodState();
// }

// class _RootNavigatorRiverpodState extends ConsumerState<RootNavigatorRiverpod> {
//   int _selectedIndex = 0;

//   static const List<String> _pageTitles = ['Orders', 'Dashboard', 'Account'];

//   late final List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       const HomeScreen(key: PageStorageKey('home')),
//       const DashboardScreen(key: PageStorageKey('dashboard')),
//       const AccountScreen(key: PageStorageKey('account')),
//     ];
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final newOrdersCount = ref.watch(newOrdersCountProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_pageTitles[_selectedIndex]),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         titleTextStyle: const TextStyle(
//           color: Color(0xFF00509D),
//           fontSize: 20,
//           fontWeight: FontWeight.w500,
//         ),
//         actions: [
//           if (_selectedIndex == 0 && newOrdersCount > 0)
//             Container(
//               margin: const EdgeInsets.only(right: 16),
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 '$newOrdersCount',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: IndexedStack(index: _selectedIndex, children: _pages),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.delivery_dining),
//             label: 'Orders',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: const Color(0xFF00509D),
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
