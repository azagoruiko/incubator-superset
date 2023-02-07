job "superset-job" {
  datacenters = ["home"]
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value = "storage"
  }
  group "superset-group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "superset-task" {
      driver = "docker"
      env {
        POSTGRES_DB="superset"
        POSTGRES_HOST="10.8.0.5"
        POSTGRES_PORT=5432
        REDIS_HOST="10.8.0.1"
        REDIS_PORT=6379
        SUPERSET_ENV="production"
        SUPERSET_PORT=8088
      }
      template {
        data = <<EOH
POSTGRES_USER="{{ key "postgres.jdbc.user" }}"
POSTGRES_PASSWORD="{{ key "postgres.jdbc.password" }}"
EOH
        destination = "secrets.env"
        env = true
      }
      config {
        image = "127.0.0.1:9999/docker/superset:0.0.13"
        privileged = true
        args = [
        ]

        port_map {
          web = 8088
        }

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 900
        memory = 900

        network {
          port  "web" {
            static = 8088
          }
        }
      }

      service {
        name = "superset-service"
        port = "web"
        tags = ["urlprefix-/superset strip=/superset"]

        check {
          type     = "http"
          path     = "/health"
          interval = "20s"
          timeout  = "2s"
        }
      }
    }
  }
}

