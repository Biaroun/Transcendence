import os
import sys
import django
from django.core.management import call_command
from django.contrib.auth import get_user_model

# Django prepare context
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(BASE_DIR)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_user_handler.settings')
django.setup()

# Secrets recover from environment variables
username = os.environ.get('DJANGO_SUPERUSER_NAME')
email = os.environ.get('DJANGO_SUPERUSER_EMAIL')
password = os.environ.get('DJANGO_SUPERUSER_PASSWORD')

if not all([username, email, password]):
    print("Please define DJANGO_SUPERUSER_NAME, DJANGO_SUPERUSER_EMAIL, and DJANGO_SUPERUSER_PASSWORD environment variables.")
    sys.exit(1)

# Vérifier si le superutilisateur existe
User = get_user_model()
if User.objects.filter(username=username).exists():
    print(f"Super '{username}' already exist.")
    sys.exit(0)

# Superuser create
call_command('createsuperuser', username=username, email=email, interactive=False)

# Password define
user = User.objects.get(username=username)
user.set_password(password)
user.save()
print(f"Superuser '{username}' created successfully.")
