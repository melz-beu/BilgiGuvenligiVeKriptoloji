# Tıbbi veri modeli - Oksimetre verileri ve medikal kayıtlar
from datetime import datetime
import json

class MedicalData:
    """Tıbbi veri temel sınıfı - Tüm medikal kayıtlar için temel model"""
    
    def __init__(self, data_id, patient_id, data_type, value, timestamp=None, device_id=None):
        """
        Tıbbi veri nesnesi oluşturur
        
        Args:
            data_id (str): Benzersiz veri ID'si
            patient_id (str): Hasta ID'si
            data_type (str): Veri türü ('SpO2', 'BPM')
            value (float): Veri değeri
            timestamp (str): Kayıt zaman damgası
            device_id (str): Cihaz ID'si
        """
        self.data_id = data_id
        self.patient_id = patient_id
        self.data_type = data_type
        self.value = value
        self.timestamp = timestamp or datetime.now().isoformat()
        self.device_id = device_id
        self.is_processed = False
    
    def to_dict(self):
        """Tıbbi veri nesnesini sözlük formatına dönüştürür"""
        return {
            'data_id': self.data_id,
            'patient_id': self.patient_id,
            'data_type': self.data_type,
            'value': self.value,
            'timestamp': self.timestamp,
            'device_id': self.device_id,
            'is_processed': self.is_processed
        }
    
    def to_json(self):
        """Tıbbi veri nesnesini JSON formatına dönüştürür"""
        return json.dumps(self.to_dict(), indent=2)


class OximeterData(MedicalData):
    """Oksimetre veri sınıfı - SpO2 ve BPM verilerini içerir"""
    
    def __init__(self, data_id, patient_id, spo2_value, bpm_value, timestamp=None, device_id="BT_OXIMETER_001"):
        """
        Oksimetre veri nesnesi oluşturur
        
        Args:
            spo2_value (float): Oksijen satürasyon değeri (%)
            bpm_value (float): Kalp atış hızı (BPM)
        """
        super().__init__(data_id, patient_id, 'OXIMETER', None, timestamp, device_id)
        self.spo2_value = spo2_value
        self.bpm_value = bpm_value
        self.ahi_index = self.calculate_ahi()  # AHI indeksini hesapla
    
    def calculate_ahi(self):
        """
        Apnea-Hypopnea Index (AHI) hesaplar
        Makaledeki formüle göre basitleştirilmiş hesaplama
        """
        # Basitleştirilmiş AHI hesaplama - gerçek uygulamada daha karmaşık olacaktır
        if self.spo2_value < 85:
            return "Severe"
        elif self.spo2_value < 90:
            return "Moderate"
        elif self.spo2_value < 95:
            return "Mild"
        else:
            return "Normal"
    
    def to_dict(self):
        """Oksimetre veri nesnesini sözlük formatına dönüştürür"""
        base_dict = super().to_dict()
        base_dict.update({
            'spo2_value': self.spo2_value,
            'bpm_value': self.bpm_value,
            'ahi_index': self.ahi_index,
            'data_type': 'OXIMETER'  # Üst sınıftaki data_type'ı override et
        })
        return base_dict


class SleepApneaRecord:
    """Sleep Apnea kayıt sınıfı - Bir kayıt oturumundaki tüm verileri içerir"""
    
    def __init__(self, record_id, patient_id, start_time, end_time=None, device_id="BT_OXIMETER_001"):
        """
        Sleep Apnea kayıt nesnesi oluşturur
        
        Args:
            record_id (str): Benzersiz kayıt ID'si
            patient_id (str): Hasta ID'si
            start_time (str): Kayıt başlangıç zamanı
            end_time (str): Kayıt bitiş zamanı
            device_id (str): Kullanılan cihaz ID'si
        """
        self.record_id = record_id
        self.patient_id = patient_id
        self.start_time = start_time
        self.end_time = end_time
        self.device_id = device_id
        self.data_points = []  # Oksimetre veri noktaları listesi
        self.block_hash = None  # Blockchain'deki hash değeri
        self.is_mined = False  # Blockchain'e eklenip eklenmediği
    
    def add_data_point(self, oximeter_data):
        """Kayda yeni veri noktası ekler"""
        self.data_points.append(oximeter_data)
    
    def calculate_average_metrics(self):
        """Ortalama metrikleri hesaplar"""
        if not self.data_points:
            return None
        
        avg_spo2 = sum(point.spo2_value for point in self.data_points) / len(self.data_points)
        avg_bpm = sum(point.bpm_value for point in self.data_points) / len(self.data_points)
        
        return {
            'average_spo2': avg_spo2,
            'average_bpm': avg_bpm,
            'total_data_points': len(self.data_points),
            'duration_minutes': self.calculate_duration()
        }
    
    def calculate_duration(self):
        """Kayıt süresini hesaplar (dakika cinsinden)"""
        if not self.end_time:
            return 0
        
        start = datetime.fromisoformat(self.start_time)
        end = datetime.fromisoformat(self.end_time)
        duration = (end - start).total_seconds() / 60
        return duration
    
    def to_dict(self):
        """Sleep Apnea kayıt nesnesini sözlük formatına dönüştürür"""
        return {
            'record_id': self.record_id,
            'patient_id': self.patient_id,
            'start_time': self.start_time,
            'end_time': self.end_time,
            'device_id': self.device_id,
            'data_points': [point.to_dict() for point in self.data_points],
            'metrics': self.calculate_average_metrics(),
            'block_hash': self.block_hash,
            'is_mined': self.is_mined
        }