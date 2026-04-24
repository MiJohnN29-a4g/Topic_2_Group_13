import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class MembershipScreen extends StatefulWidget {
  final User user;

  const MembershipScreen({super.key, required this.user});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final _userRepository = UserRepository();
  bool _isLoading = false;

  void _buyPackage(String packageType) async {
    setState(() => _isLoading = true);

    // Tính ngày hết hạn
    final now = DateTime.now();
    final expiryDate = packageType == 'monthly'
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 365));

    // Kích hoạt membership
    await _userRepository.activateMembership(
      userId: widget.user.id!,
      packageType: packageType,
      expiryDate: expiryDate,
      amount: packageType == 'monthly' ? 74000 : 740000,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: const Text('Thành công!', style: TextStyle(color: Colors.white)),
          content: Text(
            'Bạn đã mua gói ${packageType == 'monthly' ? 'Tháng' : 'Năm'} thành công.\n'
            'Hạn sử dụng: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final hasMembership = user.hasActiveMembership;
    final remainingDays = user.remainingDays;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Gói Membership',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current membership status
              _buildStatusCard(user, hasMembership, remainingDays),

              const SizedBox(height: 32),

              // Package options
              const Text(
                'Chọn gói của bạn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (!hasMembership) ...[
                _buildPackageCard(
                  title: 'Gói Tháng',
                  price: '74.000 đ',
                  period: '/tháng',
                  features: [
                    'Truy cập không giới hạn',
                    'Chất lượng HD',
                    'Xem trên 1 thiết bị',
                    'Hủy bất cứ lúc nào',
                  ],
                  onTap: () => _buyPackage('monthly'),
                  accentColor: Colors.red,
                ),
                const SizedBox(height: 16),
                _buildPackageCard(
                  title: 'Gói Năm',
                  price: '740.000 đ',
                  period: '/năm',
                  features: [
                    'Truy cập không giới hạn',
                    'Chất lượng 4K HDR',
                    'Xem trên 4 thiết bị',
                    'Tải về xem offline',
                    'Hủy bất cứ lúc nào',
                  ],
                  onTap: () => _buyPackage('yearly'),
                  accentColor: Colors.amber,
                  isPopular: true,
                ),
              ] else ...[
                _buildCurrentPackageInfo(user),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(User user, bool hasMembership, int? remainingDays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasMembership
              ? [const Color(0xFF1DB954), const Color(0xFF1ED760)]
              : [const Color(0xFF333333), const Color(0xFF444444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasMembership ? Icons.check_circle : Icons.info_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                hasMembership ? 'Thành viên Premium' : 'Chưa có gói Premium',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasMembership
                ? 'Thời gian còn lại: $remainingDays ngày'
                : 'Nâng cấp để xem phim không giới hạn',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          if (hasMembership && user.membershipType != null) ...[
            const SizedBox(height: 4),
            Text(
              'Gói: ${user.membershipType == 'yearly' ? 'Năm' : 'Tháng'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required VoidCallback onTap,
    required Color accentColor,
    bool isPopular = false,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPopular ? accentColor : const Color(0xFF333333),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Phổ biến',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$price$period',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: accentColor,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check, color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPackageInfo(User user) {
    final expiryDate = user.membershipExpiry != null
        ? DateTime.parse(user.membershipExpiry!)
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star,
            color: user.membershipType == 'yearly' ? Colors.amber : Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            user.membershipType == 'yearly' ? 'Gói Năm' : 'Gói Tháng',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hết hạn: ${expiryDate?.day}/${expiryDate?.month}/${expiryDate?.year}',
            style: const TextStyle(color: Colors.white60, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Còn lại: ${user.remainingDays ?? 0} ngày',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
