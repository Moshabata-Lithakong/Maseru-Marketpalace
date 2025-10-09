import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class InterviewManagementScreen extends StatefulWidget {
  const InterviewManagementScreen({super.key});

  @override
  State<InterviewManagementScreen> createState() => _InterviewManagementScreenState();
}

class _InterviewManagementScreenState extends State<InterviewManagementScreen> {
  final List<Map<String, dynamic>> _interviews = [
    {
      'id': '1',
      'candidate': 'John Smith',
      'position': 'Vendor Manager',
      'date': '2024-01-25',
      'time': '10:00 AM',
      'status': 'scheduled',
      'interviewer': 'Sarah Wilson',
    },
    {
      'id': '2',
      'candidate': 'Emily Johnson',
      'position': 'Driver Coordinator',
      'date': '2024-01-24',
      'time': '2:30 PM',
      'status': 'completed',
      'interviewer': 'Mike Brown',
    },
    {
      'id': '3',
      'candidate': 'David Lee',
      'position': 'Support Specialist',
      'date': '2024-01-26',
      'time': '11:00 AM',
      'status': 'scheduled',
      'interviewer': 'Lisa Wang',
    },
    {
      'id': '4',
      'candidate': 'Maria Garcia',
      'position': 'Marketing Manager',
      'date': '2024-01-23',
      'time': '3:00 PM',
      'status': 'cancelled',
      'interviewer': 'Tom Wilson',
    },
  ];

  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          appLocalizations.translate('admin.interview_management'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: _scheduleNewInterview,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview
          _buildInterviewStats(),
          
          // Filters
          _buildFilters(),
          
          // Interviews List
          Expanded(
            child: _buildInterviewsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInterviewStatItem('Scheduled', '8', Colors.blue),
          _buildInterviewStatItem('Completed', '12', Colors.green),
          _buildInterviewStatItem('Pending', '3', Colors.orange),
          _buildInterviewStatItem('Cancelled', '2', Colors.red),
        ],
      ),
    );
  }

  Widget _buildInterviewStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatIcon(title),
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  IconData _getStatIcon(String title) {
    switch (title.toLowerCase()) {
      case 'scheduled':
        return Icons.calendar_today;
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Scheduled', 'scheduled'),
                _buildFilterChip('Completed', 'completed'),
                _buildFilterChip('Cancelled', 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
    );
  }

  Widget _buildInterviewsList() {
    final filteredInterviews = _interviews.where((interview) {
      return _selectedFilter == 'all' || interview['status'] == _selectedFilter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredInterviews.length,
      itemBuilder: (context, index) {
        final interview = filteredInterviews[index];
        return _buildInterviewCard(interview);
      },
    );
  }

  Widget _buildInterviewCard(Map<String, dynamic> interview) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(interview['status']),
          child: Icon(
            _getStatusIcon(interview['status']),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          interview['candidate'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(interview['position']),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${interview['date']} at ${interview['time']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Interviewer: ${interview['interviewer']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildStatusBadge(interview['status']),
        onTap: () => _showInterviewDetails(interview),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showInterviewDetails(Map<String, dynamic> interview) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Interview Details - ${interview['candidate']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Position', interview['position']),
              _buildDetailRow('Date', interview['date']),
              _buildDetailRow('Time', interview['time']),
              _buildDetailRow('Status', interview['status']),
              _buildDetailRow('Interviewer', interview['interviewer']),
              const SizedBox(height: 16),
              const Text(
                'Interview Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Interview notes and feedback will be displayed here once the interview is completed.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (interview['status'] == 'scheduled')
            TextButton(
              onPressed: () {
                // Implement reschedule logic
                Navigator.pop(context);
              },
              child: const Text('Reschedule'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _scheduleNewInterview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule New Interview'),
        content: const Text('Interview scheduling functionality to be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement schedule logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New interview scheduled')),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}