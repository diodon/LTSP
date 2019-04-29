import time
import pandas as pd


# The URL to the collection (as comma-separated values).
collection_url = "http://geoserver-123.aodn.org.au/geoserver/ows?typeName=anmn_ts_timeseries_data&SERVICE=WFS&outputFormat=csv&REQUEST=GetFeature&VERSION=1.0.0&CQL_FILTER=(TIME%20AFTER%201990-01-01T00:00:00%20AND%20site_code%20LIKE%20'NRSROT')"

t0 = time.perf_counter()

# Fetch data...
data = pd.read_csv(collection_url)

t1 = time.perf_counter()

print(t1-t0)

## print(data.head())
