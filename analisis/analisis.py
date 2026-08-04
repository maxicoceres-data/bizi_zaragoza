import pandas as pd
from pathlib import Path
import sys
PATH = Path(__file__).resolve().parent.parent
sys.path.append(str(PATH))
from src.data import recoger_data
from src.cargar_sqlite import cargar_a_sqlite

# Direcciones de los archivos
DATA_PATH = PATH / "data"
RAW_PATH = DATA_PATH / "raw"
PROCESSED_PATH = DATA_PATH / "processed"

#recolección de los datos
url = "https://www.zaragoza.es/sede/servicio/urbanismo-infraestructuras/estacion-bicicleta.json?rows=300"
datos = recoger_data(url)


df = pd.json_normalize(datos["result"])
pd.set_option('display.max_colwidth', None)
df.to_csv(RAW_PATH / "datos_crudos.csv")




#limpieza del dataframe
columnas_eliminar = ["about","estadoEstacion","tipoEquipamiento","icon","title","description","descripcion","geometry.type"]
df = df.drop(columns=columnas_eliminar)


#normalizacion de las columnas
mapeo = {
    "bicisDisponibles" :"bicis_disponibles",
    "anclajesDisponibles" : "anclajes_disponibles",
    "lastUpdated" : "last_updated"
}

df = df.rename(columns=mapeo)



#columna fecha
df["last_updated"] = pd.to_datetime(df["last_updated"])
df["fecha"] = df["last_updated"].dt.date
df["mes"] = df["last_updated"].dt.month
df["dia"] = df["last_updated"].dt.day
df["dia_semana"] = df["last_updated"].dt.day_name(locale='es_ES')
df["hora"] = df["last_updated"].dt.hour
df["minutos"] = df["last_updated"].dt.minute



#longitud y latitud
df['longitud'] = df['geometry.coordinates'].apply(lambda x: x[0] if isinstance(x, list) and len(x) > 0 else x)
df['latitud'] = df['geometry.coordinates'].apply(lambda x: x[1] if isinstance(x, list) and len(x) > 0 else x)
df = df.drop(columns="geometry.coordinates")


#numero estacion 
df["estacion"] = df["address"].str.split('-').str[0]
df["nombre_estacion"] = df["address"].str.split('-').str[1]
df = df.drop(columns="address")


#csv limpio
df.to_csv(PROCESSED_PATH / "datos_limpios.csv")


#enviar a database
cargar_a_sqlite(PROCESSED_PATH / "datos_limpios.csv")



