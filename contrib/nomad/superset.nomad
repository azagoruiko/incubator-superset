job "superset-job" {
  datacenters = ["home"]
  type        = "service"

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

        POSTGRES_HOST="192.168.0.21"
        POSTGRES_PORT=5432
        REDIS_HOST="192.168.0.21"
        REDIS_PORT=6379
        SUPERSET_ENV="production"
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
        image = "127.0.0.1:9999/docker/superset:0.0.3"
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
        cpu    = 700
        memory = 1024

        network {
          mbits = 10
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
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

