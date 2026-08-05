from pathlib import Path
PATH = Path(__file__).resolve().parent.parent
from data import recoger_data
import json
from datetime import datetime as dt 


# Direcciones de los archivos
DATA_PATH = PATH / "data"
SNAPSHOTS_PATH = DATA_PATH / "snapshots"



#recolección de los datos
url = "https://www.zaragoza.es/sede/servicio/urbanismo-infraestructuras/estacion-bicicleta.json?rows=300"
datos = recoger_data(url)


print(len(datos["result"]))

SNAPSHOTS_PATH.mkdir(parents=True, exist_ok=True)

ahora = dt.now().strftime("%Y%m%d_%H%M%S")

destino = SNAPSHOTS_PATH / f"snapshot_{ahora}.json"

with open(destino,"w", encoding="utf-8") as f:
    json.dump(datos,f, ensure_ascii=False)
    
    