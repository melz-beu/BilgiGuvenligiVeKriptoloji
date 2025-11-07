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


class Patient(User):
    """Hasta kullanıcı sınıfı - Hasta özelliklerini içerir"""
    
    def __init__(self, user_id, username, email, password_hash, 
                 full_name, date_of_birth, gender, phone=None, 
                 emergency_contact=None, medical_conditions=None):
        """
        Hasta nesnesi oluşturur
        
        Args:
            full_name (str): Hastanın tam adı
            date_of_birth (str): Doğum tarihi
            gender (str): Cinsiyet
            phone (str): Telefon numarası
            emergency_contact (str): Acil durum iletişimi
            medical_conditions (list): Tıbbi durumlar listesi
        """
        super().__init__(user_id, username, email, password_hash, 'patient')
        self.full_name = full_name
        self.date_of_birth = date_of_birth
        self.gender = gender
        self.phone = phone
        self.emergency_contact = emergency_contact
        self.medical_conditions = medical_conditions or []
        self.assigned_doctors = []  # Hastaya atanmış doktorlar listesi
    
    def to_dict(self):
        """Hasta nesnesini sözlük formatına dönüştürür"""
        base_dict = super().to_dict()
        base_dict.update({
            'full_name': self.full_name,
            'date_of_birth': self.date_of_birth,
            'gender': self.gender,
            'phone': self.phone,
            'emergency_contact': self.emergency_contact,
            'medical_conditions': self.medical_conditions,
            'assigned_doctors': self.assigned_doctors,
            'password_hash': self.password_hash, 
        })
        return base_dict


class Doctor(User):
    """Doktor kullanıcı sınıfı - Doktor özelliklerini içerir"""
    
    def __init__(self, user_id, username, email, password_hash,
                 full_name, license_number, specialization, hospital=None):
        """
        Doktor nesnesi oluşturur
        
        Args:
            full_name (str): Doktorun tam adı
            license_number (str): Lisans numarası
            specialization (str): Uzmanlık alanı
            hospital (str): Çalıştığı hastane
        """
        super().__init__(user_id, username, email, password_hash, 'doctor')
        self.full_name = full_name
        self.license_number = license_number
        self.specialization = specialization
        self.hospital = hospital
        self.patients = []  # Doktora atanmış hastalar listesi
    
    def to_dict(self):
        """Doktor nesnesini sözlük formatına dönüştürür"""
        base_dict = super().to_dict()
        base_dict.update({
            'full_name': self.full_name,
            'license_number': self.license_number,
            'specialization': self.specialization,
            'hospital': self.hospital,
            'patients': self.patients,
            'password_hash': self.password_hash, 
        })
        return base_dict


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