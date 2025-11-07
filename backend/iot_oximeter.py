# IoT Oksimetre entegrasyonu - Makaledeki Bluetooth oksimetre bağlantısı
import random
import time
from datetime import datetime
from models.medical_data import OximeterData, SleepApneaRecord

class VirtualOximeter:
    """Sanal Bluetooth Oksimetre - Gerçek cihaz simülasyonu"""
    
    def __init__(self, device_id="BT_OXIMETER_001"):
        """
        Sanal oksimetre oluşturur
        
        Args:
            device_id (str): Cihaz ID'si
        """
        self.device_id = device_id
        self.is_connected = False
        self.is_recording = False
        self.current_record = None
    
    def connect(self):
        """
        Bluetooth bağlantısı kurar - Makaledeki pairing işlemi
        
        Returns:
            bool: Bağlantı başarılı mı
        """
        print("📱 Bluetooth oksimetre bağlanıyor...")
        time.sleep(2)  # Bağlantı süresi simülasyonu
        
        self.is_connected = True
        print("✅ Oksimetre bağlantısı başarılı!")
        return True
    
    def disconnect(self):
        """Bluetooth bağlantısını keser"""
        self.is_connected = False
        self.is_recording = False
        print("📴 Oksimetre bağlantısı kesildi")
    
    def start_recording(self, patient_id, record_id):
        """
        Veri kaydı başlatır - Makaledeki data recording
        
        Args:
            patient_id (str): Hasta ID'si
            record_id (str): Kayıt ID'si
        
        Returns:
            bool: Kayıt başlatıldı mı
        """
        if not self.is_connected:
            print("❌ Önce oksimetreye bağlanın!")
            return False
        
        self.is_recording = True
        self.current_record = SleepApneaRecord(
            record_id=record_id,
            patient_id=patient_id,
            start_time=datetime.now().isoformat(),
            device_id=self.device_id
        )
        
        print(f"🎥 Veri kaydı başlatıldı - Kayıt ID: {record_id}")
        return True
    
    def stop_recording(self):
        """
        Veri kaydını durdurur
        
        Returns:
            SleepApneaRecord: Kayıt nesnesi
        """
        if not self.is_recording or not self.current_record:
            print("❌ Aktif kayıt bulunamadı!")
            return None
        
        self.is_recording = False
        self.current_record.end_time = datetime.now().isoformat()
        
        print(f"⏹️  Veri kaydı durduruldu - Toplam veri: {len(self.current_record.data_points)}")
        
        record = self.current_record
        self.current_record = None
        return record
    
    def generate_oximeter_data(self):
        """
        Oksimetre verisi üretir - Gerçek cihaz simülasyonu
        
        Returns:
            dict: SpO2 ve BPM verileri
        """
        # Gerçekçi SpO2 ve BPM değerleri üret
        # Normal SpO2: 95-100%, Sleep Apnea'da düşebilir
        spo2 = random.uniform(85.0, 99.0)
        
        # Normal BPM: 60-100, uyku sırasında değişebilir
        bpm = random.uniform(55.0, 85.0)
        
        return {
            'spo2': round(spo2, 1),
            'bpm': round(bpm, 1),
            'timestamp': datetime.now().isoformat()
        }
    
    def record_data_point(self, patient_id):
        """
        Tek veri noktası kaydeder
        
        Args:
            patient_id (str): Hasta ID'si
        
        Returns:
            OximeterData: Kaydedilen veri
        """
        if not self.is_recording:
            return None
        
        data = self.generate_oximeter_data()
        data_id = f"ox_data_{datetime.now().strftime('%Y%m%d_%H%M%S_%f')}"
        
        oximeter_data = OximeterData(
            data_id=data_id,
            patient_id=patient_id,
            spo2_value=data['spo2'],
            bpm_value=data['bpm'],
            timestamp=data['timestamp'],
            device_id=self.device_id
        )
        
        self.current_record.add_data_point(oximeter_data)
        return oximeter_data
    
    def continuous_recording(self, patient_id, duration_seconds=60, callback=None):
        """
        Sürekli veri kaydı yapar - Makaledeki data capture
        
        Args:
            patient_id (str): Hasta ID'si
            duration_seconds (int): Kayıt süresi (saniye)
            callback (function): Her veri noktası için callback
        
        Returns:
            SleepApneaRecord: Tamamlanan kayıt
        """
        if not self.start_recording(patient_id, f"record_{datetime.now().strftime('%Y%m%d_%H%M%S')}"):
            return None
        
        print(f"⏱️  {duration_seconds} saniyelik kayıt başlatılıyor...")
        
        start_time = time.time()
        while time.time() - start_time < duration_seconds and self.is_recording:
            # Her saniye bir veri noktası kaydet (makaledeki sampling rate)
            data_point = self.record_data_point(patient_id)
            
            if callback and data_point:
                callback(data_point)
            
            time.sleep(1)  # 1 saniye bekle
        
        return self.stop_recording()


class OximeterManager:
    """Oksimetre yöneticisi - Çoklu cihaz desteği"""
    
    def __init__(self):
        self.connected_devices = {}
        self.available_devices = [
            "BT_OXIMETER_001",
            "BT_OXIMETER_002", 
            "BT_OXIMETER_003"
        ]
    
    def scan_devices(self):
        """
        Kullanılabilir cihazları tarar
        
        Returns:
            list: Bulunan cihaz listesi
        """
        print("🔍 Bluetooth cihazları taranıyor...")
        time.sleep(1)
        return self.available_devices
    
    def connect_device(self, device_id):
        """
        Belirtilen cihaza bağlanır
        
        Args:
            device_id (str): Cihaz ID'si
        
        Returns:
            VirtualOximeter: Bağlı oksimetre nesnesi
        """
        if device_id not in self.available_devices:
            print(f"❌ Cihaz bulunamadı: {device_id}")
            return None
        
        oximeter = VirtualOximeter(device_id)
        if oximeter.connect():
            self.connected_devices[device_id] = oximeter
            return oximeter
        
        return None
    
    def disconnect_device(self, device_id):
        """Cihaz bağlantısını keser"""
        if device_id in self.connected_devices:
            self.connected_devices[device_id].disconnect()
            del self.connected_devices[device_id]
            print(f"✅ Cihaz bağlantısı kesildi: {device_id}")
    
    def get_connected_devices(self):
        """Bağlı cihazları getirir"""
        return list(self.connected_devices.keys())