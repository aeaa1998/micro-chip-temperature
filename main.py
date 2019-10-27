from smbus2 import SMBus
import time
import json
import datetime
from bmp280 import BMP280

bus = SMBus(1)
bmp280 = BMP280(i2c_dev=bus)
counter = 0

data = {
  "data": [],
  "hours": []
}
hoursS =""
tempsS = ""
fileHours= open("hours3.txt", "w+")
fileTemps= open("temps3.txt", "w+")
# file= open("json2.txt", "w+")
while counter < 25000:
    temperature = bmp280.get_temperature()
    now = datetime.datetime.now()
    # data["data"].append(temperature)
    # data["hours"].append(now.hour)
    hoursS += (str(now.hour) + " ")
    tempsS += (str(temperature) + " ")
    counter+= 1
    time.sleep(0.05)
    print(counter)

# jsonString = json.dumps(data)
fileHours.write("%s" % hoursS)
fileTemps.write("%s" % tempsS)
fileHours.close()
fileTemps.close()
