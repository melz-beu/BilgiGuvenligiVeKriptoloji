# Hasta modeli - Patient sınıfı ve hasta işlemleri
from datetime import datetime
import json
from .user import User

class Patient(User):
    """Hasta sınıfı - Patient özellikleri ve metodları"""
    
    def __init__(self, user_id, username, email, password_hash, 
                 full_name=None, date_of_birth=None, gender=None, 
                 phone=None, emergency_contact=None, medical_conditions=None,
                 created_at=None):
        """
        Hasta nesnesi oluşturur
        
        Args:
            user_id (str): Benzersiz kullanıcı ID'si
            username (str): Kullanıcı adı
            email (str): E-posta adresi
            password_hash (str): Şifre hash'i
            full_name (str): Hastanın tam adı
            date_of_birth (str): Doğum tarihi (YYYY-MM-DD)
            gender (str): Cinsiyet
            phone (str): Telefon numarası
            emergency_contact (str): Acil durum iletişimi
            medical_conditions (list): Tıbbi durumlar listesi
            created_at (str): Oluşturulma tarihi
        """
        super().__init__(user_id, username, email, password_hash, 'patient', created_at)
        self.full_name = full_name
        self.date_of_birth = date_of_birth
        self.gender = gender
        self.phone = phone
        self.emergency_contact = emergency_contact
        self.medical_conditions = medical_conditions or []
        self.assigned_doctors = []  # Hastaya atanmış doktorlar listesi
        self.medical_history = []   # Tıbbi geçmiş kayıtları
    
    def calculate_age(self):
        """
        Hastanın yaşını hesaplar
        
        Returns:
            int: Yaş veya None
        """
        if not self.date_of_birth:
            return None
        
        try:
            birth_date = datetime.strptime(self.date_of_birth, '%Y-%m-%d')
            today = datetime.now()
            age = today.year - birth_date.year
            
            # Doğum günü henüz gelmemişse bir yaş eksik say
            if (today.month, today.day) < (birth_date.month, birth_date.day):
                age -= 1
            
            return age
        except ValueError:
            print("Geçersiz doğum tarihi formatı")
            return None
    
    def add_medical_condition(self, condition):
        """
        Tıbbi durum ekler
        
        Args:
            condition (str): Tıbbi durum
        
        Returns:
            bool: Ekleme başarılı mı
        """
        if condition and condition not in self.medical_conditions:
            self.medical_conditions.append(condition)
            return True
        return False
    
    def remove_medical_condition(self, condition):
        """
        Tıbbi durum kaldırır
        
        Args:
            condition (str): Kaldırılacak tıbbi durum
        
        Returns:
            bool: Kaldırma başarılı mı
        """
        if condition in self.medical_conditions:
            self.medical_conditions.remove(condition)
            return True
        return False
    
    def assign_doctor(self, doctor_id):
        """
        Doktor atar
        
        Args:
            doctor_id (str): Doktor ID'si
        
        Returns:
            bool: Atama başarılı mı
        """
        if doctor_id and doctor_id not in self.assigned_doctors:
            self.assigned_doctors.append(doctor_id)
            return True
        return False
    
    def remove_doctor(self, doctor_id):
        """
        Doktor atamasını kaldırır
        
        Args:
            doctor_id (str): Kaldırılacak doktor ID'si
        
        Returns:
            bool: Kaldırma başarılı mı
        """
        if doctor_id in self.assigned_doctors:
            self.assigned_doctors.remove(doctor_id)
            return True
        return False
    
    def add_medical_record(self, record):
        """
        Tıbbi kayıt ekler
        
        Args:
            record (dict): Tıbbi kayıt verisi
        
        Returns:
            bool: Ekleme başarılı mı
        """
        if record:
            record['timestamp'] = datetime.now().isoformat()
            self.medical_history.append(record)
            return True
        return False
    
    def get_recent_medical_history(self, limit=10):
        """
        Son tıbbi kayıtları getirir
        
        Args:
            limit (int): Getirilecek kayıt sayısı
        
        Returns:
            list: Tıbbi kayıtlar listesi
        """
        return self.medical_history[-limit:] if self.medical_history else []
    
    def get_health_summary(self):
        """
        Sağlık özeti oluşturur
        
        Returns:
            dict: Sağlık özeti
        """
        age = self.calculate_age()
        
        summary = {
            'patient_id': self.user_id,
            'full_name': self.full_name,
            'age': age,
            'gender': self.gender,
            'medical_conditions': self.medical_conditions,
            'assigned_doctors_count': len(self.assigned_doctors),
            'medical_records_count': len(self.medical_history),
            'last_update': datetime.now().isoformat()
        }
        
        return summary
    
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
            'age': self.calculate_age(),
            'medical_history_count': len(self.medical_history)
        })
        return base_dict
    
    def to_json(self):
        """Hasta nesnesini JSON formatına dönüştürür"""
        return json.dumps(self.to_dict(), indent=2, ensure_ascii=False)


