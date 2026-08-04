import sqlite3
import pandas as pd
from pathlib import Path





def cargar_a_sqlite(csv):
    
    df = pd.read_csv(csv)
    
    DB_PATH = Path(__file__).resolve().parent.parent / "database.db"
    
    conn = sqlite3.connect(DB_PATH)
    
    conn.execute("""
                 CREATE TABLE IF NOT EXISTS bizi_data (
                    id INTEGER,
                    estado VARCHAR(255),
                    bicis_disponibles INTEGER,
                    anclajes_disponibles INTEGER,
                    last_updated DATETIME,
                    fecha DATE,
                    mes INTEGER,
                    dia INTEGER,
                    dia_semana VARCHAR(255),
                    hora INTEGER,
                    minutos INTEGER,
                    longitud REAL,
                    latitud REAL,
                    estacion INTEGER,
                    nombre_estacion VARCHAR(255),
                    PRIMARY KEY (estacion, last_updated)
                 )
                 """)
    
    
    conn.executemany(
        "INSERT OR IGNORE INTO bizi_data (id,estado,bicis_disponibles, anclajes_disponibles,last_updated,fecha,mes,dia,dia_semana,hora,minutos,longitud,latitud,estacion,nombre_estacion) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        df[["id","estado","bicis_disponibles","anclajes_disponibles","last_updated","fecha","mes","dia","dia_semana","hora","minutos","longitud","latitud","estacion","nombre_estacion"]].values.tolist()
    )
    
    conn.commit()
    conn.close()
    
    
    
    
    