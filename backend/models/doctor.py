# doctor.py
import json
from models.user import User

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
 
        })
        return base_dict

'''    
    def to_json(self):
        """Doktor nesnesini JSON formatına dönüştürür"""
        return json.dumps(self.to_dict(), indent=2, ensure_ascii=False)
'''
class DoctorManager:
    """Doktor yöneticisi"""
    # ... DoctorManager metodları