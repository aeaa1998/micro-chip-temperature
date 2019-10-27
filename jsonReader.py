import json
from bmp280 import BMP280


hourJson = '"hour": '
dataJson = '"data": '
data = {
  "data": [],
  "hours": []
}
# json.dump()
file= open("json.txt", "w+")
data["data"].append(1)
data["hours"].append(11)
jsonString = json.dumps(data)
file.write("%s" % jsonString)
file.close()