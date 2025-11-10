# Blockchain yönetimi - Zincir işlemleri ve doğrulama
import json
from datetime import datetime
from block import Block, GenesisBlock
from config import Config

class Blockchain:
    """Blockchain sınıfı - Tüm zincir işlemlerini yönetir"""
    
    def __init__(self, difficulty=Config.BLOCKCHAIN_DIFFICULTY,  database_manager=None ):
        """
        Blockchain nesnesi oluşturur
        
        Args:
            difficulty (int): Madencilik zorluk seviyesi
        """
        # ⭐ DATABASE MANAGER'ı kaydedelim
        self.database = database_manager

                # ⭐ DATABASE'DEN YÜKLEME YAPALIM
        saved_state = self.load_from_database()
        if saved_state:
            print("✅ Önceki blockchain veritabanından yüklendi!")
            self.chain = saved_state['chain']
            self.difficulty = saved_state['difficulty']
        else:
            print("🌱 Yeni genesis bloğu oluşturuldu!")
            self.chain = [self.create_genesis_block()]
            self.difficulty = difficulty
        self.pending_data = []  # Blok oluşturulmayı bekleyen veriler
        self.mining_reward = Config.BLOCKCHAIN_REWARD
    def load_from_database(self):
        """Blockchain'i veritabanından yükler"""
        if not self.database:
            print("⚠️  Database manager bulunamadı - yeni zincir başlatılıyor")
            return None
        
        try:
            saved_state = self.database.get_blockchain_state()
            if not saved_state:
                print("ℹ️  Kayıtlı blockchain bulunamadı - yeni başlatılıyor")
                return None
            
            # JSON verisini parse et
            chain_data = json.loads(saved_state['chain_data'])
            
            # Dict'leri Block nesnelerine dönüştür
            chain_objects = []
            for block_dict in chain_data['chain']:
                block = Block(
                    index=block_dict['index'],
                    timestamp=block_dict['timestamp'],
                    data=block_dict['data'],
                    previous_hash=block_dict['previous_hash'],
                    nonce=block_dict['nonce'],
                    hash_value=block_dict['hash']  # Önceden hesaplanmış hash
                )
                chain_objects.append(block)
            
            return {
                'chain': chain_objects,
                'difficulty': chain_data['difficulty']
            }
            
        except Exception as e:
            print(f"❌ Blockchain yükleme hatası: {e}")
            return None

    def save_to_database(self):
        """Blockchain'i veritabanına kaydeder"""
        if not self.database:
            print("⚠️  Database manager bulunamadı - kayıt yapılamadı")
            return False
        
        try:
            # Blockchain verisini hazırla
            chain_data = {
                'chain': [block.to_dict() for block in self.chain],
                'difficulty': self.difficulty
            }
            
            # JSON'a dönüştür
            chain_json = json.dumps(chain_data, indent=2)
            
            # Veritabanına kaydet
            success = self.database.save_blockchain_state(
                chain_data=chain_json,
                difficulty=self.difficulty
            )
            
            if success:
                print(f"💾 Blockchain kaydedildi! Blok sayısı: {len(self.chain)}")
            else:
                print("❌ Blockchain kaydedilemedi!")
                
            return success
            
        except Exception as e:
            print(f"❌ Blockchain kaydetme hatası: {e}")
            return False
    
    def create_genesis_block(self):
        """Genesis bloğu oluşturur ve döndürür"""
        return GenesisBlock()
    
    def get_latest_block(self):
        """Zincirdeki son bloğu döndürür"""
        return self.chain[-1]
    
    def add_pending_data(self, medical_data):
        """
        Blok oluşturulmayı bekleyen veri listesine yeni veri ekler
        
        Args:
            medical_data (dict): Tıbbi veri kaydı
        
        Returns:
            bool: Ekleme başarılı mı
        """
        try:
            self.pending_data.append(medical_data)
            print(f"📥 Bekleyen veri eklendi: {medical_data.get('record_id', 'Unknown')}")
            return True
        except Exception as e:
            print(f"❌ Veri eklenirken hata: {e}")
            return False
    
    def mine_pending_data(self, miner_address="medical_system"):
        """
        Bekleyen verileri içeren yeni blok oluşturur ve madenciliği yapar
        
        Args:
            miner_address (str): Madencinin adresi (sistem tarafından yapıldığı için sabit)
        
        Returns:
            Block: Oluşturulan blok veya None
        """
        if not self.pending_data:
            print("⚠️  Madencilik için bekleyen veri yok!")
            return None
        
        print(f"⛏️  {len(self.pending_data)} veri kaydı için madencilik başlıyor...")
        
        # Yeni blok oluştur
        latest_block = self.get_latest_block()
        new_block = Block(
            index=len(self.chain),
            timestamp=datetime.now().isoformat(),
            data=self.pending_data.copy(),  # Bekleyen tüm verileri al
            previous_hash=latest_block.hash
        )
        
        # Bloku mine et (leading-zero bulma)
        start_time = datetime.now()
        new_block.mine_block(self.difficulty)
        end_time = datetime.now()
        
        # Madencilik süresini hesapla
        mining_time = (end_time - start_time).total_seconds()
        print(f"⏱️  Madencilik süresi: {mining_time:.6f} saniye")
        
        # Bloğu zincire ekle
        self.chain.append(new_block)
        
        # Bekleyen verileri temizle
        self.pending_data = []
        
        # ⭐ YENİ: OTOMATİK DATABASE'E KAYDET
        self.save_to_database()

        print(f"✅ Blok #{new_block.index} zincire eklendi!")
        print(f"📊 Zincir uzunluğu: {len(self.chain)}")
        
        return new_block
    
    def is_chain_valid(self):
        """
        Blockchain'in geçerliliğini kontrol eder
        
        Returns:
            bool: Zincir geçerli mi
        """
        # Tüm blokları kontrol et (genesis bloğundan başlayarak)
        for i in range(1, len(self.chain)):
            current_block = self.chain[i]
            previous_block = self.chain[i - 1]
            
            # Mevcut bloğun hash'i doğru mu?
            if not current_block.is_valid():
                print(f"❌ Blok #{current_block.index} geçersiz hash!")
                return False
            
            # Önceki bloğun hash'i mevcut blokta doğru gösteriliyor mu?
            if current_block.previous_hash != previous_block.hash:
                print(f"❌ Blok #{current_block.index} önceki hash uyuşmuyor!")
                return False
        
        print("✅ Blockchain geçerli!")
        return True
    
    def get_chain_length(self):
        """Zincir uzunluğunu döndürür"""
        return len(self.chain)
    
    def get_block_by_index(self, index):
        """
        İndex numarasına göre blok döndürür
        
        Args:
            index (int): Blok index numarası
        
        Returns:
            Block: İstenen blok veya None
        """
        if 0 <= index < len(self.chain):
            return self.chain[index]
        return None
    
    def get_block_by_hash(self, block_hash):
        """
        Hash değerine göre blok döndürür
        
        Args:
            block_hash (str): Aranan hash değeri
        
        Returns:
            Block: Bulunan blok veya None
        """
        for block in self.chain:
            if block.hash == block_hash:
                return block
        return None
    
    def search_medical_data(self, patient_id=None, record_id=None):
        """
        Tıbbi verileri arar
        
        Args:
            patient_id (str): Hasta ID'si
            record_id (str): Kayıt ID'si
        
        Returns:
            list: Bulunan veriler listesi
        """
        results = []
        
        for block in self.chain:
            # Genesis bloğunu atla
            if block.index == 0:
                continue
            
            # Bloktaki tüm verileri kontrol et
            for medical_data in block.data:
                match = True
                
                if patient_id and medical_data.get('patient_id') != patient_id:
                    match = False
                
                if record_id and medical_data.get('record_id') != record_id:
                    match = False
                
                if match:
                    results.append({
                        'block_index': block.index,
                        'block_hash': block.hash,
                        'block_timestamp': block.timestamp,
                        'medical_data': medical_data
                    })
        
        return results
    
    def get_chain_stats(self):
        """Blockchain istatistiklerini döndürür"""
        total_blocks = len(self.chain)
        total_transactions = sum(len(block.data) for block in self.chain if block.index > 0)
        
        return {
            'total_blocks': total_blocks,
            'total_transactions': total_transactions,
            'difficulty': self.difficulty,
            'pending_transactions': len(self.pending_data),
            'is_valid': self.is_chain_valid()
        }
    
    def to_dict(self):
        """Blockchain nesnesini sözlük formatına dönüştürür"""
        return {
            "chain": [block.to_dict() for block in self.chain],
            "difficulty": self.difficulty,
            "pending_data": self.pending_data,
            "mining_reward": self.mining_reward
        }
    
    def to_json(self):
        """Blockchain nesnesini JSON formatına dönüştürür"""
        return json.dumps(self.to_dict(), indent=2)