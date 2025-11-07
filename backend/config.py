# Yapılandırma ayarları - Sistem geneli sabitler ve ayarlar
import os
from datetime import timedelta

class Config:
    """Ana yapılandırma sınıfı - Tüm sistem ayarları burada tanımlanır"""
    
    # Flask ayarları
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'lightmedchain-secret-key-2024'
    DEBUG = True
    
    # JWT Ayarları
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-key-2024'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)
    
    # Blockchain ayarları
    BLOCKCHAIN_DIFFICULTY = 2  # Makalede belirtilen optimal zorluk seviyesi
    BLOCKCHAIN_REWARD = 0  # Madencilik ödülü (sağlık uygulamasında gerek yok)
    
    # Veritabanı ayarları
    DATABASE_URI = os.environ.get('DATABASE_URI') or 'sqlite:///lightmedchain.db'
    
    # API ayarları
    API_VERSION = 'v1'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB max file size
    
    # Bluetooth/IoT ayarları
    OXIMETER_DATA_TYPES = ['SpO2', 'BPM']  # Desteklenen veri türleri
    SAMPLING_RATE = 1  # Saniyede 1 örnek (makaleye uygun)