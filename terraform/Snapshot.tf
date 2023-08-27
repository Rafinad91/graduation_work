
resource "yandex_compute_snapshot_schedule" "default" {
  name = "daily-snapshots"

  schedule_policy {
    expression = "0 2 * * *"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "Daily snapshot"
    labels = {
      daily_snapshot = "true"
    }
  }

  #disk_ids = ["epdgaoa8rbfrvuqa05o1", "fhmu66biv14b40vmklgi", "fhmhalmudfoom1j4aim7","fhmtmgqe6ugu0dufd783","fhmqrqhkuac4ooitvq8k","fhm3fciffuk5l7sqa4pu","fhmullsmpi46n9841ipe"]
}