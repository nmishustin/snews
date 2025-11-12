#!/usr/bin/env python3
"""Script to create Airflow admin user."""

import os
import sys


def create_admin_user():
    """Create admin user for Airflow."""
    try:
        # For Airflow 3.x with standalone mode, user is created automatically
        # But we can set a specific password via environment variable
        username = os.getenv("AIRFLOW_ADMIN_USERNAME", "admin")
        password = os.getenv("AIRFLOW_ADMIN_PASSWORD", "admin")
        
        print(f"Admin credentials:")
        print(f"Username: {username}")
        print(f"Password: {password}")
        print("")
        print("Note: In standalone mode, admin user is created automatically")
        print("Check logs for the auto-generated password or set AIRFLOW_ADMIN_PASSWORD")
        
        return 0
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(create_admin_user())

