import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/team_model.dart';
import '../../data/repositories/teams_firestore_repository.dart';

class TeamsListScreen extends StatefulWidget {
  const TeamsListScreen({Key? key}) : super(key: key);

  @override
  State<TeamsListScreen> createState() => _TeamsListScreenState();
}

class _TeamsListScreenState extends State<TeamsListScreen> {
  final _repository = TeamsFirestoreRepository();
  List<Team> _teams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final teams = await _repository.getTeamsForUser(user.uid);
    if (mounted) {
      setState(() {
        _teams = teams;
        _loading = false;
      });
    }
  }

  void _createTeam() {
    Get.toNamed('/create_team_screen')?.then((_) => _loadTeams());
  }

  void _viewTeamDetail(Team team) {
    Get.toNamed('/team_detail_screen', arguments: team)
        ?.then((_) => _loadTeams());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Mis Equipos',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.kYellowAccent),
            onPressed: _createTeam,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.kYellowAccent))
          : RefreshIndicator(
              color: AppColors.kYellowAccent,
              onRefresh: _loadTeams,
              child: _teams.isEmpty ? _buildEmptyState() : _buildList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTeam,
        backgroundColor: AppColors.kYellowAccent,
        child: const Icon(Icons.add, color: AppColors.kBlack),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups, size: 80, color: AppColors.kGrey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No tienes equipos aún.\nCrea uno con el botón +',
            style: TextStyle(color: AppColors.kGrey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _teams.length,
      itemBuilder: (context, index) => _buildTeamCard(_teams[index]),
    );
  }

  Widget _buildTeamCard(Team team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.kYellowAccent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.groups, color: AppColors.kYellowAccent),
        ),
        title: Text(
          team.name,
          style: const TextStyle(
            color: AppColors.kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${team.sport} • ${team.playerIds.length} jugadores',
          style: const TextStyle(color: AppColors.kGrey, fontSize: 13),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.kGrey),
        onTap: () => _viewTeamDetail(team),
      ),
    );
  }
}
