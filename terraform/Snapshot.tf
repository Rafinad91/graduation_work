
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

  #disk_ids = var.disk_ids
}