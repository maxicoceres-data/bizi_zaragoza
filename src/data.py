import requests

def recoger_data(url):
    
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        return data
        
    else:
        return f"Error: {response.status_code}"
    
