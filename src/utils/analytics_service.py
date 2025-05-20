from datetime import datetime, timedelta
from typing import List, Dict, Any, Tuple
from PySide6.QtCore import QObject, Signal, Slot, Property
from database.database import Database
from .logger import get_logger
from .date_formatter import format_relative_time

logger = get_logger()

class AnalyticsService(QObject):
    dataUpdated = Signal()

    def __init__(self):
        super().__init__()
        self.database = Database()
        self._cache_timeout = 300  # 5 minutes
        self._last_cache_time = None
        self._cached_data = {}
        self._current_range_value = "day"
        self._performance_data = []
        self._performance_labels = []
        self._request_stats_data = []
        self._request_stats_labels = []

    def _needs_cache_refresh(self) -> bool:
        """Check if the cached data needs to be refreshed."""
        if not self._last_cache_time:
            return True
        age = (datetime.now() - self._last_cache_time).total_seconds()
        return age > self._cache_timeout

    def _get_current_range(self) -> str:
        return self._current_range_value

    @Slot(str)
    def setTimeRange(self, range_type: str):
        if self._current_range_value != range_type:
            self._current_range_value = range_type
            self.refreshData()

    currentRange = Property(str, _get_current_range, notify=dataUpdated)

    def _get_performance_data(self):
        return self._performance_data

    performanceData = Property('QVariantList', _get_performance_data, notify=dataUpdated)

    def _get_performance_labels(self):
        return self._performance_labels

    performanceLabels = Property('QVariantList', _get_performance_labels, notify=dataUpdated)

    def _get_request_stats_data(self):
        return self._request_stats_data

    requestStatsData = Property('QVariantList', _get_request_stats_data, notify=dataUpdated)

    def _get_request_stats_labels(self):
        return self._request_stats_labels

    requestStatsLabels = Property('QVariantList', _get_request_stats_labels, notify=dataUpdated)

    @Slot()
    def refreshData(self):
        """Force refresh all data"""
        self._cached_data = {}
        self._last_cache_time = None
        self._update_performance_data()
        self._update_request_stats()
        self.dataUpdated.emit()

    def _update_performance_data(self):
        """Update performance chart data"""
        try:
            data = self.database.get_performance_stats()
            self._performance_data = [stat['avg_value'] for stat in data]
            self._performance_labels = [stat['metric_type'] for stat in data]
        except Exception as e:
            logger.error(f"Error updating performance data: {str(e)}")
            self._performance_data = []
            self._performance_labels = []

    def _update_request_stats(self):
        """Update request statistics chart data"""
        try:
            with self.database._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT method, COUNT(*) as count
                    FROM request_log
                    GROUP BY method
                    ORDER BY count DESC
                """)
                results = cursor.fetchall()
                self._request_stats_data = [r['count'] for r in results]
                self._request_stats_labels = [r['method'] for r in results]
        except Exception as e:
            logger.error(f"Error updating request stats: {str(e)}")
            self._request_stats_data = []
            self._request_stats_labels = []

    @Slot(str, result='QVariant')
    def get_user_activity(self, time_range: str) -> Dict[str, Any]:
        """Get user activity data for the specified time range."""
        try:
            if self._needs_cache_refresh() or 'user_activity' not in self._cached_data:
                # Get the date range based on the selected time range
                end_date = datetime.now()
                if time_range == "Last 7 Days":
                    start_date = end_date - timedelta(days=7)
                    group_by = "day"
                elif time_range == "Last 30 Days":
                    start_date = end_date - timedelta(days=30)
                    group_by = "day"
                elif time_range == "Last 3 Months":
                    start_date = end_date - timedelta(days=90)
                    group_by = "week"
                else:  # Last Year
                    start_date = end_date - timedelta(days=365)
                    group_by = "month"

                # Execute query to get user activity data
                query = """
                SELECT 
                    strftime(?, datetime) as period,
                    COUNT(*) as count
                FROM user_activity
                WHERE datetime BETWEEN ? AND ?
                GROUP BY period
                ORDER BY period
                """

                date_format = {
                    "day": "%Y-%m-%d",
                    "week": "%Y-W%W",
                    "month": "%Y-%m"
                }[group_by]

                with self.database._get_connection() as conn:
                    cursor = conn.cursor()
                    cursor.execute(query, (date_format, start_date, end_date))
                    results = cursor.fetchall()

                # Format data for QML
                data = {
                    'labels': [r['period'] for r in results],
                    'values': [r['count'] for r in results],
                    'maxValue': max([r['count'] for r in results] or [0])
                }

                self._cached_data['user_activity'] = data
                self._last_cache_time = datetime.now()

            return self._cached_data['user_activity']

        except Exception as e:
            logger.error(f"Error getting user activity: {str(e)}", exc_info=True)
            return {'labels': [], 'values': [], 'maxValue': 0}

    @Slot(str, result='QVariant')
    def get_form_submissions(self, time_range: str) -> Dict[str, Any]:
        """Get form submission statistics for the specified time range."""
        try:
            if self._needs_cache_refresh() or 'form_submissions' not in self._cached_data:
                # Similar implementation as get_user_activity but for form submissions
                # This would query a different table or set of tables
                
                # Placeholder data until we implement form submission tracking
                data = {
                    'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    'values': [12, 19, 23, 18, 25, 28, 32],
                    'maxValue': 50
                }

                self._cached_data['form_submissions'] = data
                self._last_cache_time = datetime.now()

            return self._cached_data['form_submissions']

        except Exception as e:
            logger.error(f"Error getting form submissions: {str(e)}", exc_info=True)
            return {'labels': [], 'values': [], 'maxValue': 0}

    @Slot(str, result='QVariant')
    def get_error_rate(self, time_range: str) -> Dict[str, Any]:
        """Get error rate statistics for the specified time range."""
        try:
            if self._needs_cache_refresh() or 'error_rate' not in self._cached_data:
                # Query error logs and calculate error rates
                # This would analyze application logs or error tracking tables
                
                # Placeholder data until we implement error tracking
                data = {
                    'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    'values': [2.1, 1.8, 2.5, 1.9, 1.2, 1.5, 1.7],
                    'maxValue': 10
                }

                self._cached_data['error_rate'] = data
                self._last_cache_time = datetime.now()

            return self._cached_data['error_rate']

        except Exception as e:
            logger.error(f"Error getting error rate: {str(e)}", exc_info=True)
            return {'labels': [], 'values': [], 'maxValue': 0}

    @Slot(result='QVariant')
    def get_performance_metrics(self) -> Dict[str, Any]:
        """Get current performance metrics."""
        try:
            if self._needs_cache_refresh() or 'performance' not in self._cached_data:
                # Query various system metrics
                with self.database._get_connection() as conn:
                    cursor = conn.cursor()
                    
                    # Get active users in the last hour
                    cursor.execute("""
                        SELECT COUNT(DISTINCT user_id) as active_users
                        FROM user_activity
                        WHERE datetime >= datetime('now', '-1 hour')
                    """)
                    active_users = cursor.fetchone()['active_users']

                    # Calculate average response time (placeholder query)
                    cursor.execute("""
                        SELECT AVG(response_time) as avg_response
                        FROM performance_metrics
                        WHERE timestamp >= datetime('now', '-5 minutes')
                    """)
                    avg_response = cursor.fetchone()['avg_response'] or 0

                    # Calculate success rate
                    cursor.execute("""
                        SELECT 
                            COUNT(*) as total,
                            SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successes
                        FROM request_log
                        WHERE timestamp >= datetime('now', '-1 hour')
                    """)
                    result = cursor.fetchone()
                    success_rate = (result['successes'] / result['total'] * 100) if result['total'] > 0 else 100

                data = {
                    'avgResponseTime': f"{avg_response:.0f}ms",
                    'successRate': f"{success_rate:.1f}%",
                    'activeUsers': str(active_users),
                    'cpuUsage': "45%"  # Placeholder - would need system monitoring
                }

                self._cached_data['performance'] = data
                self._last_cache_time = datetime.now()

            return self._cached_data['performance']

        except Exception as e:
            logger.error(f"Error getting performance metrics: {str(e)}", exc_info=True)
            return {
                'avgResponseTime': '0ms',
                'successRate': '0%',
                'activeUsers': '0',
                'cpuUsage': '0%'
            }

    @Slot()
    def clear_cache(self):
        """Clear the cached data to force a refresh."""
        self._cached_data = {}
        self._last_cache_time = None
        self.dataUpdated.emit()