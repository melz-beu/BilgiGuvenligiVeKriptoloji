# Flask Micro Web Server - Makaledeki Flask implementasyonu (DÜZELTİLMİŞ VERSİYON)
import sys
import os
# Mevcut dizini Python path'ine ekle
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import uuid
from datetime import datetime

from config import Config
from blockchain import Blockchain
from mining import MiningEngine, DifficultyManager
from iot_oximeter import OximeterManager
from database import DatabaseManager
from auth import AuthService, token_required, admin_required, doctor_or_admin_required
from models.patient import Patient
from models.doctor import Doctor
from models.admin import Admin
from models.medical_data import OximeterData, SleepApneaRecord

class LightMedChainAPI:
    """LightMedChain API Servisi - Makaledeki Flask uygulaması"""
    
    def __init__(self):
        self.app = Flask(__name__)
        self.app.config.from_object(Config)
        CORS(self.app)  # CORS desteği
        
        # Sistem bileşenlerini başlat
        self.blockchain = Blockchain()
        self.oximeter_manager = OximeterManager()
        self.database = DatabaseManager()
        self.mining_engine = MiningEngine()
        self.difficulty_manager = DifficultyManager()
        self.auth_service = AuthService()
        
        # API route'larını tanımla
        self.setup_routes()
        
        # Test verileri oluştur (geliştirme için)
        self.create_test_data()
    
    def setup_routes(self):
        """API route'larını tanımlar"""
        
        # Ana sayfa - Sistem durumu
        @self.app.route('/')
        def home():
            return jsonify({
                "message": "LightMedChain API - Medical Record Blockchain System",
                "version": "1.0",
                "status": "active",
                "timestamp": datetime.now().isoformat()
            })
        
        # Auth routes - Kimlik doğrulama endpoint'leri
        @self.app.route('/api/auth/login', methods=['POST'])
        def login():
            """Kullanıcı girişi"""
            try:
                data = request.get_json()
                
                if not data or 'username' not in data or 'password' not in data:
                    return jsonify({"error": "Kullanıcı adı ve şifre gerekiyor"}), 400
                
                auth_result = self.auth_service.authenticate_user(data['username'], data['password'])
                
                if auth_result:
                    return jsonify({
                        "message": "Giriş başarılı",
                        "token": auth_result['token'],
                        "user": auth_result['user']
                    })
                else:
                    return jsonify({"error": "Geçersiz kullanıcı adı veya şifre"}), 401
                    
            except Exception as e:
                return jsonify({"error": str(e)}), 500

        @self.app.route('/api/auth/register', methods=['POST'])
        def register():
            """Yeni kullanıcı kaydı"""
            try:
                data = request.get_json()
                
                required_fields = ['username', 'email', 'password', 'user_type']
                for field in required_fields:
                    if field not in data:
                        return jsonify({"error": f"Eksik alan: {field}"}), 400
                
                # Kullanıcı türü kontrolü
                if data['user_type'] not in ['patient', 'doctor', 'admin']:
                    return jsonify({"error": "Geçersiz kullanıcı türü"}), 400
                
                success = self.auth_service.register_user(data)
                
                if success:
                    return jsonify({"message": "Kullanıcı başarıyla kaydedildi"})
                else:
                    return jsonify({"error": "Kullanıcı kaydı başarısız"}), 400
                    
            except Exception as e:
                return jsonify({"error": str(e)}), 500

        @self.app.route('/api/auth/verify', methods=['POST'])
        @token_required
        def verify_token():
            """Token doğrulama"""
            return jsonify({
                "message": "Token geçerli",
                "user": {
                    "user_id": request.user_id,
                    "username": request.username,
                    "user_type": request.user_type
                }
            })

        # Blockchain routes
        @self.app.route('/api/blockchain/status', methods=['GET'])
        def get_blockchain_status():
            """Blockchain durumunu getirir"""
            stats = self.blockchain.get_chain_stats()
            return jsonify(stats)
        
        @self.app.route('/api/blockchain/chain', methods=['GET'])
        def get_full_chain():
            """Tam blockchain'i getirir"""
            chain_data = self.blockchain.to_dict()
            return jsonify(chain_data)
        
        @self.app.route('/api/blockchain/mine', methods=['POST'])
        def mine_block():
            """Yeni blok madenci"""
            try:
                mined_block = self.blockchain.mine_pending_data()
                if mined_block:
                    return jsonify({
                        "message": "Blok başarıyla madenci!",
                        "block": mined_block.to_dict(),
                        "chain_length": self.blockchain.get_chain_length()
                    })
                else:
                    return jsonify({"error": "Madencilik için veri yok"}), 400
            except Exception as e:
                return jsonify({"error": str(e)}), 500
        
        # Medical Data routes
        @self.app.route('/api/medical-data/record', methods=['POST'])
        @token_required
        def record_medical_data():
            """Tıbbi veri kaydı oluşturur"""
            try:
                data = request.get_json()
                
                # Gerekli alanları kontrol et
                required_fields = ['patient_id', 'spo2_value', 'bpm_value']
                for field in required_fields:
                    if field not in data:
                        return jsonify({"error": f"Eksik alan: {field}"}), 400
                
                # Oksimetre verisi oluştur
                data_id = f"med_data_{datetime.now().strftime('%Y%m%d_%H%M%S_%f')}"
                oximeter_data = OximeterData(
                    data_id=data_id,
                    patient_id=data['patient_id'],
                    spo2_value=data['spo2_value'],
                    bpm_value=data['bpm_value'],
                    device_id=data.get('device_id', 'BT_OXIMETER_001')
                )
                
                # Veritabanına kaydet
                self.database.save_medical_data(oximeter_data)
                
                # Blockchain'e ekle (pending data)
                self.blockchain.add_pending_data(oximeter_data.to_dict())
                
                return jsonify({
                    "message": "Tıbbi veri kaydedildi ve blockchain'e eklendi",
                    "data_id": data_id,
                    "ahi_index": oximeter_data.ahi_index
                })
                
            except Exception as e:
                return jsonify({"error": str(e)}), 500
        
        @self.app.route('/api/medical-data/patient/<patient_id>', methods=['GET'])
        @token_required
        def get_patient_medical_data(patient_id):
            """Hastanın tıbbi verilerini getirir"""
            try:
                # Veritabanından getir
                db_data = self.database.get_patient_medical_data(patient_id)
                
                # Blockchain'den ara
                blockchain_data = self.blockchain.search_medical_data(patient_id=patient_id)
                
                return jsonify({
                    "patient_id": patient_id,
                    "database_records": db_data,
                    "blockchain_records": blockchain_data,
                    "total_records": len(db_data) + len(blockchain_data)
                })
                
            except Exception as e:
                return jsonify({"error": str(e)}), 500
        
        # Oximeter IoT routes
        @self.app.route('/api/oximeter/scan', methods=['GET'])
        @token_required
        def scan_oximeter_devices():
            """Kullanılabilir oksimetre cihazlarını tara"""
            try:
                devices = self.oximeter_manager.scan_devices()
                return jsonify({
                    "available_devices": devices
                })
            except Exception as e:
                return jsonify({"error": str(e)}), 500
        
        @self.app.route('/api/oximeter/connect', methods=['POST'])
        @token_required
        def connect_oximeter():
            """Oksimetre cihazına bağlan"""
            try:
                data = request.get_json()
                device_id = data.get('device_id')
                
                if not device_id:
                    return jsonify({"error": "Cihaz ID'si gerekli"}), 400
                
                oximeter = self.oximeter_manager.connect_device(device_id)
                if oximeter:
                    return jsonify({
                        "message": "Oksimetre bağlantısı başarılı",
                        "device_id": device_id,
                        "is_connected": oximeter.is_connected
                    })
                else:
                    return jsonify({"error": "Cihaz bağlantısı başarısız"}), 400
                    
            except Exception as e:
                return jsonify({"error": str(e)}), 500
        
        # Mining ve Difficulty routes
        @self.app.route('/api/mining/difficulty', methods=['GET'])
        def get_difficulty_levels():
            """Tüm zorluk seviyelerini getirir"""
            levels = self.difficulty_manager.get_all_difficulty_levels()
            return jsonify(levels)
        
        @self.app.route('/api/mining/difficulty/<int:level>', methods=['POST'])
        @admin_required
        def set_difficulty_level(level):
            """Zorluk seviyesini ayarlar"""
            try:
                if level < 1 or level > 5:
                    return jsonify({"error": "Zorluk seviyesi 1-5 arası olmalı"}), 400
                
                self.blockchain.difficulty = level
                self.mining_engine.difficulty = level
                
                settings = self.difficulty_manager.get_difficulty_settings(level)
                
                return jsonify({
                    "message": f"Zorluk seviyesi {level} olarak ayarlandı",
                    "settings": settings
                })
                
            except Exception as e:
                return jsonify({"error": str(e)}), 500
        
        @self.app.route('/api/mining/benchmark', methods=['POST'])
        @admin_required
        def run_benchmark():
            """Performans benchmark testi çalıştırır"""
            try:
                # Test verisi oluştur
                test_data = {
                    "test_type": "performance_benchmark",
                    "timestamp": datetime.now().isoformat(),
                    "data_points": 10
                }
                
                # Tüm zorluk seviyelerinde test et
                results = self.mining_engine.benchmark_difficulty_levels(
                    index=self.blockchain.get_chain_length(),
                    timestamp=datetime.now().isoformat(),
                    data=test_data,
                    previous_hash=self.blockchain.get_latest_block().hash
                )
                
                return jsonify({
                    "benchmark_results": results
                })
                
            except Exception as e:
                return jsonify({"error": str(e)}), 500
        
        # System Management routes
        @self.app.route('/api/system/performance', methods=['GET'])
        @admin_required
        def get_system_performance():
            """Sistem performans metriklerini getirir"""
            chain_stats = self.blockchain.get_chain_stats()
            
            performance_data = {
                "blockchain": chain_stats,
                "mining_difficulty": self.blockchain.difficulty,
                "connected_devices": self.oximeter_manager.get_connected_devices(),
                "pending_transactions": len(self.blockchain.pending_data),
                "system_uptime": "active",
                "timestamp": datetime.now().isoformat()
            }
            
            return jsonify(performance_data)
    
    def create_test_data(self):
        """Test verileri oluşturur (geliştirme için)"""
        try:
            # Test hastası oluştur
            test_patient = Patient(
                user_id="patient_001",
                username="hasta",
                email="patient@test.com",
                password_hash=self.auth_service._hash_password("123456"),
                full_name="Ahmet Yılmaz",
                date_of_birth="1980-01-15",
                gender="Male"
            )
            
            # Test doktoru oluştur
            test_doctor = Doctor(
                user_id="doctor_001", 
                username="doktor",
                email="doctor@test.com",
                password_hash=self.auth_service._hash_password("123456"),
                full_name="Dr. Ayşe Demir",
                license_number="MED123456",
                specialization="Cardiology"
            )
            
            # Test admin oluştur
            test_admin = Admin(
                user_id="admin_001",
                username="admin", 
                email="admin@test.com",
                password_hash=self.auth_service._hash_password("123456"),
                full_name="Sistem Yöneticisi"
            )
            
            # Veritabanına kaydet
            self.database.save_user(test_patient)
            self.database.save_user(test_doctor)
            self.database.save_user(test_admin)
            
            print("✅ Test verileri oluşturuldu!")
            
        except Exception as e:
            print(f"⚠️  Test verileri oluşturulurken hata: {e}")
    
    def run(self, host='127.0.0.1', port=5000, debug=True):
        """
        Flask uygulamasını çalıştırır
        
        Args:
            host (str): Host adresi
            port (int): Port numarası
            debug (bool): Debug modu
        """
        print(f"🚀 LightMedChain API {host}:{port} adresinde başlatılıyor...")
        print("📋 Kullanılabilir Endpoint'ler:")
        print("   AUTH:")
        print("   POST /api/auth/login          - Kullanıcı girişi")
        print("   POST /api/auth/register       - Yeni kullanıcı kaydı")
        print("   POST /api/auth/verify         - Token doğrulama")
        print("   BLOCKCHAIN:")
        print("   GET  /api/blockchain/status   - Blockchain durumu")
        print("   GET  /api/blockchain/chain    - Tam blockchain")
        print("   POST /api/blockchain/mine     - Yeni blok madenci")
        print("   MEDICAL DATA:")
        print("   POST /api/medical-data/record - Tıbbi veri kaydet")
        print("   GET  /api/medical-data/patient/<id> - Hasta verileri")
        print("   OXIMETER:")
        print("   GET  /api/oximeter/scan       - Cihazları tara")
        print("   POST /api/oximeter/connect    - Cihaza bağlan")
        print("   MINING:")
        print("   GET  /api/mining/difficulty   - Zorluk seviyeleri")
        print("   POST /api/mining/benchmark    - Performans testi")
        print("   SYSTEM:")
        print("   GET  /api/system/performance  - Sistem performansı")
        
        self.app.run(host=host, port=port, debug=debug)


# Uygulamayı çalıştır
if __name__ == '__main__':
    api = LightMedChainAPI()
    api.run()