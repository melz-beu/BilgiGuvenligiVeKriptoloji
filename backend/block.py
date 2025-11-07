# Güncellenmiş blok yapısı - Makaleye %100 uyumlu
import hashlib
import json
from datetime import datetime
from config import Config
from mining import MiningEngine

class Block:
    """Güncellenmiş blok sınıfı - Makaleye %100 uyumlu"""
    
    def __init__(self, index, timestamp, data, previous_hash, nonce=0, hash_value=None):
        """
        Blok nesnesi oluşturur - Makaledeki yapıya uygun
        
        Args:
            index (int): Blok numarası
            timestamp (str): Oluşturulma zamanı
            data (dict): Blokta saklanacak veri (medical records)
            previous_hash (str): Önceki bloğun hash değeri
            nonce (int): Proof-of-Work için sayı
            hash_value (str): Önceden hesaplanmış hash (opsiyonel)
        """
        self.index = index
        self.timestamp = timestamp
        self.data = data  # Tıbbi veri kayıtları - makaledeki gibi
        self.previous_hash = previous_hash
        self.nonce = nonce
        self.hash = hash_value or self.calculate_hash()
    
    def calculate_hash(self):
        """
        Blok hash'ini hesaplar - Makaledeki SHA256 standardı
        
        Returns:
            str: Hesaplanan hash değeri (64 karakter hex)
        """
        # Makaledeki hash hesaplama formatına uygun
        block_string = f"{self.index}{self.timestamp}{json.dumps(self.data, sort_keys=True)}{self.previous_hash}{self.nonce}"
        return hashlib.sha256(block_string.encode()).hexdigest()
    
    def mine_block(self, difficulty):
        """
        Proof-of-Work madenciliği yapar - Leading-zero bulma
        
        Args:
            difficulty (int): Zorluk seviyesi (1-5 arası)
        """
        mining_engine = MiningEngine(difficulty)
        
        # Madencilik işlemini başlat
        mining_result = mining_engine.mine_block(
            self.index, 
            self.timestamp, 
            self.data, 
            self.previous_hash
        )
        
        # Sonuçları bloka kaydet
        self.nonce = mining_result['nonce']
        self.hash = mining_result['hash']
        
        return mining_result
    
    def get_leading_zeros_count(self):
        """
        Blok hash'inde kaç tane leading-zero olduğunu sayar
        
        Returns:
            int: Leading-zero sayısı
        """
        count = 0
        for char in self.hash:
            if char == '0':
                count += 1
            else:
                break
        return count
    
    def is_valid(self, difficulty=None):
        """
        Blok hash'inin geçerli olup olmadığını kontrol eder
        
        Args:
            difficulty (int): Beklenen zorluk seviyesi
        
        Returns:
            bool: Blok geçerli mi
        """
        # Hash değeri doğru hesaplanmış mı?
        calculated_hash = self.calculate_hash()
        if self.hash != calculated_hash:
            return False
        
        # Zorluk seviyesi kontrolü (isteğe bağlı)
        if difficulty is not None:
            expected_zeros = '0' * difficulty
            if not self.hash.startswith(expected_zeros):
                return False
        
        return True
    
    def to_dict(self):
        """Blok nesnesini sözlük formatına dönüştürür - API için"""
        return {
            "index": self.index,
            "timestamp": self.timestamp,
            "data": self.data,
            "previous_hash": self.previous_hash,
            "hash": self.hash,
            "nonce": self.nonce,
            "leading_zeros": self.get_leading_zeros_count()
        }
    
    def to_json(self):
        """Blok nesnesini JSON formatına dönüştürür"""
        return json.dumps(self.to_dict(), indent=2)


class GenesisBlock(Block):
    """Genesis Blok sınıfı - Makaledeki gibi özel ilk blok"""
    
    def __init__(self):
        """
        Genesis blok oluşturur - Makaledeki yapıya uygun
        """
        # Makaledeki genesis blok yapısına uygun
        genesis_data = {
            "message": "LightMedChain Genesis Block - Medical Record System",
            "creator": "LightMedChain Framework",
            "medical_system": "Sleep Apnea Monitoring",
            "timestamp": datetime.now().isoformat(),
            "version": "1.0"
        }
        
        super().__init__(
            index=0,
            timestamp=datetime.now().isoformat(),
            data=genesis_data,
            previous_hash="0" * 64,  # 64 karakterlik sıfır - standart
            nonce=0
        )
        
        # Genesis bloğu önceden mine edilmiş kabul edilir
        print("🌱 Genesis Blok oluşturuldu! - Makaleye uygun")