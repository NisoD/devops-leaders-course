from fastapi.testclient import TestClient

# Import your app
from main import app

client = TestClient(app)


def test_homepage():
    """Test that the homepage loads successfully."""
    response = client.get("/")
    assert response.status_code == 200
    assert "<html" in response.text.lower()


def test_weather_success(monkeypatch):
    """Test the /weather endpoint with a mocked API response."""

    mock_response = {
        "current_condition": [
            {
                "temp_C": "22",
                "weatherDesc": [{"value": "Sunny"}],
            }
        ],
        "nearest_area": [
            {
                "areaName": [{"value": "TestCity"}],
                "latitude": "34.0522",
                "longitude": "-118.2437",
            }
        ],
    }

    def mock_get(*args, **kwargs):
        class MockResponse:
            def __init__(self):
                self.status_code = 200

            def json(self):
                return mock_response

        return MockResponse()

    monkeypatch.setattr("requests.get", mock_get)

    response = client.get("/weather?location=Tel Aviv")
    assert response.status_code == 200
    data = response.json()
    assert data["location"] == "TestCity"
    assert data["temperature"] == "22"
    assert data["description"] == "Sunny"


def test_stress_status_flag_disabled(monkeypatch):
    """Should return 403 if STRESS_TEST_FLAG is not enabled."""
    monkeypatch.setenv("STRESS_TEST_FLAG", "false")
    response = client.get("/stress_status")
    assert response.status_code == 403
    assert response.json()["detail"] == "CPU stress test feature is disabled"
