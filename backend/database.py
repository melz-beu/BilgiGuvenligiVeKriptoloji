# Veritabanı işlemleri - Kullanıcı ve sistem verilerini yönetir
import json
import sqlite3
from pathlib import Path
from config import Config

class DatabaseManager:
    """Veritabanı yöneticisi - Tüm veritabanı işlemlerini yönetir"""
    
    def __init__(self, db_path=Config.DATABASE_URI):
        """
        Veritabanı yöneticisi oluşturur
        
        Args:
            db_path (str): Veritabanı dosya yolu
        """
        self.db_path = db_path.replace('sqlite:///', '')
        self.init_database()
    
    def get_connection(self):
        """Veritabanı bağlantısı oluşturur ve döndürür"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row  # Sütunlara isimle erişim sağlar
            return conn
        except sqlite3.Error as e:
            print(f"❌ Veritabanı bağlantı hatası: {e}")
            return None
    
    def init_database(self):
        """Veritabanını ve gerekli tabloları oluşturur"""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                # Kullanıcılar tablosu
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS users (
                        user_id TEXT PRIMARY KEY,
                        username TEXT UNIQUE NOT NULL,
                        email TEXT UNIQUE NOT NULL,
                        password_hash TEXT NOT NULL,
                        user_type TEXT NOT NULL,
                        full_name TEXT,
                        date_of_birth TEXT,
                        gender TEXT,
                        phone TEXT,
                        emergency_contact TEXT,
                        license_number TEXT,
                        specialization TEXT,
                        hospital TEXT,
                        permissions TEXT,
                        medical_conditions TEXT,
                        assigned_doctors TEXT,
                        patients TEXT,
                        is_active BOOLEAN DEFAULT 1,
                        created_at TEXT NOT NULL
                    )
                ''')
                
                # Tıbbi veriler tablosu
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS medical_data (
                        data_id TEXT PRIMARY KEY,
                        patient_id TEXT NOT NULL,
                        data_type TEXT NOT NULL,
                        spo2_value REAL,
                        bpm_value REAL,
                        ahi_index TEXT,
                        timestamp TEXT NOT NULL,
                        device_id TEXT,
                        is_processed BOOLEAN DEFAULT 0,
                        FOREIGN KEY (patient_id) REFERENCES users (user_id)
                    )
                ''')
                
                # Sleep Apnea kayıtları tablosu
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS sleep_apnea_records (
                        record_id TEXT PRIMARY KEY,
                        patient_id TEXT NOT NULL,
                        start_time TEXT NOT NULL,
                        end_time TEXT,
                        device_id TEXT,
                        data_points TEXT,
                        block_hash TEXT,
                        is_mined BOOLEAN DEFAULT 0,
                        average_metrics TEXT,
                        FOREIGN KEY (patient_id) REFERENCES users (user_id)
                    )
                ''')
                
                # Blockchain durumu tablosu
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS blockchain_state (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        chain_data TEXT NOT NULL,
                        difficulty INTEGER DEFAULT 2,
                        last_updated TEXT NOT NULL
                    )
                ''')
                
                conn.commit()
                print("✅ Veritabanı tabloları başarıyla oluşturuldu!")
                
        except sqlite3.Error as e:
            print(f"❌ Veritabanı başlatma hatası: {e}")
    
    def save_user(self, user):
        """
        Kullanıcıyı veritabanına kaydeder
        
        Args:
            user: Kaydedilecek kullanıcı nesnesi
        
        Returns:
            bool: Kayıt başarılı mı
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                user_dict = user.to_dict()
                
                # DEBUG: Password hash kontrolü
                print(f"🔍 DEBUG - Password hash in user_dict: {repr(user_dict.get('password_hash'))}")
                print(f"🔍 DEBUG - All keys in user_dict: {list(user_dict.keys())}")
                
                # Listeleri JSON string'e dönüştür
                medical_conditions = json.dumps(user_dict.get('medical_conditions', []))
                assigned_doctors = json.dumps(user_dict.get('assigned_doctors', []))
                patients = json.dumps(user_dict.get('patients', []))
                permissions = json.dumps(user_dict.get('permissions', []))
                
                cursor.execute('''
                    INSERT OR REPLACE INTO users 
                    (user_id, username, email, password_hash, user_type, full_name, 
                    date_of_birth, gender, phone, emergency_contact, license_number,
                    specialization, hospital, permissions, medical_conditions,
                    assigned_doctors, patients, is_active, created_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    user_dict['user_id'],
                    user_dict['username'],
                    user_dict['email'],
                    user_dict.get('password_hash', ''),  # Bu satırı kontrol ediyoruz
                    user_dict['user_type'],
                    user_dict.get('full_name'),
                    user_dict.get('date_of_birth'),
                    user_dict.get('gender'),
                    user_dict.get('phone'),
                    user_dict.get('emergency_contact'),
                    user_dict.get('license_number'),
                    user_dict.get('specialization'),
                    user_dict.get('hospital'),
                    permissions,
                    medical_conditions,
                    assigned_doctors,
                    patients,
                    user_dict.get('is_active', True),
                    user_dict['created_at']
                ))
                
                conn.commit()
                print(f"✅ Kullanıcı kaydedildi: {user_dict['username']}")
                return True
            
        except sqlite3.Error as e:
            print(f"❌ Kullanıcı kaydetme hatası: {e}")
            return False
    
    def get_user_by_username(self, username):
        """
        Kullanıcı adına göre kullanıcı getirir
        
        Args:
            username (str): Kullanıcı adı
        
        Returns:
            dict: Kullanıcı bilgileri veya None
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute('SELECT * FROM users WHERE username = ? AND is_active = 1', (username,))
                user_data = cursor.fetchone()
                
                if user_data:
                    return dict(user_data)
                return None
                
        except sqlite3.Error as e:
            print(f"❌ Kullanıcı getirme hatası: {e}")
            return None
    
    def get_user_by_id(self, user_id):
        """
        Kullanıcı ID'sine göre kullanıcı getirir
        
        Args:
            user_id (str): Kullanıcı ID'si
        
        Returns:
            dict: Kullanıcı bilgileri veya None
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute('SELECT * FROM users WHERE user_id = ? AND is_active = 1', (user_id,))
                user_data = cursor.fetchone()
                
                if user_data:
                    return dict(user_data)
                return None
                
        except sqlite3.Error as e:
            print(f"❌ Kullanıcı getirme hatası: {e}")
            return None
    
    def save_medical_data(self, medical_data):
        """
        Tıbbi veriyi veritabanına kaydeder
        
        Args:
            medical_data: Kaydedilecek tıbbi veri nesnesi
        
        Returns:
            bool: Kayıt başarılı mı
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                data_dict = medical_data.to_dict()
                
                cursor.execute('''
                    INSERT INTO medical_data 
                    (data_id, patient_id, data_type, spo2_value, bpm_value, ahi_index, timestamp, device_id, is_processed)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    data_dict['data_id'],
                    data_dict['patient_id'],
                    data_dict['data_type'],
                    data_dict.get('spo2_value'),
                    data_dict.get('bpm_value'),
                    data_dict.get('ahi_index'),
                    data_dict['timestamp'],
                    data_dict.get('device_id'),
                    data_dict.get('is_processed', False)
                ))
                
                conn.commit()
                print(f"✅ Tıbbi veri kaydedildi: {data_dict['data_id']}")
                return True
                
        except sqlite3.Error as e:
            print(f"❌ Tıbbi veri kaydetme hatası: {e}")
            return False
    
    def get_patient_medical_data(self, patient_id, limit=100):
        """
        Hastanın tıbbi verilerini getirir
        
        Args:
            patient_id (str): Hasta ID'si
            limit (int): Getirilecek maksimum kayıt sayısı
        
        Returns:
            list: Tıbbi veriler listesi
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute('''
                    SELECT * FROM medical_data 
                    WHERE patient_id = ? 
                    ORDER BY timestamp DESC 
                    LIMIT ?
                ''', (patient_id, limit))
                
                medical_data = [dict(row) for row in cursor.fetchall()]
                return medical_data
                
        except sqlite3.Error as e:
            print(f"❌ Tıbbi veri getirme hatası: {e}")
            return []
    
    def get_all_patients(self):
        """
        Tüm hastaları getirir
        
        Returns:
            list: Hasta verileri listesi
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute('''
                    SELECT * FROM users 
                    WHERE user_type = 'patient' AND is_active = 1
                    ORDER BY created_at DESC
                ''')
                
                patients = [dict(row) for row in cursor.fetchall()]
                return patients
                
        except sqlite3.Error as e:
            print(f"❌ Hasta getirme hatası: {e}")
            return []
    
    def save_blockchain_state(self, chain_data, difficulty):
        """
        Blockchain durumunu kaydeder
        
        Args:
            chain_data (str): Blockchain verisi (JSON string)
            difficulty (int): Mevcut zorluk seviyesi
        
        Returns:
            bool: Kayıt başarılı mı
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                # Önceki kayıtları temizle
                cursor.execute('DELETE FROM blockchain_state')
                
                # Yeni kaydı ekle
                cursor.execute('''
                    INSERT INTO blockchain_state 
                    (chain_data, difficulty, last_updated)
                    VALUES (?, ?, ?)
                ''', (
                    chain_data,
                    difficulty,
                    datetime.now().isoformat()
                ))
                
                conn.commit()
                print("✅ Blockchain durumu kaydedildi!")
                return True
                
        except sqlite3.Error as e:
            print(f"❌ Blockchain durumu kaydetme hatası: {e}")
            return False
    
    def get_blockchain_state(self):
        """
        Blockchain durumunu getirir
        
        Returns:
            dict: Blockchain durumu veya None
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute('SELECT * FROM blockchain_state ORDER BY id DESC LIMIT 1')
                state_data = cursor.fetchone()
                
                if state_data:
                    return dict(state_data)
                return None
                
        except sqlite3.Error as e:
            print(f"❌ Blockchain durumu getirme hatası: {e}")
            return None

# datetime import'u ekleyelim
from datetime import datetime