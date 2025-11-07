# Kimlik doğrulama ve yetkilendirme servisleri
import jwt
import datetime
from functools import wraps
from flask import request, jsonify
from config import Config
from database import DatabaseManager

class AuthService:
    """Kimlik doğrulama servisi - JWT token yönetimi"""
    
    def __init__(self):
        self.secret_key = Config.JWT_SECRET_KEY
        self.db = DatabaseManager()
    
    def generate_token(self, user_id, username, user_type):
        """
        JWT token oluşturur
        
        Args:
            user_id (str): Kullanıcı ID'si
            username (str): Kullanıcı adı
            user_type (str): Kullanıcı türü
        
        Returns:
            str: JWT token
        """
        try:
            payload = {
                'exp': datetime.datetime.utcnow() + Config.JWT_ACCESS_TOKEN_EXPIRES,
                'iat': datetime.datetime.utcnow(),
                'sub': user_id,
                'username': username,
                'user_type': user_type
            }
            return jwt.encode(payload, self.secret_key, algorithm='HS256')
        except Exception as e:
            print(f"Token oluşturma hatası: {e}")
            return None
    
    def verify_token(self, token):
        """
        JWT token doğrular
        
        Args:
            token (str): JWT token
        
        Returns:
            dict: Token payload veya None
        """
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=['HS256'])
            return payload
        except jwt.ExpiredSignatureError:
            print("Token süresi dolmuş")
            return None
        except jwt.InvalidTokenError:
            print("Geçersiz token")
            return None
    
    def authenticate_user(self, username, password):
        """
        Kullanıcı kimlik doğrulaması yapar
        
        Args:
            username (str): Kullanıcı adı
            password (str): Şifre (hash'lenmiş olmalı)
        
        Returns:
            dict: Kullanıcı bilgileri veya None
        """
        try:
            # Veritabanından kullanıcıyı getir
            user_data = self.db.get_user_by_username(username)
            
            if not user_data:
                print(f"Kullanıcı bulunamadı: {username}")
                return None
            
            # Şifre doğrulama (basit hash kontrolü - gerçek uygulamada güvenli hash kullanın)
            if user_data['password_hash'] != self._hash_password(password):
                print("Şifre hatalı")
                return None
            
            if not user_data['is_active']:
                print("Kullanıcı pasif durumda")
                return None
            
            # Token oluştur
            token = self.generate_token(
                user_data['user_id'],
                user_data['username'],
                user_data['user_type']
            )
            
            if not token:
                return None
            
            return {
                'token': token,
                'user': {
                    'user_id': user_data['user_id'],
                    'username': user_data['username'],
                    'email': user_data['email'],
                    'user_type': user_data['user_type'],
                    'full_name': user_data.get('full_name'),
                    'is_active': user_data['is_active']
                }
            }
            
        except Exception as e:
            print(f"Kimlik doğrulama hatası: {e}")
            return None
    
    def _hash_password(self, password):
        """
        Şifreyi hash'ler (basit implementasyon - gerçek uygulamada bcrypt kullanın)
        
        Args:
            password (str): Şifre
        
        Returns:
            str: Hash'lenmiş şifre
        """
        import hashlib
        # Debug için hash değerini yazdır
        hashed = hashlib.sha256(password.encode()).hexdigest()
        print(f"🔐 Password: {password} -> Hash: {hashed}")
        return hashed
    
    def register_user(self, user_data):
        """
        Yeni kullanıcı kaydı oluşturur
        
        Args:
            user_data (dict): Kullanıcı bilgileri
        
        Returns:
            bool: Kayıt başarılı mı
        """
        try:
            # Kullanıcı adı ve email kontrolü
            existing_user = self.db.get_user_by_username(user_data['username'])
            if existing_user:
                print("Kullanıcı adı zaten kullanılıyor")
                return False
            
            # Şifreyi hash'le - BURASI ÖNEMLİ!
            password_hash = self._hash_password(user_data['password'])
            print(f"🔐 Register - Password hash: {password_hash}")
            
            # Kullanıcı türüne göre nesne oluştur
            from models.user import Patient, Doctor, Admin
            
            user_id = f"{user_data['user_type']}_{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}"
            
            if user_data['user_type'] == 'patient':
                user = Patient(
                    user_id=user_id,
                    username=user_data['username'],
                    email=user_data['email'],
                    password_hash=password_hash,  # ← DÜZELTİLDİ!
                    full_name=user_data.get('full_name'),
                    date_of_birth=user_data.get('date_of_birth'),
                    gender=user_data.get('gender'),
                    phone=user_data.get('phone'),
                    emergency_contact=user_data.get('emergency_contact'),
                    medical_conditions=user_data.get('medical_conditions', [])
                )
            elif user_data['user_type'] == 'doctor':
                user = Doctor(
                    user_id=user_id,
                    username=user_data['username'],
                    email=user_data['email'],
                    password_hash=password_hash,  # ← DÜZELTİLDİ!
                    full_name=user_data.get('full_name'),
                    license_number=user_data.get('license_number'),
                    specialization=user_data.get('specialization'),
                    hospital=user_data.get('hospital')
                )
            elif user_data['user_type'] == 'admin':
                user = Admin(
                    user_id=user_id,
                    username=user_data['username'],
                    email=user_data['email'],
                    password_hash=password_hash,  # ← DÜZELTİLDİ!
                    full_name=user_data.get('full_name')
                )
            else:
                print("Geçersiz kullanıcı türü")
                return False
            
            # Veritabanına kaydet
            result = self.db.save_user(user)
            if result:
                print(f"✅ Kullanıcı KAYDEDİLDİ: {user_data['username']} - Hash: {password_hash}")
            return result
                
        except Exception as e:
            print(f"❌ Kullanıcı kayıt hatası: {e}")
            return False

