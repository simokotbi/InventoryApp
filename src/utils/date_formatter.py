from datetime import datetime

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