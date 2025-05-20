from datetime import datetime, timedelta

def format_date(date_str: str, input_format: str = "%Y-%m-%d", output_format: str = "%B %d, %Y") -> str:
    """
    Convert a date string from one format to another.
    
    Args:
        date_str: The date string to format
        input_format: The format of the input date string
        output_format: The desired output format
        
    Returns:
        Formatted date string or original string if parsing fails
    """
    try:
        date_obj = datetime.strptime(date_str, input_format)
        return date_obj.strftime(output_format)
    except ValueError:
        return date_str

def is_valid_date(date_str: str, date_format: str = "%Y-%m-%d") -> bool:
    """
    Check if a date string is valid according to the given format.
    
    Args:
        date_str: The date string to validate
        date_format: The expected format of the date string
        
    Returns:
        bool: True if the date is valid, False otherwise
    """
    try:
        datetime.strptime(date_str, date_format)
        return True
    except ValueError:
        return False

def format_relative_time(timestamp: datetime) -> str:
    """
    Format a timestamp into a relative time string (e.g., "2 minutes ago").
    
    Args:
        timestamp: The datetime to format
        
    Returns:
        A human-readable relative time string
    """
    now = datetime.now()
    diff = now - timestamp

    if diff < timedelta(minutes=1):
        return "just now"
    elif diff < timedelta(hours=1):
        minutes = int(diff.total_seconds() / 60)
        return f"{minutes} minute{'s' if minutes != 1 else ''} ago"
    elif diff < timedelta(days=1):
        hours = int(diff.total_seconds() / 3600)
        return f"{hours} hour{'s' if hours != 1 else ''} ago"
    elif diff < timedelta(days=30):
        days = diff.days
        return f"{days} day{'s' if days != 1 else ''} ago"
    elif diff < timedelta(days=365):
        months = int(diff.days / 30)
        return f"{months} month{'s' if months != 1 else ''} ago"
    else:
        years = int(diff.days / 365)
        return f"{years} year{'s' if years != 1 else ''} ago"