# Kullanıcı veri modeli - Tüm kullanıcı türleri için temel model
from datetime import datetime
import json

class User:
    """Kullanıcı temel sınıfı - Tüm kullanıcı türleri bu sınıftan türer"""
    
    def __init__(self, user_id, username, email, password_hash, user_type, created_at=None):
        """
        Kullanıcı nesnesi oluşturur
        
        Args:
            user_id (str): Benzersiz kullanıcı ID'si
            username (str): Kullanıcı adı
            email (str): E-posta adresi
            password_hash (str): Şifre hash'i
            user_type (str): Kullanıcı türü ('patient', 'doctor', 'admin')
            created_at (str): Oluşturulma tarihi
        """
        self.user_id = user_id
        self.username = username
        self.email = email
        self.password_hash = password_hash
        self.user_type = user_type
        self.created_at = created_at or datetime.now().isoformat()
        self.is_active = True
    
    def to_dict(self):
        """Kullanıcı nesnesini sözlük formatına dönüştürür"""
        return {
            'user_id': self.user_id,
            'username': self.username,
            'email': self.email,
            'user_type': self.user_type,
            'created_at': self.created_at,
            'is_active': self.is_active
        }
    
    def to_json(self):
        """Kullanıcı nesnesini JSON formatına dönüştürür"""
        return json.dumps(self.to_dict(), indent=2)



 



 