# Decorator fonksiyonları
def token_required(f):
    """
    Token gerektiren endpoint'ler için decorator
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Token'ı header'dan al
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]  # Bearer token formatı
            except IndexError:
                return jsonify({'message': 'Geçersiz token formatı'}), 401
        
        if not token:
            return jsonify({'message': 'Token gerekiyor'}), 401
        
        # Token'ı doğrula
        auth_service = AuthService()
        payload = auth_service.verify_token(token)
        
        if not payload:
            return jsonify({'message': 'Geçersiz veya süresi dolmuş token'}), 401
        
        # Kullanıcı bilgilerini request'e ekle
        request.user_id = payload['sub']
        request.username = payload['username']
        request.user_type = payload['user_type']
        
        return f(*args, **kwargs)
    
    return decorated


def admin_required(f):
    """
    Admin yetkisi gerektiren endpoint'ler için decorator
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        # Önce token kontrolü
        token_response = token_required(f)(*args, **kwargs)
        
        # Eğer token hatası varsa direkt dön
        if isinstance(token_response, tuple) and token_response[1] != 200:
            return token_response
        
        # Admin kontrolü
        if not hasattr(request, 'user_type') or request.user_type != 'admin':
            return jsonify({'message': 'Admin yetkisi gerekiyor'}), 403
        
        return f(*args, **kwargs)
    
    return decorated


def doctor_or_admin_required(f):
    """
    Doktor veya Admin yetkisi gerektiren endpoint'ler için decorator
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        # Önce token kontrolü
        token_response = token_required(f)(*args, **kwargs)
        
        # Eğer token hatası varsa direkt dön
        if isinstance(token_response, tuple) and token_response[1] != 200:
            return token_response
        
        # Doktor veya Admin kontrolü
        if not hasattr(request, 'user_type') or request.user_type not in ['doctor', 'admin']:
            return jsonify({'message': 'Doktor veya Admin yetkisi gerekiyor'}), 403
        
        return f(*args, **kwargs)
    
    return decorated