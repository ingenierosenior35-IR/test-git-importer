import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/core/constants/colors.dart';
import '../../data/models/espn_models.dart';
import '../../data/models/poll_model.dart';
import '../../data/datasources/espn_api_service.dart';
import '../../data/repositories/polls_firebase_repository.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({Key? key}) : super(key: key);

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _espnService = EspnApiService();
  final _repository = PollsFirebaseRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step tracking
  int _step = 0; // 0 = select league, 1 = configure & create

  // Step 0 state
  EspnLeague? _selectedLeague;
  bool _loadingLeagueData = false;
  List<EspnTeam> _teams = [];
  List<EspnEvent> _fixtures = [];
  String? _leagueError;

  // Step 1 state
  bool _saving = false;

  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat('EEE dd MMM, HH:mm', 'es');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onLeagueSelected(EspnLeague league) async {
    setState(() {
      _selectedLeague = league;
      _loadingLeagueData = true;
      _leagueError = null;
      _teams = [];
      _fixtures = [];
    });

    final results = await Future.wait([
      _espnService.getTeams(league.slug),
      _espnService.getScoreboard(league.slug),
    ]);

    if (!mounted) return;

    final teams = results[0] as List<EspnTeam>;
    final fixtures = results[1] as List<EspnEvent>;

    setState(() {
      _loadingLeagueData = false;
      _teams = teams;
      _fixtures = fixtures;
      if (teams.isEmpty && fixtures.isEmpty) {
        _leagueError = 'No se encontraron datos para esta liga en este momento.';
      }
      // Pre-fill poll name
      if (_nameController.text.isEmpty) {
        _nameController.text = 'Polla ${league.name}';
      }
    });
  }

  void _goToStep1() {
    if (_selectedLeague == null) {
      Get.snackbar('Selecciona una liga', 'Elige una liga para continuar.',
          backgroundColor: AppColors.kDarkCard,
          colorText: AppColors.kWhite,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final userName = user?.displayName ?? user?.email ?? 'Usuario';

    setState(() => _saving = true);

    try {
      final joinCode = PollsFirebaseRepository.generateJoinCode();
      final poll = Poll(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        creatorId: userId,
        creatorName: userName,
        createdAt: DateTime.now(),
        participantIds: [userId],
        status: 'active',
        leagueSlug: _selectedLeague?.slug,
        leagueName: _selectedLeague?.name,
        fixtures: _fixtures,
        joinCode: joinCode,
      );

      await _repository.createPoll(poll);

      if (!mounted) return;

      Get.snackbar(
        '¡Polla creada!',
        'Código de invitación: $joinCode',
        backgroundColor: AppColors.kYellowAccent.withOpacity(0.95),
        colorText: AppColors.kBlack,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'No se pudo crear la polla. Inténtalo de nuevo.',
        backgroundColor: AppColors.kError,
        colorText: AppColors.kWhite,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.kWhite),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _step == 0 ? 'SELECCIONAR LIGA' : 'CREAR POLLA',
          style: const TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _step == 0 ? _buildStepLeague() : _buildStepConfigure(),
    );
  }

  // ─── Step 0: League selection ────────────────────────────────────────────

  Widget _buildStepLeague() {
    return Column(
      children: [
        // Step indicator
        _buildStepIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Elige la liga o torneo',
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Los partidos se traerán automáticamente desde ESPN',
                style: TextStyle(color: AppColors.kGreyLight, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...EspnLeague.popularLeagues.map(_buildLeagueTile),
              if (_leagueError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.kError.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kError.withOpacity(0.4)),
                  ),
                  child: Text(
                    _leagueError!,
                    style: TextStyle(color: AppColors.kError, fontSize: 13),
                  ),
                ),
              ],
              if (_loadingLeagueData) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(color: AppColors.kYellowAccent),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Cargando equipos y partidos…',
                    style: TextStyle(color: AppColors.kGreyLight, fontSize: 13),
                  ),
                ),
              ],
              if (_selectedLeague != null && !_loadingLeagueData && _fixtures.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildFixturesPreview(),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
        // Bottom action button
        _buildBottomBar(
          label: 'SIGUIENTE',
          enabled: _selectedLeague != null && !_loadingLeagueData,
          onPressed: _goToStep1,
        ),
      ],
    );
  }

  Widget _buildLeagueTile(EspnLeague league) {
    final isSelected = _selectedLeague?.slug == league.slug;
    return GestureDetector(
      onTap: () => _onLeagueSelected(league),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kYellowAccent.withOpacity(0.15) : AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.kYellowAccent : AppColors.kDarkSurface,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.sports_soccer,
              color: isSelected ? AppColors.kYellowAccent : AppColors.kGrey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                league.name,
                style: TextStyle(
                  color: isSelected ? AppColors.kYellowAccent : AppColors.kWhite,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.kYellowAccent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFixturesPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event, color: AppColors.kYellowAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              'Próximas jornadas (${_fixtures.length} partidos)',
              style: const TextStyle(
                color: AppColors.kWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._fixtures.take(5).map(_buildFixtureCard),
        if (_fixtures.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+ ${_fixtures.length - 5} partidos más incluidos',
              style: TextStyle(color: AppColors.kGreyLight, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildFixtureCard(EspnEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kDarkSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.week != null)
            Text(
              'Jornada ${event.week}',
              style: TextStyle(color: AppColors.kGrey, fontSize: 11),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  event.homeTeam.displayName,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'vs',
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  event.awayTeam.displayName,
                  style: const TextStyle(color: AppColors.kWhite, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _dateFormat.format(event.date.toLocal()),
            style: TextStyle(color: AppColors.kGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Configure & create ─────────────────────────────────────────

  Widget _buildStepConfigure() {
    return Column(
      children: [
        _buildStepIndicator(),
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // League summary chip
                if (_selectedLeague != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.kYellowAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.kYellowAccent.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_soccer, color: AppColors.kYellowAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedLeague!.name,
                            style: const TextStyle(
                              color: AppColors.kYellowAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${_fixtures.length} partidos',
                          style: TextStyle(color: AppColors.kGreyLight, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Poll name
                _buildLabel('Nombre de la Polla'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Ej: La Liga 2024 - Amigos',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 20),

                // Description
                _buildLabel('Descripción'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Describe de qué trata esta polla…',
                  maxLines: 3,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Ingresa una descripción' : null,
                ),
                const SizedBox(height: 24),

                // Fixtures summary
                if (_fixtures.isNotEmpty) ...[
                  _buildLabel('Partidos incluidos (${_fixtures.length})'),
                  const SizedBox(height: 8),
                  ..._fixtures.map(_buildFixtureCard),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomBar(
          label: 'CREAR POLLA',
          enabled: !_saving,
          onPressed: _createPoll,
          loading: _saving,
        ),
      ],
    );
  }

  // ─── Shared helpers ──────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Container(
      color: AppColors.kDarkCard,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _stepDot(label: '1', active: _step == 0, done: _step > 0),
          Expanded(
            child: Container(
              height: 2,
              color: _step > 0
                  ? AppColors.kYellowAccent
                  : AppColors.kDarkSurface,
            ),
          ),
          _stepDot(label: '2', active: _step == 1, done: false),
        ],
      ),
    );
  }

  Widget _stepDot({required String label, required bool active, required bool done}) {
    Color bg = done
        ? AppColors.kYellowAccent
        : active
            ? AppColors.kYellowAccent
            : AppColors.kDarkSurface;
    Color fg = (active || done) ? AppColors.kBlack : AppColors.kGrey;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: AppColors.kBlack, size: 16)
            : Text(
                label,
                style: TextStyle(
                    color: fg, fontSize: 13, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: AppColors.kWhite, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.kWhite),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.kGrey),
        filled: true,
        fillColor: AppColors.kDarkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kDarkSurface, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kYellowAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kError, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildBottomBar({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
    bool loading = false,
  }) {
    return Container(
      color: AppColors.kDarkBackground,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kYellowAccent,
          disabledBackgroundColor: AppColors.kDarkSurface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.kBlack,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: AppColors.kBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}

