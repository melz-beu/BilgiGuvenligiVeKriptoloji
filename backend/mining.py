# Madencilik işlemleri - Makaledeki leading-zero algoritmasına uygun
import hashlib
import time
from datetime import datetime
from config import Config

class MiningEngine:
    """Madencilik motoru - Makaledeki leading-zero algoritmasını implemente eder"""
    
    def __init__(self, difficulty=Config.BLOCKCHAIN_DIFFICULTY):
        """
        Madencilik motoru oluşturur
        
        Args:
            difficulty (int): Zorluk seviyesi (1-5 arası)
        """
        self.difficulty = difficulty
        self.nonce = 0
        self.hash_operations = 0
    
    def leading_zero_count(self, hash_string):
        """
        Leading-zero sayısını hesaplar - Makaledeki algoritma
        
        Args:
            hash_string (str): Hash değeri
        
        Returns:
            int: Baştaki sıfır sayısı
        """
        count = 0
        for char in hash_string:
            if char == '0':
                count += 1
            else:
                break
        return count
    
    def calculate_hash(self, index, timestamp, data, previous_hash, nonce):
        """
        SHA256 hash hesaplar - Makaledeki standart
        
        Args:
            index (int): Blok indexi
            timestamp (str): Zaman damgası
            data (dict): Blok verisi
            previous_hash (str): Önceki hash
            nonce (int): Nonce değeri
        
        Returns:
            str: Hesaplanan hash
        """
        # Makaledeki formata uygun hash hesaplama
        import json
        block_string = f"{index}{timestamp}{json.dumps(data, sort_keys=True)}{previous_hash}{nonce}"
        return hashlib.sha256(block_string.encode()).hexdigest()
    
    def mine_block(self, index, timestamp, data, previous_hash):
        """
        Blok madenciliği yapar - Leading-zero bulma
        
        Args:
            index (int): Blok indexi
            timestamp (str): Zaman damgası
            data (dict): Blok verisi
            previous_hash (str): Önceki hash
        
        Returns:
            dict: Madencilik sonuçları
        """
        print(f"⛏️  Blok #{index} madenciliği başlıyor... Zorluk: {self.difficulty}")
        start_time = time.time()
        self.nonce = 0
        self.hash_operations = 0
        
        target_zeros = '0' * self.difficulty
        
        while True:
            current_hash = self.calculate_hash(index, timestamp, data, previous_hash, self.nonce)
            self.hash_operations += 1
            
            # Leading-zero kontrolü
            if current_hash.startswith(target_zeros):
                end_time = time.time()
                mining_time = end_time - start_time
                
                print(f"✅ Blok #{index} başarıyla madenci!")
                print(f"🔗 Hash: {current_hash}")
                print(f"🔢 Nonce: {self.nonce}")
                print(f"⏱️  Süre: {mining_time:.6f} saniye")
                print(f"🔄 Hash operasyonu: {self.hash_operations}")
                
                return {
                    'nonce': self.nonce,
                    'hash': current_hash,
                    'mining_time': mining_time,
                    'hash_operations': self.hash_operations,
                    'difficulty': self.difficulty
                }
            
            self.nonce += 1
            
            # Her 10000 denemede bir progress göster
            if self.nonce % 10000 == 0:
                print(f"⏳ Denenen nonce: {self.nonce}, Mevcut hash: {current_hash}")
    
    def benchmark_difficulty_levels(self, index, timestamp, data, previous_hash):
        """
        Tüm zorluk seviyelerinde performans testi yapar - Makaledeki deney
        
        Args:
            index (int): Blok indexi
            timestamp (str): Zaman damgası
            data (dict): Blok verisi
            previous_hash (str): Önceki hash
        
        Returns:
            dict: Tüm zorluk seviyeleri için sonuçlar
        """
        print("🧪 Zorluk seviyeleri performans testi başlıyor...")
        results = {}
        
        original_difficulty = self.difficulty
        
        for difficulty in range(1, 6):  # 1-5 arası zorluk seviyeleri
            self.difficulty = difficulty
            print(f"\n🔬 Zorluk seviyesi {difficulty} test ediliyor...")
            
            result = self.mine_block(index, timestamp, data, previous_hash)
            results[difficulty] = result
        
        # Orijinal zorluk seviyesine geri dön
        self.difficulty = original_difficulty
        
        return results
    
    def compare_with_existing_networks(self, mining_time):
        """
        Mevcut blockchain ağları ile performans karşılaştırması - Makaledeki tablo
        
        Args:
            mining_time (float): Bizim sistemin madencilik süresi
        
        Returns:
            dict: Karşılaştırma sonuçları
        """
        # Makaledeki referans değerler (saniye cinsinden)
        network_times = {
            'bitcoin': 600,  # 10 dakika
            'ethereum': 15,   # 15 saniye
            'litecoin': 9000, # 150 dakika
            'dogecoin': 60    # 60 saniye
        }
        
        comparison = {}
        for network, time_ in network_times.items():
            comparison[network] = {
                'their_time': time_,
                'our_time': mining_time,
                'faster_by': time_ - mining_time if time_ > mining_time else 0,
                'slower_by': mining_time - time_ if mining_time > time_ else 0,
                'is_faster': mining_time < time_
            }
        
        return comparison


class DifficultyManager:
    """Zorluk seviyesi yöneticisi - Makaledeki difficulty ayarlarını yönetir"""
    
    def __init__(self):
        self.difficulty_levels = {
            1: {
                'leading_zeros': 1,
                'example': '0xxxxxxxxxxx',
                'description': 'Çok Kolay - Hızlı işlemler için'
            },
            2: {
                'leading_zeros': 2,
                'example': '00xxxxxxxxxx',
                'description': 'Kolay - Önerilen IoT seviyesi'
            },
            3: {
                'leading_zeros': 3,
                'example': '000xxxxxxxxx',
                'description': 'Orta - Denge performans'
            },
            4: {
                'leading_zeros': 4,
                'example': '0000xxxxxxxx',
                'description': 'Zor - Yüksek güvenlik'
            },
            5: {
                'leading_zeros': 5,
                'example': '00000xxxxxxx',
                'description': 'Çok Zor - Maksimum güvenlik'
            }
        }
    
    def get_difficulty_settings(self, level):
        """
        Zorluk seviyesi ayarlarını getirir
        
        Args:
            level (int): Zorluk seviyesi (1-5)
        
        Returns:
            dict: Zorluk ayarları
        """
        return self.difficulty_levels.get(level, self.difficulty_levels[2])
    
    def get_all_difficulty_levels(self):
        """
        Tüm zorluk seviyelerini getirir
        
        Returns:
            dict: Tüm zorluk seviyeleri
        """
        return self.difficulty_levels