# ari4me_app

This flutter app will be used to

- collect air quality values notified via BLE by the sensor (M5StickC Plus + Air quality sensor)
- send new data to the backend, when online (data will be dispatched by the backend on the MQTT broker)
- store data in the local MongoDB realm database, when offline. Sync the stored data when returns online.
- navigate and visualize the data

# references

To see how to use MongoDB Realm, please refer to:
https://www.mongodb.com/docs/realm/sdk/flutter/install/
