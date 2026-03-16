import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/core/constants/colors.dart';
import '../../data/models/poll_model.dart';
import '../../data/repositories/polls_firebase_repository.dart';
import 'poll_detail_screen.dart';
import 'create_poll_screen.dart';
import 'join_poll_screen.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({Key? key}) : super(key: key);

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = PollsFirebaseRepository();
  List<Poll> _allPolls = [];
  bool _loading = true;
  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dateFormat = DateFormat('dd MMM yyyy', 'es');
    _loadPolls();
  }

  Future<void> _loadPolls() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final polls = await _repository.getPollsForUser(user.uid);
        if (mounted) {
          setState(() {
            _allPolls = polls;
            _loading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('PollsScreen._loadPolls error: $e');
    }
    // Not authenticated or error: show empty list.
    if (mounted) {
      setState(() {
        _allPolls = [];
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Poll> get _activePolls {
    return _allPolls.where((p) => p.isActive).toList();
  }

  List<Poll> get _finishedPolls {
    return _allPolls.where((p) => p.isFinished).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'POLLAS FUTBOLERAS',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.kYellowAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JoinPollScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kYellowAccent,
          labelColor: AppColors.kYellowAccent,
          unselectedLabelColor: AppColors.kGrey,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'ACTIVAS'),
            Tab(text: 'FINALIZADAS'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.kYellowAccent))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildPollsList(_activePolls),
          _buildPollsList(_finishedPolls),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePollScreen()),
          );
          if (result == true) _loadPolls();
        },
        backgroundColor: AppColors.kYellowAccent,
        icon: const Icon(Icons.add, color: AppColors.kBlack),
        label: Text(
          'Crear Polla',
          style: TextStyle(
            color: AppColors.kBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPollsList(List<Poll> polls) {
    if (polls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.poll,
              size: 64,
              color: AppColors.kGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay pollas disponibles',
              style: TextStyle(
                color: AppColors.kGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: polls.length,
      itemBuilder: (context, index) {
        return _buildPollCard(polls[index]);
      },
    );
  }

  Widget _buildPollCard(Poll poll) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PollDetailScreen(pollId: poll.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: poll.isActive
                ? AppColors.kYellowAccent.withOpacity(0.3)
                : AppColors.kGrey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: poll.isActive
                        ? AppColors.kYellowAccent.withOpacity(0.2)
                        : AppColors.kGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    poll.isActive ? 'ACTIVA' : 'FINALIZADA',
                    style: TextStyle(
                      color: poll.isActive ? AppColors.kYellowAccent : AppColors.kGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.kGrey,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              poll.name,
              style: TextStyle(
                color: AppColors.kWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              poll.description,
              style: TextStyle(
                color: AppColors.kGreyLight,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: AppColors.kGrey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      poll.creatorName,
                      style: TextStyle(
                        color: AppColors.kGreyLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.group, color: AppColors.kYellowAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${poll.participantCount} participantes',
                      style: TextStyle(
                        color: AppColors.kYellowAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.kGrey, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Creada: ${_dateFormat.format(poll.createdAt)}',
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 11,
                  ),
                ),
                if (poll.leagueName != null) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.sports_soccer, color: AppColors.kGrey, size: 13),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      poll.leagueName!,
                      style: TextStyle(color: AppColors.kGrey, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
