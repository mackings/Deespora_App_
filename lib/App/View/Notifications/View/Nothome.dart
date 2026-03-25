import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Events/Views/eventDetails.dart';
import 'package:dspora/App/View/Notifications/Api/notifications_service.dart';
import 'package:dspora/App/View/Notifications/Model/notification_model.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Restaurants/View/Details.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FrontDetails.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/fallback_network_image.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';

class Notification_home extends StatefulWidget {
  const Notification_home({super.key});

  @override
  State<Notification_home> createState() => _Notification_homeState();
}

class _Notification_homeState extends State<Notification_home> {
  final NotificationsService _notificationsService = NotificationsService();
  NotificationsFeed _feed = NotificationsFeed.empty();
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasRetriedEmptyState = false;

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final feed = await _notificationsService.fetchNotifications(
        eventsLimit: 3,
        placesLimit: 2,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _feed = feed;
        _isLoading = false;
        _hasRetriedEmptyState = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatGeneratedAt(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Updated just now';
    }

    final local = dateTime.toLocal();
    final month = _monthNames[local.month - 1];
    final minutes = local.minute.toString().padLeft(2, '0');
    return 'Updated $month ${local.day}, ${local.year} at ${local.hour}:$minutes';
  }

  String _formatEventDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date coming soon';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    final local = parsed.toLocal();
    final month = _monthNames[local.month - 1];
    final minutes = local.minute.toString().padLeft(2, '0');
    return '$month ${local.day}, ${local.year} • ${local.hour}:$minutes';
  }

  String _cleanPlaceId(String value, String prefix) {
    return value.startsWith(prefix) ? value.substring(prefix.length) : value;
  }

  Future<void> _openNotification(NotificationItem item) async {
    if (!mounted) {
      return;
    }

    if (item.isEvent) {
      final parsedEventDate = DateTime.tryParse(item.eventDate ?? '');
      final event = Event(
        id: item.id,
        name: item.title,
        type: item.type,
        url: item.url ?? '',
        images: item.imageUrl != null && item.imageUrl!.isNotEmpty
            ? [
                EventImage(
                  url: item.imageUrl!,
                  ratio: '16_9',
                  width: 1200,
                  height: 675,
                  fallback: false,
                ),
              ]
            : const [],
        sales: EventSales(
          publicSale: EventSaleDetail(
            startDateTime: item.eventDate ?? '',
            endDateTime: '',
          ),
        ),
        dates: EventDates(
          start: EventDateStart(
            localDate: parsedEventDate != null
                ? '${parsedEventDate.year}-${parsedEventDate.month.toString().padLeft(2, '0')}-${parsedEventDate.day.toString().padLeft(2, '0')}'
                : '',
            localTime: parsedEventDate != null
                ? '${parsedEventDate.hour.toString().padLeft(2, '0')}:${parsedEventDate.minute.toString().padLeft(2, '0')}'
                : '',
          ),
          timezone: '',
          statusCode: item.type,
        ),
        classifications: const [],
        venues: [
          EventVenue(
            name: item.venue ?? 'Venue',
            address: '',
            city: '',
            country: '',
            latitude: 0,
            longitude: 0,
          ),
        ],
      );

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      );
      return;
    }

    if (item.isRestaurant) {
      final restaurant = Restaurant(
        id: _cleanPlaceId(item.id, 'restaurant:'),
        name: item.title,
        vicinity: item.location ?? '',
        rating: item.rating ?? 0,
        openNow: false,
        photoUrl: item.imageUrl,
        userRatingsTotal: item.reviewCount,
        photoReferences: item.imageUrl != null && item.imageUrl!.isNotEmpty
            ? [item.imageUrl!]
            : const [],
        reviews: const [],
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
        ),
      );
      return;
    }

    if (item.isCatering) {
      final catering = Catering(
        id: _cleanPlaceId(item.id, 'catering:'),
        name: item.title,
        address: item.location ?? '',
        rating: item.rating ?? 0,
        openNow: false,
        photoUrl: item.imageUrl,
        userRatingsTotal: item.reviewCount,
        photoReferences: item.imageUrl != null && item.imageUrl!.isNotEmpty
            ? [item.imageUrl!]
            : const [],
        reviews: const [],
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GlobalStoreDetails(catering: catering),
        ),
      );
    }
  }

  Widget _buildImage(NotificationItem item) {
    final assetPath = item.isCatering
        ? Images.cateringPlaceholderAsset
        : Images.restaurantPlaceholderAsset;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FallbackNetworkImage(
        imageUrls: item.imageUrl != null && item.imageUrl!.isNotEmpty
            ? [item.imageUrl!]
            : const [],
        assetPath: assetPath,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMeta(NotificationItem item) {
    if (item.isEvent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatEventDate(item.eventDate),
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          if ((item.venue ?? '').isNotEmpty)
            Text(
              item.venue!,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
        ],
      );
    }

    final details = <String>[];
    if (item.rating != null) {
      details.add('⭐ ${item.rating!.toStringAsFixed(1)}');
    }
    if (item.reviewCount != null) {
      details.add('${item.reviewCount} reviews');
    }
    if ((item.location ?? '').isNotEmpty) {
      details.add(item.location!);
    }

    return Text(
      details.join(' • '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: Colors.black54),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    final badgeLabel = switch (item.type) {
      'new_event' => 'New Event',
      'upcoming_event' => 'Upcoming',
      'latest_restaurant' => 'Restaurant',
      'latest_catering' => 'Catering',
      _ => item.type.replaceAll('_', ' '),
    };

    return InkWell(
      onTap: () => _openNotification(item),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildImage(item),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37B6AF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: Color(0xFF1E8F89),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  _buildMeta(item),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF37B6AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<NotificationItem> items, {
    required String subtitle,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 14),
        ...items.map(_buildNotificationCard),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF37B6AF)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to load notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadNotifications,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_feed.isEmpty) {
      if (!_hasRetriedEmptyState) {
        _hasRetriedEmptyState = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadNotifications();
          }
        });
      }
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF37B6AF),
      onRefresh: _loadNotifications,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            _formatGeneratedAt(_feed.generatedAt),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          _buildSection(
            'Event Updates',
            _feed.events,
            subtitle: 'Latest additions and upcoming events from the live feed',
          ),
          _buildSection(
            'Restaurant Highlights',
            _feed.restaurants,
            subtitle:
                'Discovery feed spots with the most recent review activity',
          ),
          _buildSection(
            'Catering Highlights',
            _feed.catering,
            subtitle: 'Recent catering standouts from the discovery cache',
          ),
          _buildSection(
            'More Notifications',
            _feed.notifications,
            subtitle: 'Additional updates from the notification feed',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: CustomText(text: "Notifications", title: true, fontSize: 18),
        actions: [
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh, color: Color(0xFF37B6AF)),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }
}
