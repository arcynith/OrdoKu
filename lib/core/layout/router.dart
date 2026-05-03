import 'package:go_router/go_router.dart';
import 'package:ordoku/features/file_manager/ui/home_screen.dart';
import 'package:ordoku/features/writer/ui/writer_screen.dart';
import 'package:ordoku/features/sheet/ui/sheet_screen.dart';
import 'package:ordoku/features/slides/ui/slides_screen.dart';
import 'package:ordoku/features/design/ui/design_screen.dart';
import 'package:ordoku/features/notes/ui/notes_screen.dart';
import 'package:ordoku/features/pdf_viewer/ui/pdf_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/writer',
      builder: (context, state) {
        final filePath = state.extra as String?;
        return WriterScreen(filePath: filePath);
      },
    ),
    GoRoute(
      path: '/sheet',
      builder: (context, state) {
        final filePath = state.extra as String?;
        return SheetScreen(filePath: filePath);
      },
    ),
    GoRoute(
      path: '/slides',
      builder: (context, state) {
        final filePath = state.extra as String?;
        return SlidesScreen(filePath: filePath);
      },
    ),
    GoRoute(
      path: '/design',
      builder: (context, state) {
        final filePath = state.extra as String?;
        return DesignScreen(filePath: filePath);
      },
    ),
    GoRoute(
      path: '/notes',
      builder: (context, state) {
        final filePath = state.extra as String?;
        return NotesScreen(filePath: filePath);
      },
    ),
    GoRoute(
      path: '/pdf',
      builder: (context, state) {
        final filePath = state.extra as String?;
        return PdfScreen(filePath: filePath);
      },
    ),
  ],
);