class PatientManager:
    """Hasta yöneticisi - Hasta işlemlerini yönetir"""
    
    def __init__(self, database_manager):
        """
        Hasta yöneticisi oluşturur
        
        Args:
            database_manager: Veritabanı yöneticisi
        """
        self.db = database_manager
        self.patients = {}  # Cache için hasta sözlüğü
    
    def create_patient(self, patient_data):
        """
        Yeni hasta oluşturur
        
        Args:
            patient_data (dict): Hasta verileri
        
        Returns:
            Patient: Oluşturulan hasta nesnesi veya None
        """
        try:
            # Gerekli alanları kontrol et
            required_fields = ['username', 'email', 'password_hash']
            for field in required_fields:
                if field not in patient_data:
                    print(f"Eksik alan: {field}")
                    return None
            
            # Hasta ID oluştur
            patient_id = f"patient_{datetime.now().strftime('%Y%m%d%H%M%S')}"
            
            # Hasta nesnesi oluştur
            patient = Patient(
                user_id=patient_id,
                username=patient_data['username'],
                email=patient_data['email'],
                password_hash=patient_data['password_hash'],
                full_name=patient_data.get('full_name'),
                date_of_birth=patient_data.get('date_of_birth'),
                gender=patient_data.get('gender'),
                phone=patient_data.get('phone'),
                emergency_contact=patient_data.get('emergency_contact'),
                medical_conditions=patient_data.get('medical_conditions', [])
            )
            
            # Veritabanına kaydet
            if self.db.save_user(patient):
                self.patients[patient_id] = patient
                print(f"✅ Hasta oluşturuldu: {patient_id}")
                return patient
            else:
                print("❌ Hasta veritabanına kaydedilemedi")
                return None
                
        except Exception as e:
            print(f"❌ Hasta oluşturma hatası: {e}")
            return None
    
    def get_patient(self, patient_id):
        """
        Hasta bilgilerini getirir
        
        Args:
            patient_id (str): Hasta ID'si
        
        Returns:
            Patient: Hasta nesnesi veya None
        """
        # Önce cache'den kontrol et
        if patient_id in self.patients:
            return self.patients[patient_id]
        
        # Veritabanından getir
        user_data = self.db.get_user_by_id(patient_id)
        
        if not user_data or user_data.get('user_type') != 'patient':
            return None
        
        # Hasta nesnesi oluştur
        patient = Patient(
            user_id=user_data['user_id'],
            username=user_data['username'],
            email=user_data['email'],
            password_hash=user_data['password_hash'],
            full_name=user_data.get('full_name'),
            date_of_birth=user_data.get('date_of_birth'),
            gender=user_data.get('gender'),
            phone=user_data.get('phone'),
            emergency_contact=user_data.get('emergency_contact'),
            medical_conditions=json.loads(user_data.get('medical_conditions', '[]')),
            created_at=user_data.get('created_at')
        )
        
        # Assigned doctors'ı yükle
        assigned_doctors = json.loads(user_data.get('assigned_doctors', '[]'))
        patient.assigned_doctors = assigned_doctors
        
        # Cache'e ekle
        self.patients[patient_id] = patient
        
        return patient
    
    def update_patient(self, patient_id, update_data):
        """
        Hasta bilgilerini günceller
        
        Args:
            patient_id (str): Hasta ID'si
            update_data (dict): Güncellenecek veriler
        
        Returns:
            bool: Güncelleme başarılı mı
        """
        try:
            patient = self.get_patient(patient_id)
            if not patient:
                print(f"Hasta bulunamadı: {patient_id}")
                return False
            
            # Güncelleme alanlarını kontrol et ve uygula
            updatable_fields = [
                'full_name', 'date_of_birth', 'gender', 'phone', 
                'emergency_contact', 'medical_conditions'
            ]
            
            for field in updatable_fields:
                if field in update_data:
                    setattr(patient, field, update_data[field])
            
            # Veritabanını güncelle
            if self.db.save_user(patient):
                # Cache'i güncelle
                self.patients[patient_id] = patient
                print(f"✅ Hasta güncellendi: {patient_id}")
                return True
            else:
                print("❌ Hasta veritabanında güncellenemedi")
                return False
                
        except Exception as e:
            print(f"❌ Hasta güncelleme hatası: {e}")
            return False
    
    def delete_patient(self, patient_id):
        """
        Hastayı siler (soft delete)
        
        Args:
            patient_id (str): Hasta ID'si
        
        Returns:
            bool: Silme başarılı mı
        """
        try:
            patient = self.get_patient(patient_id)
            if not patient:
                print(f"Hasta bulunamadı: {patient_id}")
                return False
            
            # Hastayı pasifleştir
            patient.is_active = False
            
            # Veritabanını güncelle
            if self.db.save_user(patient):
                # Cache'den kaldır
                if patient_id in self.patients:
                    del self.patients[patient_id]
                print(f"✅ Hasta silindi: {patient_id}")
                return True
            else:
                print("❌ Hasta veritabanında silinemedi")
                return False
                
        except Exception as e:
            print(f"❌ Hasta silme hatası: {e}")
            return False
    
    def get_all_patients(self, active_only=True):
        """
        Tüm hastaları getirir
        
        Args:
            active_only (bool): Sadece aktif hastaları getir
        
        Returns:
            list: Hasta nesneleri listesi
        """
        # Bu metod gerçek uygulamada veritabanından tüm hastaları getirir
        # Şimdilik demo veri döndürüyoruz
        demo_patients = [
            Patient(
                user_id="patient_001",
                username="ahmet_yilmaz",
                email="ahmet@test.com",
                password_hash="hashed_password_123",
                full_name="Ahmet Yılmaz",
                date_of_birth="1980-05-15",
                gender="Erkek",
                phone="+90 555 123 4567",
                medical_conditions=["Sleep Apnea", "Hipertansiyon"]
            ),
            Patient(
                user_id="patient_002",
                username="ayse_demir", 
                email="ayse@test.com",
                password_hash="hashed_password_456",
                full_name="Ayşe Demir",
                date_of_birth="1975-12-20",
                gender="Kadın",
                phone="+90 555 765 4321",
                medical_conditions=["Sleep Apnea", "Obezite"]
            )
        ]
        
        if active_only:
            return [p for p in demo_patients if p.is_active]
        return demo_patients
    
    def search_patients(self, search_term):
        """
        Hastaları ara
        
        Args:
            search_term (str): Arama terimi
        
        Returns:
            list: Bulunan hasta nesneleri listesi
        """
        all_patients = self.get_all_patients()
        
        # Arama terimine göre filtrele
        filtered_patients = []
        search_lower = search_term.lower()
        
        for patient in all_patients:
            # İsim, email veya kullanıcı adında ara
            if (search_lower in (patient.full_name or "").lower() or
                search_lower in patient.email.lower() or
                search_lower in patient.username.lower()):
                filtered_patients.append(patient)
        
        return filtered_patients
    
    def get_patient_stats(self):
        """
        Hasta istatistiklerini getirir
        
        Returns:
            dict: İstatistik verileri
        """
        all_patients = self.get_all_patients()
        active_patients = [p for p in all_patients if p.is_active]
        
        # Cinsiyet dağılımı
        gender_stats = {}
        for patient in active_patients:
            gender = patient.gender or 'Belirtilmemiş'
            gender_stats[gender] = gender_stats.get(gender, 0) + 1
        
        # Yaş dağılımı
        age_groups = {'18-30': 0, '31-45': 0, '46-60': 0, '60+': 0}
        for patient in active_patients:
            age = patient.calculate_age()
            if age:
                if 18 <= age <= 30:
                    age_groups['18-30'] += 1
                elif 31 <= age <= 45:
                    age_groups['31-45'] += 1
                elif 46 <= age <= 60:
                    age_groups['46-60'] += 1
                else:
                    age_groups['60+'] += 1
        
        return {
            'total_patients': len(all_patients),
            'active_patients': len(active_patients),
            'inactive_patients': len(all_patients) - len(active_patients),
            'gender_distribution': gender_stats,
            'age_distribution': age_groups,
            'average_medical_conditions': sum(len(p.medical_conditions) for p in active_patients) / len(active_patients) if active_patients else 0
        }