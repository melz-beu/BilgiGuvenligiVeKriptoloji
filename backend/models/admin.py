# admin.py
from models.user import User

class Admin(User):
    """Sistem yöneticisi sınıfı - Admin özelliklerini içerir"""
    
    def __init__(self, user_id, username, email, password_hash, full_name):
        """
        Admin nesnesi oluşturur
        
        Args:
            full_name (str): Adminin tam adı
        """
        super().__init__(user_id, username, email, password_hash, 'admin')
        self.full_name = full_name
        self.permissions = ['user_management', 'system_config', 'blockchain_management']
    
    def to_dict(self):
        """Admin nesnesini sözlük formatına dönüştürür"""
        base_dict = super().to_dict()
        base_dict.update({
            'full_name': self.full_name,
            'permissions': self.permissions,
            'password_hash': self.password_hash, 
        })
        return base_dict

class AdminManager:
    """Admin yöneticisi"""
    # ... AdminManager metodları