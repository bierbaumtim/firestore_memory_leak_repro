# firestore_memory_leak_repro

A small Flutter project to reproduce memory leak in firedart on web.

## Issue
The try to get a snapshot of an collection produce a enormous memory leak on the web. Means you gets nearly 3-4 GB of ram within 2-3 minutes, before the browser stops the app. Using the same code on android or ios works just fine. 
