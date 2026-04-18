#include <WiFi.h>
#include <WebServer.h>
#include "ROBLEX.h"

ROBLEX ROBLEX;
WebServer server(80);

const char* ssid = "roblex";
const char* password = "12345678";

struct FeedingSchedule {
  String hhmm;
  int grams;
  bool active;
};

FeedingSchedule schedules[2] = {
  {"07:00", 80, true},
  {"18:00", 80, true},
};

bool sentToday[2] = {false, false};

void sendPlain(int code, const String &msg) {
  server.send(code, "text/plain", msg);
}

void handleRoot() {
  // Compatible with ROBLEX example: /?r201g32b255&
  if (server.hasArg("r") && server.hasArg("g") && server.hasArg("b")) {
    int r = server.arg("r").toInt();
    int g = server.arg("g").toInt();
    int b = server.arg("b").toInt();
    ROBLEX.Rgb(r, g, b);
    sendPlain(200, "ok rgb");
    return;
  }

  if (server.hasArg("cmd")) {
    String cmd = server.arg("cmd");

    // cmd=dispense:80
    if (cmd.startsWith("dispense:")) {
      int grams = cmd.substring(9).toInt();
      grams = constrain(grams, 1, 500);
      // TODO: reemplaza por tu logica real de motor/servo para dispensar.
      Serial.printf("Dispense command: %dg\n", grams);
      sendPlain(200, "ok dispense");
      return;
    }

    // cmd=schedule:1:07:00:80
    if (cmd.startsWith("schedule:")) {
      int p1 = cmd.indexOf(':', 9);
      int p2 = cmd.indexOf(':', p1 + 1);
      int p3 = cmd.indexOf(':', p2 + 1);
      if (p1 < 0 || p2 < 0 || p3 < 0) {
        sendPlain(400, "bad schedule format");
        return;
      }

      int slot = cmd.substring(9, p1).toInt();
      String hh = cmd.substring(p1 + 1, p2);
      String mm = cmd.substring(p2 + 1, p3);
      int grams = cmd.substring(p3 + 1).toInt();

      if (slot < 1 || slot > 2) {
        sendPlain(400, "invalid slot");
        return;
      }

      schedules[slot - 1].hhmm = hh + ":" + mm;
      schedules[slot - 1].grams = constrain(grams, 1, 500);
      schedules[slot - 1].active = true;
      sendPlain(200, "ok schedule");
      return;
    }

    if (cmd == "ping") {
      sendPlain(200, "pong");
      return;
    }

    sendPlain(400, "unknown cmd");
    return;
  }

  sendPlain(200, "roblex pet feeder online");
}

void setup() {
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(400);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());

  // Sincroniza hora para usar programacion por HH:MM.
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");

  server.on("/", HTTP_GET, handleRoot);
  server.begin();
}

void loop() {
  server.handleClient();

  // Planner simple por minuto.
  // Si coincide HH:MM, ejecuta una vez y marca enviado.
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    delay(200);
    return;
  }

  char current[6];
  snprintf(current, sizeof(current), "%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min);
  String now = String(current);

  for (int i = 0; i < 2; i++) {
    if (!schedules[i].active) continue;

    if (now == schedules[i].hhmm && !sentToday[i]) {
      // TODO: reemplaza por tu logica real de motor/servo para dispensar.
      Serial.printf("Auto dispense slot %d => %dg at %s\n", i + 1, schedules[i].grams, schedules[i].hhmm.c_str());
      sentToday[i] = true;
    }

    // Reset diario despues de medianoche
    if (timeinfo.tm_hour == 0 && timeinfo.tm_min == 1) {
      sentToday[i] = false;
    }
  }

  delay(200);
}
