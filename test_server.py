import tritonclient.http as httpclient


with httpclient.InferenceServerClient("localhost:8000") as client:
    client.is_server_live()
    client.is_server_ready()
