def test_index(app, client):
    res = client.get('/')
    assert res.status_code == 200
    assert res.get_data(as_text=True) == "Hello Docker and YouTube!"
