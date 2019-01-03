# Installation

```
virtualenv -p python2 venv
source venv/bin/activate
git clone https://gitlab.com/theparadoxer02/iotflaskapi.git
cd iotflaskapi
pip install -r requirements.txt
export FLASK_APP=run.py
chmod u+x gunicorn.sh
```

Flask Web Server will running over 5555 Port

# Commands
-   POST: ```curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"deviceid":"10", "temperature": 99, "latitude": 28.344, "longitude": 29.43343, "timestamp": 1545806205861 }' \
    http://localhost:5555/topic```

