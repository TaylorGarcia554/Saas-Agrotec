import 'package:agrotec/analiseManual.dart';
import 'package:agrotec/historico.dart';
import 'package:agrotec/home.dart';
import 'package:agrotec/utils/cor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class Menuhome extends ConsumerStatefulWidget {
  const Menuhome({super.key});

  @override
  ConsumerState<Menuhome> createState() => _MenuhomeState();
}

class _MenuhomeState extends ConsumerState<Menuhome> {
  Widget _buildMenuItem(
    IconData icon,
    String? title,
    int index,
    bool collapsed,
  ) {
    final selectedIndex = ref.watch(navigationProvider);

    final size = MediaQuery.of(context).size;

    final bool temTitulo = title != null;

    return InkWell(
      onTap: () => ref.read(navigationProvider.notifier).setIndex(index),
      child: Container(
        decoration: BoxDecoration(
          color: selectedIndex == index
              // ? Color(0xff8f5c30)
              ? Cor.verdeForte
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Center(child: Icon(icon, color: Colors.black)),
              SizedBox(width: temTitulo ? 0 : 10),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: collapsed ? 0 : 120, // ajusta pro tamanho do texto
                  child: AnimatedOpacity(
                    opacity: collapsed ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      "  ${title!}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
              // if (title != null)
              //   Text(
              //     title,
              //     style: const TextStyle(
              //       color: Colors.white,
              //       fontSize: 16,
              //       fontFamily: 'Inter',
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Adicione inicializações aqui se necessário
  }

  @override
  Widget build(BuildContext context) {
    final _selectedIndex = ref.watch(navigationProvider);

    final size = MediaQuery.of(context).size;

    final bool tamanhoTela = size.width < 1000;

    return Scaffold(
      // backgroundColor: Color(0xff8f5c30),
      backgroundColor: Cor.verdeClaro,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // aumenta a altura do AppBar
        child: AppBar(
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        // Image.asset(
                        //   'assets/iconBusca.png',
                        //   height: 40,
                        // ),
                        const SizedBox(width: 10),
                        const Text(
                          'AgroTec',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // backgroundColor: Color(0xff8f5c30),
          backgroundColor: Cor.verdeForte,
          elevation: 10,
          shadowColor: Colors.black,
        ),
      ),
      body:
          // Padding(
          //   padding: EdgeInsets.all(size.height * 0.08),
          // child:
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: tamanhoTela ? 66 : 180, // alterna entre estreito e largo
                // color: Color(0xff38291a),
                color: Cor.verdeAgua,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildMenuItem(Icons.dashboard, "Início", 0, tamanhoTela),
                    _buildMenuItem(Icons.calculate, "Manual", 2, tamanhoTela),
                    // _buildMenuItem(Icons.history, "Historico", 1, tamanhoTela),
                  ],
                ),
              ),

              // conteúdo da página
              Expanded(
                child: switch (_selectedIndex) {
                  0 => const Home(),
                  1 => const Historico(),
                  2 => const ManualAnalysisScreen(),
                  _ => const Home(),
                },
              ),
            ],
          ),
    );
  }
}

class NavigationProvider extends StateNotifier<int> {
  NavigationProvider() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

final navigationProvider = StateNotifierProvider<NavigationProvider, int>((
  ref,
) {
  return NavigationProvider();
});
